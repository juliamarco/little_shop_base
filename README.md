This project builds two extensions on top of Little Shop of Orders, a BE Mod 2 Week 4/5 Group Project at Turing School of Software and Design.

The original project consists of building a fictitious e-commerce platform where users can register to place items into a shopping cart and 'check out'. Merchant users can mark items as 'fulfilled', and Admins can mark orders as 'complete'. Each user role will have access to some or all CRUD functionality for application models.

The two extensions built are Coupon Codes & Merchant Stats Charts.

## Merchant Statistics as Charts

### The general goal of this extension is to convert statistics blocks on the application to visual charts using charting JavaScript libraries like D3, C3 or Google Charts, or find a Ruby gem that can assist.

This are some of the charts created. 

Total Revenue by month for a merchant:

<img width="457" alt="screen shot 2019-02-28 at 10 41 22 am" src="https://user-images.githubusercontent.com/35079289/53587310-4356f580-3b47-11e9-9828-402a75438e45.png">

Sold Items Percentage for a merchant:

<img width="446" alt="screen shot 2019-02-28 at 10 33 50 am" src="https://user-images.githubusercontent.com/35079289/53587311-4356f580-3b47-11e9-9d64-37bd5c84cc54.png">

Top Items Sold By Quantity for a merchant:

<img width="392" alt="screen shot 2019-02-28 at 10 29 47 am" src="https://user-images.githubusercontent.com/35079289/53587312-4356f580-3b47-11e9-9d1d-e64969e04622.png">

Top States By Items Shipped:

<img width="392" alt="screen shot 2019-02-28 at 10 28 15 am" src="https://user-images.githubusercontent.com/35079289/53587313-43ef8c00-3b47-11e9-844a-c758b847cdc5.png">

Total Sales on the whole site:

<img width="221" alt="screen shot 2019-02-28 at 10 48 14 am" src="https://user-images.githubusercontent.com/35079289/53587314-43ef8c00-3b47-11e9-9022-8b16969c1955.png">

## Coupon Codes

### The general goal of this extension is that Merchants can generate coupon codes within the system and user can apply these coupons.

As a merchant, you have access to a "My Coupons" link, where you can manage your coupons
<img width="329" alt="screen shot 2019-02-28 at 10 47 30 am" src="https://user-images.githubusercontent.com/35079289/53587317-43ef8c00-3b47-11e9-8627-fcc657ebd8f4.png">

This will take you to your Coupon's index page, where you have all CRUD functionality over your coupons:
<img width="307" alt="screen shot 2019-02-28 at 10 47 47 am" src="https://user-images.githubusercontent.com/35079289/53587316-43ef8c00-3b47-11e9-92a9-303b9c76f208.png">

Let's create a new coupon that we can apply as a user later on. 

<img width="221" alt="screen shot 2019-02-28 at 10 48 14 am" src="https://user-images.githubusercontent.com/35079289/53587314-43ef8c00-3b47-11e9-9022-8b16969c1955.png">

This coupon is now linked to all this merchant's items(merchant_1), and as a user, I can submit that coupon now. This is our cart right now. I have items from 3 different merchants. When I submit the coupon, I should see the discount applied to the items from merchant_1 only:

<img width="1000" alt="screen shot 2019-02-28 at 11 00 05 am" src="https://user-images.githubusercontent.com/35079289/53587604-10613180-3b48-11e9-875e-b92cfcaec16e.png">

<img width="801" alt="screen shot 2019-02-28 at 11 02 08 am" src="https://user-images.githubusercontent.com/35079289/53587712-4d2d2880-3b48-11e9-9286-6777b28e00ac.png">

We see how we have successfully applied the coupon, the discounted total, and our total updated.
When we check out and go to that order's page, we see again the discounted total, the total, and our coupon used

<img width="319" alt="screen shot 2019-02-28 at 11 03 43 am" src="https://user-images.githubusercontent.com/35079289/53587795-849bd500-3b48-11e9-9275-186ffa697012.png">

