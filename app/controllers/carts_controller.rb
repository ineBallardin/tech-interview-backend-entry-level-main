class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_product, only: [:create, :add_item]

  def show
    render json: @cart
  end

  def create
    existing_line_item = @cart.line_items.find_by(product_id: @product.id)

    if existing_line_item
      render json: {
        error: t('.errors.product_already_in_cart'),
        message: t('.errors.use_add_item_endpoint')
      }, status: :conflict
    else
      quantity = cart_params[:quantity].to_i
      @cart.add_product(product: @product, quantity: quantity)
      render json: @cart, status: :created
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [t('.errors.product_not_found')] }, status: :not_found
  end

  def add_item
    quantity = cart_params[:quantity].to_i
    @cart.add_product(product: @product, quantity: quantity)
    
    render json: @cart, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [t('.errors.product_not_found')] }, status: :not_found
  end

  def remove_item
    removed_item = @cart.remove_item(params[:product_id])

    if removed_item
      render json: @cart
    else
      render json: { errors: [t('.errors.product_not_found_in_cart')] }, status: :not_found
    end
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!
    session[:cart_id] = @cart.id
  end

  def set_product
    @product = Product.find(cart_params[:product_id])
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end
end