# == Schema Information
#
# Table name: shopping_carts
#
#  id         :integer          not null, primary key
#  buyer_id   :integer
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe ShoppingCart, type: :model do
  
  context 'when checking out products in shopping cart' do
    before do
      @user = User.create!(email: 'glenn@example.com', password: 'password')
      @user2 = User.create!(email: 'sam@example.com', password: 'password')
      @product1 = Product.create!(seller: @user, name: 'Batman1', price: 100.24, description: 'Test Product', condition: 'Mint', category: 'Comic Books & Graphic Novels', status: 'Available', postage: 'None/Pickup Only')
      @product2 = Product.create!(seller: @user, name: 'Batman2', price: 200.13, description: 'Test Product', condition: 'Mint', category: 'Comic Books & Graphic Novels', status: 'Available', postage: 'None/Pickup Only')
      @product3 = Product.create!(seller: @user, name: 'Batman3', price: 300.44, description: 'Test Product', condition: 'Mint', category: 'Comic Books & Graphic Novels', status: 'Available', postage: 'None/Pickup Only')
      @price_sum_of_products = ((@product1.price + @product2.price + @product3.price) * 100).to_i
      @shopping_cart_item1 = ShoppingCart.create!(product_id: @product1.id, buyer: @user2)
      @shopping_cart_item2 = ShoppingCart.create!(product_id: @product2.id, buyer: @user2)
      @shopping_cart_item3 = ShoppingCart.create!(product_id: @product3.id, buyer: @user2)
      @shopping_cart = ShoppingCart.where(buyer: @user2)
    end

    it 'will contain the product' do
      expect(@shopping_cart_item1.product).to eq(@product1)
    end

    it 'will contain the product price' do
      expect(@shopping_cart_item1.product.price).to eq(@product1.price)
    end

    it 'will contain the product status' do
      expect(@shopping_cart_item1.product.status).to eq(@product1.status)
    end

    it 'will set the shopping cart item to Sold' do
      @shopping_cart_item1.change_product_status_to('Sold')
      expect(@shopping_cart_item1.product.status).to eq('Sold')
    end

    it 'will set the shopping cart item to Available' do
      @shopping_cart_item2.change_product_status_to('Available')
      expect(@shopping_cart_item2.product.status).to eq('Available')
    end

    it 'will set the shopping cart item to Checked Out' do
      @shopping_cart_item3.change_product_status_to('Checked Out')
      expect(@shopping_cart_item3.product.status).to eq('Checked Out')
    end

    it 'will get the total amount in cents of all products for a user' do
      @amount = (@shopping_cart.map(&:product).map(&:price).sum * 100).to_i
      expect(@amount).to eq(@price_sum_of_products)
    end
  end
end
