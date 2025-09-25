class Cart < ApplicationRecord
  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_validation :set_default_total_price, on: :create

  def add_product(product:, quantity:)
    line_item = line_items.find_or_initialize_by(product_id: product.id)
    
    if line_item.persisted?
      line_item.quantity = (line_item.quantity || 0) + quantity.to_i
    else
      line_item.quantity = quantity.to_i
      line_item.price = product.price
    end
    
    line_item.save!
    update_total!
    
    return line_item
  end

  def as_json(options = {})
    {
      id: id,
      products: line_items.reload.map(&:as_json),
      total_price: self.total_price
    }
  end

  def update_total!
    self.update!(total_price: recalculate_total)
  end

  private

  def set_default_total_price
    self.total_price = 0 if total_price.nil?
  end

  def recalculate_total
    line_items.sum { |item| item.quantity * (item.price || 0).to_f }
  end
end