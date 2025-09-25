require 'rails_helper'

RSpec.describe LineItem, type: :model do
  let(:product) { create(:product, price: 20.00) }
  let(:cart) { create(:cart) }

  describe 'validations' do
    it 'is valid with a quantity greater than 0' do
      line_item = build(:line_item, cart: cart, product: product, quantity: 1)
      expect(line_item).to be_valid
    end

    it 'is invalid with a quantity of 0' do
      line_item = build(:line_item, cart: cart, product: product, quantity: 0)
      line_item.valid?
      expect(line_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is invalid with a non-numeric quantity' do
      line_item = build(:line_item, cart: cart, product: product, quantity: 'abc')
      line_item.valid?
      expect(line_item.errors[:quantity]).to include("is not a number")
    end
  end

  describe 'callbacks' do
    context 'when creating a new line item' do
      it 'sets the price from the product' do
        line_item = create(:line_item, product: product, cart: cart)
        expect(line_item.price).to eq(20.00)
      end
    end

    context 'after saving or destroying' do
      it 'updates the cart total price when a new item is created' do
        expect {
          create(:line_item, product: product, cart: cart, quantity: 2)
        }.to change { cart.reload.total_price }.from(0.0).to(40.0)
      end

      it 'updates the cart total price when an item is destroyed' do
        line_item = create(:line_item, product: product, cart: cart, quantity: 2)
        expect {
          line_item.destroy
        }.to change { cart.reload.total_price }.from(40.0).to(0.0)
      end
    end
  end

  describe '#unit_price' do
    it 'returns the frozen price if it exists' do
      line_item = create(:line_item, product: product, price: 10.00)
      expect(line_item.unit_price).to eq(10.00)
    end

    it "returns the product's price if no frozen price is set" do
      line_item = build(:line_item, product: product, price: nil)
      expect(line_item.unit_price).to eq(20.00)
    end
  end

  describe '#total_price' do
    it 'correctly calculates the total price' do
      line_item = create(:line_item, product: product, quantity: 3, price: 10.00)
      expect(line_item.total_price).to eq(30.00)
    end
  end
end