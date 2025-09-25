require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'validations' do
    it 'is valid with a positive total_price' do
      cart = build(:cart, total_price: 10.0)
      expect(cart).to be_valid
    end

    it 'is valid with a total_price of 0' do
      cart = build(:cart, total_price: 0)
      expect(cart).to be_valid
    end

    it 'is invalid with a negative total_price' do
      cart = build(:cart, total_price: -1)
      cart.valid?
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe '#add_product' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 15.50) }

    context 'when adding a new product' do
      it 'creates a new line item' do
        expect {
          cart.add_product(product: product, quantity: 2)
        }.to change { cart.line_items.count }.by(1)
      end

      it 'sets the correct quantity for the new line item' do
        line_item = cart.add_product(product: product, quantity: 2)
        expect(line_item.quantity).to eq(2)
      end

      it 'updates the cart total price correctly' do
        cart.add_product(product: product, quantity: 2)
        expect(cart.total_price).to eq(31.0)
      end
    end

    context 'when adding a product that is already in the cart' do
      before do
        cart.add_product(product: product, quantity: 1)
      end

      it 'does not create a new line item' do
        expect {
          cart.add_product(product: product, quantity: 3)
        }.not_to change { cart.line_items.count }
      end

      it 'increases the quantity of the existing line item' do
        line_item = cart.add_product(product: product, quantity: 3)
        expect(line_item.quantity).to eq(4)
      end

      it 'updates the cart total price correctly' do
        cart.add_product(product: product, quantity: 3)
        expect(cart.total_price).to eq(62.0)
      end
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    xit 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    xit 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
