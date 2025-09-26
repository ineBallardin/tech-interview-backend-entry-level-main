class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_carts_as_abandoned
    remove_old_abandoned_carts
  end

  private

  def mark_carts_as_abandoned
    carts_to_abandon = Cart.ready_to_abandon
    
    Rails.logger.info "Marking #{carts_to_abandon.count} cart(s) as abandoned"
    
    carts_to_abandon.find_each do |cart|
      cart.mark_as_abandoned
      Rails.logger.info "Cart ##{cart.id} marked as abandoned"
    end
  end

  def remove_old_abandoned_carts
    carts_to_remove = Cart.ready_to_remove
    
    Rails.logger.info "Removing #{carts_to_remove.count} abandoned cart(s)"
    
    carts_to_remove.find_each do |cart|
      cart.remove_if_abandoned

      Rails.logger.info "Cart ##{cart.id} removed (abandoned for more than 7 days)"
    end
  end
end
