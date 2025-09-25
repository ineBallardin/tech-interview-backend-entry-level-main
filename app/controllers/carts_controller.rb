class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :create, :add_item, :remove_item]
  before_action :set_product, only: [:create, :add_item, :remove_item]

  def show
    render json: @cart
  end

  def create
    existing_line_item = @cart.line_items.find_by(product_id: @product.id)

    if existing_line_item
      render json: {
        error: "Product already in cart.",
        message: "Use the /cart/add_item endpoint to update quantity."
      }, status: :conflict
    else
      quantity = cart_params[:quantity].to_i
      @cart.add_product(product: @product, quantity: quantity)
      render json: @cart, status: :created
    end
  end

  def add_item
    quantity = cart_params[:quantity].to_i
    @cart.add_product(product: @product, quantity: quantity)

    render json: @cart, status: :ok
  end

  def remove_item
    line_item = @cart.line_items.find_by(product_id: @product.id)

    if line_item
      line_item.destroy
      @cart.reload

      render json: @cart, status: :ok
    else
      render json: { error: "Product not found in cart." }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found." }, status: :not_found
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