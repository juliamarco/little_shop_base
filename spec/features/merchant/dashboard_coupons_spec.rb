require 'rails_helper'

describe "Merchant Dashboard Coupons page" do
  before :each do
    @merchant = create(:merchant)
    @coupon_1 = @merchant.coupons.create!(code: "123", dollar: 9.0, percentage: true)
    @coupon_2 = @merchant.coupons.create!(code: "345", dollar: 9.0, percentage: true)
    @coupon_3 = @merchant.coupons.create!(code: "456", dollar: 9.0, percentage: true)
    @coupon_4 = @merchant.coupons.create!(code: "678", dollar: 9.0, percentage: true)

  end

  describe 'as a merchant' do
    it 'should allow me to add a new coupon with percentage' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path
      click_link 'Add New Coupon'

      expect(current_path).to eq(new_dashboard_coupon_path)

      code = "AEIOU"
      discount = 36.0

      fill_in :code, with: code
      select 'Percent', from: 'Type of discount'
      fill_in "Amount", with: discount
      click_button  'Create Coupon'

      expect(current_path).to eq(dashboard_coupons_path)

      expect(page).to have_content("Coupon '#{code}' has been added!")

      coupon = Coupon.last

      within "#coupon-#{coupon.id}" do
        expect(page).to have_content("Coupon Code: #{coupon.code}")
        expect(page).to have_content("Coupon Discount: #{coupon.dollar.round}%")
        expect(page).to have_link('Edit Coupon')
        expect(page).to have_button('Delete Coupon')
        expect(page).to have_button('Disable Coupon')
      end
    end

    it "will render the form again if enter invalid options when creating" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path
      click_link 'Add New Coupon'

      code = "AEIOU"
      discount = "julia"

      fill_in :code, with: code
      select 'Percent', from: 'Type of discount'
      fill_in "Amount", with: discount
      click_button  'Create Coupon'

      expect(page).to have_content("1 error prohibited this coupon from being saved: Dollar is not a number")
    end

    it 'should allow me to add a new coupon with dollars' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path

      click_link 'Add New Coupon'

      code = "SDF32"
      discount = 5.5

      fill_in :code, with: code
      select 'Dollars', from: 'Type of discount'
      fill_in "Amount", with: discount
      click_button 'Create Coupon'

      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to have_content("Coupon '#{code}' has been added!")

      coupon = Coupon.last

      within "#coupon-#{coupon.id}" do
        expect(page).to have_content("Coupon Code: #{coupon.code}")
        expect(page).to have_content("Coupon Discount: $#{coupon.dollar}")
        expect(page).to have_link('Edit Coupon')
        expect(page).to have_button('Delete Coupon')
        expect(page).to have_button('Disable Coupon')
      end
    end

    it 'should not let me have more than 5 coupons' do
      coupon_5 = @merchant.coupons.create!(code: "789", dollar: 9.0, percentage: true)


      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path

      click_link 'Add New Coupon'

      code = "SDF32"
      discount = 5.5

      fill_in :code, with: code
      select 'Dollars', from: 'Type of discount'
      fill_in "Amount", with: discount
      click_button 'Create Coupon'

      expect(page).to have_content("You can't have more than 5 coupons!")
    end

    it "lets me disable and re-enable an coupon" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path

      within "#coupon-#{Coupon.first.id}" do
        click_button 'Disable Coupon'
      end

      within "#coupon-#{Coupon.first.id}" do
        expect(page).to_not have_button('Disable Coupon')
        click_button 'Enable Coupon'
      end

      within "#coupon-#{Coupon.first.id}" do
        expect(page).to_not have_button('Enable Coupon')
      end
    end

    it "lets me edit an existing coupon" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        click_link 'Edit Coupon'
      end

      expect(current_path).to eq(edit_dashboard_coupon_path(@coupon_1))

      fill_in :code, with: ('New ' + @coupon_1.code)
      select 'Dollars', from: 'Type of discount'
      fill_in "Amount", with: 123
      click_button 'Update Coupon'

      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to have_content("Coupon 'New #{@coupon_1.code}' has been updated!")

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_content("Coupon Code: New #{@coupon_1.code}")
        expect(page).to have_content("Coupon Discount: $123")
      end
    end

    it "will render the form again if enter invalid options when editing" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        click_link 'Edit Coupon'
      end

      expect(current_path).to eq(edit_dashboard_coupon_path(@coupon_1))

      fill_in :code, with: ('New ' + @coupon_1.code)
      select 'Dollars', from: 'Type of discount'
      fill_in "Amount", with: "hola"
      click_button 'Update Coupon'

      expect(page).to have_content("1 error prohibited this coupon from being saved")
    end

    it "lets me delete an existing coupon if it hasn't been used" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        click_button 'Delete Coupon'
      end

      expect(page).to_not have_css("#coupon-#{@coupon_1.id}")
      expect(page).to_not have_content(@coupon_1.code)
    end

    it "Does not let me delete an existing coupon if it has been used" do
      user = create(:user, state: "IA", city: "Des Moines")
      order = create(:completed_order, user: user, coupon: @coupon_1)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @am_admin = false
      visit dashboard_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        click_button 'Delete Coupon'
      end

      expect(page).to have_css("#coupon-#{@coupon_1.id}")
      expect(page).to have_content("You cannot delete coupon: #{@coupon_1.code}!")
    end
  end
end
