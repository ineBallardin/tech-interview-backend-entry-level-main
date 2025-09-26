class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_carts_as_abandoned
    remove_old_abandoned_carts
  end

  private

  def t(key, options = {})
    I18n.t(key, **{ scope: 'jobs.mark_cart_as_abandoned' }.merge(options))
  end

  def mark_carts_as_abandoned
    carts_to_abandon = Cart.ready_to_abandon
    
    Rails.logger.info t('marking_carts', count: carts_to_abandon.count)
    
    carts_to_abandon.find_each do |cart|
      cart.mark_as_abandoned
      Rails.logger.info t('cart_marked', id: cart.id)
    end
  end

  def remove_old_abandoned_carts
    carts_to_remove = Cart.ready_to_remove
    
    Rails.logger.info t('removing_carts', count: carts_to_remove.count)
    
    carts_to_remove.find_each do |cart|
      cart.remove_if_abandoned

      Rails.logger.info t('cart_removed', id: cart.id)
    end
  end
end
