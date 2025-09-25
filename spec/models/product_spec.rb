require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'is invalid without a name' do
      product = build(:product, name: nil)
      product.valid?
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a price' do
      product = build(:product, price: nil)
      product.valid?
      expect(product.errors[:price]).to include("can't be blank")
    end

    it 'is invalid with a price less than 0' do
      product = build(:product, price: -1)
      product.valid?
      expect(product.errors[:price]).to include("must be greater than or equal to 0")
    end

    it 'is valid with all required attributes' do
      product = build(:product)
      expect(product).to be_valid
    end
  end
end