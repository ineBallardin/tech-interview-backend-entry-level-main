class Cart < ApplicationRecord
  ABANDONED_AFTER = 3.hours
  REMOVE_AFTER_ABANDONED = 7.days

  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_validation :set_default_total_price, on: :create
  before_create :set_last_interaction
  
  scope :not_abandoned, -> { where(abandoned: false) }
  scope :abandoned, -> { where(abandoned: true) }
  scope :ready_to_abandon, -> { 
    not_abandoned
      .where('last_interaction_at <= ?', ABANDONED_AFTER.ago) 
  }
  scope :ready_to_remove, -> { 
    abandoned
      .where('abandoned_at <= ?', REMOVE_AFTER_ABANDONED.ago) 
  }

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
    touch_interaction!
    
    return line_item
  end

  def remove_item(product_id)
    line_item = line_items.find_by(product_id: product_id)
    
    if line_item
      line_item.destroy
      touch_interaction!
      true
    else
      false
    end
  end

  def mark_as_abandoned
    return if abandoned?

    update!(
      abandoned: true,
      abandoned_at: Time.current
    )
  end

  def abandoned?
    abandoned == true
  end

  def ready_to_abandon?
    !abandoned? && last_interaction_at && last_interaction_at <= ABANDONED_AFTER.ago
  end

  def ready_to_remove?
    abandoned? && abandoned_at && abandoned_at <= REMOVE_AFTER_ABANDONED.ago
  end

  def remove_if_abandoned
    destroy if ready_to_remove?
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

  def set_last_interaction
    self.last_interaction_at = Time.current if last_interaction_at.nil?
  end

  def touch_interaction!
    update_column(:last_interaction_at, Time.current) if persisted?
    if abandoned?
      update_column(:abandoned, false)
      update_column(:abandoned_at, nil)
    end
  end

  def recalculate_total
    line_items.reload.sum(&:total_price)
  end
end