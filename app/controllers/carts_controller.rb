class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :create]
  before_action :set_product, only: [:create]

  def show
    render json: @cart
  end

  def create
    quantity = cart_params[:quantity].to_i
    @cart.add_product(product: @product, quantity: quantity)

    render json: @cart, status: :created
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