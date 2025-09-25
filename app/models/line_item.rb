class LineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  after_save :trigger_cart_price_update
  after_destroy :trigger_cart_price_update

  before_validation :set_price_from_product, on: :create

  def unit_price
    price || product.price
  end

  def total_price
    unit_price * quantity
  end

  def as_json(options = {})
    {
      id: product.id,
      name: product.name,
      quantity: quantity,
      unit_price: unit_price,
      total_price: total_price
    }
  end

  private

  def set_price_from_product
    self.price = product.price if price.nil? && product.present?
  end

  def trigger_cart_price_update
    cart.update_total!
  end
end