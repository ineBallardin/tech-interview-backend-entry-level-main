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

  describe 'scopes' do
    let!(:active_cart) { create(:cart, last_interaction_at: 1.hour.ago) }
    let!(:inactive_cart) { create(:cart, last_interaction_at: 4.hours.ago) }
    let!(:abandoned_cart) { 
      create(:cart, abandoned: true, abandoned_at: 2.days.ago) 
    }
    let!(:old_abandoned_cart) { 
      create(:cart, abandoned: true, abandoned_at: 8.days.ago) 
    }
    
    describe '.not_abandoned' do
      it 'returns only non-abandoned carts' do
        expect(Cart.not_abandoned).to contain_exactly(active_cart, inactive_cart)
      end
    end
    
    describe '.abandoned' do
      it 'returns only abandoned carts' do
        expect(Cart.abandoned).to contain_exactly(abandoned_cart, old_abandoned_cart)
      end
    end
    
    describe '.ready_to_abandon' do
      it 'returns inactive carts not yet abandoned' do
        expect(Cart.ready_to_abandon).to contain_exactly(inactive_cart)
      end
    end
    
    describe '.ready_to_remove' do
      it 'returns carts abandoned for more than 7 days' do
        expect(Cart.ready_to_remove).to contain_exactly(old_abandoned_cart)
      end
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

  describe 'abandoned cart functionality' do
    let(:cart) { create(:cart) }
    
    describe '#mark_as_abandoned' do
      context 'when cart is not abandoned' do
        it 'marks the cart as abandoned' do
          expect { cart.mark_as_abandoned }.to change { 
            cart.abandoned? 
          }.from(false).to(true)
        end
        
        it 'records the abandonment timestamp' do
          cart.mark_as_abandoned
          expect(cart.abandoned_at).to be_within(1.second).of(Time.current)
        end
      end
      
      context 'when cart is already abandoned' do
        before do
          cart.update!(abandoned: true, abandoned_at: 1.day.ago)
        end
        
        it 'does not change the state' do
          expect { cart.mark_as_abandoned }.not_to change { cart.abandoned_at }
        end
      end
    end
    
    describe '#ready_to_abandon?' do
      it 'returns true when inactive for more than 3 hours' do
        cart.update!(last_interaction_at: 4.hours.ago)
        expect(cart.ready_to_abandon?).to be true
      end
      
      it 'returns false when recently active' do
        cart.update!(last_interaction_at: 1.hour.ago)
        expect(cart.ready_to_abandon?).to be false
      end
      
      it 'returns false when already abandoned' do
        cart.update!(abandoned: true, last_interaction_at: 4.hours.ago)
        expect(cart.ready_to_abandon?).to be false
      end
    end
    
    describe '#ready_to_remove?' do
      it 'returns true when abandoned for more than 7 days' do
        cart.update!(abandoned: true, abandoned_at: 8.days.ago)
        expect(cart.ready_to_remove?).to be true
      end
      
      it 'returns false when recently abandoned' do
        cart.update!(abandoned: true, abandoned_at: 3.days.ago)
        expect(cart.ready_to_remove?).to be false
      end
      
      it 'returns false when not abandoned' do
        expect(cart.ready_to_remove?).to be false
      end
    end
    
    describe 'product interaction' do
      let(:product) { create(:product) }
      
      it 'updates last_interaction_at when adding product' do
        cart.update!(last_interaction_at: 1.day.ago)
        
        expect { 
          cart.add_product(product: product, quantity: 1) 
        }.to change { 
          cart.reload.last_interaction_at 
        }
        
        expect(cart.last_interaction_at).to be_within(1.second).of(Time.current)
      end
      
      it 'removes abandoned flag when adding product' do
        cart.update!(abandoned: true, abandoned_at: 1.day.ago)
        
        cart.add_product(product: product, quantity: 1)
        
        expect(cart.reload.abandoned?).to be false
        expect(cart.abandoned_at).to be_nil
      end
      
      it 'updates last_interaction_at when removing product' do
        cart.add_product(product: product, quantity: 1)
        cart.update!(last_interaction_at: 1.day.ago)
        
        expect { 
          cart.remove_item(product.id) 
        }.to change { 
          cart.reload.last_interaction_at 
        }
      end
    end
  end
end