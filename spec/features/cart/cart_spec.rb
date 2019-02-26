require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'cart workflow', type: :feature do
  before :each do
    @merchant = create(:merchant)
    @merchant_2 = create(:merchant)
    @item = create(:item, user: @merchant)
    @item_2 = create(:item, user: @merchant)
    @item_3 = create(:item, user: @merchant_2)
    @coupon = @merchant.coupons.create!(code: "123", dollar: 2.0, percentage: false)
    @coupon_2 = @merchant.coupons.create!(code: "234", dollar: 50.0, percentage: true)
  end

  describe 'shows an empty cart when no items are added' do
    scenario 'as a visitor' do
      visit cart_path
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit cart_path
    end
    after :each do
      expect(page).to have_content('Your cart is empty')
      expect(page).to_not have_button('Emtpy cart')
    end
  end

  describe 'allows visitors to add items to cart' do
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      expect(page).to have_content("You have 1 package of #{@item.name} in your cart")
      expect(page).to have_link("Cart: 1")
      expect(current_path).to eq(items_path)

      visit item_path(@item)
      click_button "Add to Cart"

      expect(page).to have_content("You have 2 packages of #{@item.name} in your cart")
      expect(page).to have_link("Cart: 2")
    end
  end

  describe 'shows an empty cart when no items are added' do
    before :each do
      @item_2 = create(:item, user: @merchant)
    end
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit item_path(@item_2)
      click_button "Add to Cart"
      visit item_path(@item_2)
      click_button "Add to Cart"

      visit cart_path

      expect(page).to_not have_content('Your cart is empty')
      expect(page).to have_button('Empty cart')

      within "#item-#{@item.id}" do
        expect(page).to have_content(@item.name)
        expect(page.find("#item-#{@item.id}-image")['src']).to have_content(@item.image)
        expect(page).to have_content("Merchant: #{@item.user.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item.price)}")
        expect(page).to have_content("Quantity: 1")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item.price*1)}")
      end
      within "#item-#{@item_2.id}" do
        expect(page).to have_content(@item_2.name)
        expect(page.find("#item-#{@item_2.id}-image")['src']).to have_content(@item_2.image)
        expect(page).to have_content("Merchant: #{@item_2.user.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_2.price)}")
        expect(page).to have_content("Quantity: 2")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item_2.price*2)}")
      end
      expect(page).to have_content("Total: #{number_to_currency(@item.price + (@item_2.price*2)) }")
    end
  end

  describe 'users can empty their cart if it has items in it' do
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit cart_path

      expect(page).to_not have_content('Your cart is empty')
      click_button 'Empty cart'

      expect(current_path).to eq(cart_path)
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')
    end
  end

  describe 'users can increase or decrease cart quantities' do
    before :each do
      @item_2 = create(:item, user: @merchant, inventory: 3)
    end
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit cart_path

      within "#item-#{@item.id}" do
        click_button 'Remove all from cart'
      end
      expect(page).to have_content("You have removed all packages of #{@item.name} from your cart")
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')

      visit item_path(@item_2)
      click_button "Add to Cart"
      visit cart_path

      within "#item-#{@item_2.id}" do
        click_button 'Add more to cart'
      end
      within "#item-#{@item_2.id}" do
        click_button 'Add more to cart'
      end
      expect(page).to have_link('Cart: 3')

      within "#item-#{@item_2.id}" do
        expect(page).to_not have_button('Add more to cart')
      end

      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      expect(page).to have_content("You have removed 1 package of #{@item_2.name} from your cart, new quantity is 1")
      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')
    end
  end

  describe 'users can checkout (or not) depending on role' do
    scenario 'as a visitor' do
      visit item_path(@item)
      click_button "Add to Cart"
      visit cart_path
      expect(page).to have_content('You must register or log in to check out')
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit profile_orders_path
      expect(page).to have_content('You have no orders yet')

      visit item_path(@item)
      click_button "Add to Cart"
      visit cart_path

      click_button 'Check out'

      expect(current_path).to eq(profile_orders_path)
      expect(page).to have_content('You have successfully checked out!')

      visit profile_orders_path
      expect(page).to have_content("Order ID #{Order.last.id}")
    end
  end

  describe 'does not allow merchants to add items to a cart' do
    scenario 'as a merchant' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
    end
    scenario 'as an admin' do
      admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    end
    after :each do
      visit item_path(@item)

      expect(page).to_not have_button("Add to cart")
    end
  end

  describe 'as a registered user' do
    it 'displays me a form to enter a coupon code' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
      click_button "Add to Cart"
      visit item_path(@item)
      click_button "Add to Cart"

      visit cart_path
      fill_in :coupon, with: @coupon.code
      click_button "Submit Coupon"
 
      expect(page).to have_content("Coupon '#{@coupon.code}' successfully applied")
    end

    it 'applies the coupon dollars and updates subtotal and grand total in cart' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
      click_button "Add to Cart"
      visit item_path(@item)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit cart_path
      fill_in :coupon, with: @coupon.code
      click_button "Submit Coupon"

      expect(page).to have_content("Subtotal: $4.00")
      expect(page).to have_content("Subtotal: $2.50")
      expect(page).to have_content("Total: $6.50")
    end

    it 'applies the coupon percent and updates subtotal and grand total in cart and remembers the discount' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
      click_button "Add to Cart"
      visit item_path(@item)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit cart_path
      fill_in :coupon, with: @coupon_2.code
      click_button "Submit Coupon"
      expect(page).to have_content("Subtotal: $3.00")
      expect(page).to have_content("Subtotal: $2.25")
      expect(page).to have_content("Total: $5.25")

      visit root_path
      visit cart_path

      expect(page).to have_content("Subtotal: $3.00")
      expect(page).to have_content("Subtotal: $2.25")
      expect(page).to have_content("Total: $5.25")
    end

    it "let's me know if code invalid" do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
      click_button "Add to Cart"
      visit item_path(@item)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit cart_path
      fill_in :coupon, with: "hola"
      click_button "Submit Coupon"

      expect(page).to have_content("Invalid coupon. Try again")
    end

    it "let's me know if code has been used" do
      user = create(:user)
      order = create(:completed_order, user: user, coupon: @coupon)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
      click_button "Add to Cart"
      visit item_path(@item)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit cart_path
      fill_in :coupon, with: @coupon.code
      click_button "Submit Coupon"

      expect(page).to have_content("You have already applied coupon '#{@coupon.code}'")
    end

    it 'only updates the item from the merchant the coupon belongs to' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit item_path(@item)
      click_button "Add to Cart"
      visit item_path(@item_3)
      click_button "Add to Cart"

      visit cart_path
      fill_in :coupon, with: @coupon_2.code
      click_button "Submit Coupon"

      expect(page).to have_content("Subtotal: $1.50")
      expect(page).to have_content("Subtotal: $6.00")
    end

    it 'cart should not display a negative value' do
      coupon = @merchant.coupons.create!(code: "UJK", dollar: 150.0, percentage: true)

      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit item_path(@item)
      click_button "Add to Cart"

      visit cart_path
      fill_in :coupon, with: coupon.code
      click_button "Submit Coupon"

      expect(page).to have_content("Total: $0.00")
    end
  end
end

RSpec.describe CartController, type: :controller do
  it 'redirects back to where you came from if you try to add an invalid item id to cart' do
    item = create(:item)
    put :add, params: {id: (item.id + 1)}
    expect(response.request.env['action_dispatch.request.flash_hash'].to_h['error']).to eq('Cannot add that item')
    expect(response.status).to eq(302)
    expect(response.header['Location']).to include(items_path)
  end
end
