require 'rails_helper'

RSpec.describe "/cart", type: :request do
  let!(:product) { create(:product, name: "Test Product", price: 10.00) }

  describe "GET /cart" do
    it "creates a new cart if one doesn't exist in the session" do
      get '/cart'

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      
      expect(json_response['id']).not_to be_nil
      expect(json_response['products']).to be_empty
      expect(json_response['total_price']).to eq("0.0")
    end

    it "returns an existing cart from the session" do
      post '/cart/add_item', params: { product_id: product.id, quantity: 1 }
      expect(response).to have_http_status(:ok)
      created_cart_id = JSON.parse(response.body)['id']

      get '/cart'
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(created_cart_id)
      expect(json_response['products'].first['id']).to eq(product.id)
    end
  end

  describe "POST /cart" do
    context "with a new product" do
      it "adds the product to the cart" do
        post '/cart', params: { product_id: product.id, quantity: 2 }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['id']).to eq(product.id)
        expect(json_response['products'].first['quantity']).to eq(2)
      end
    end

    context "with a product that already exists in the cart" do
      it "returns a conflict error and does not add the product" do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }
        expect(response).to have_http_status(:ok)

        post '/cart', params: { product_id: product.id, quantity: 3 }
        
        expect(response).to have_http_status(:conflict)
        
        get '/cart'
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(1)
      end
    end

    context "with an invalid product" do
      it "returns a not_found status" do
        post '/cart', params: { product_id: -1, quantity: 1 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /cart/add_item" do
    context "with a new product" do
      it "adds the product to the cart" do
        post '/cart/add_item', params: { product_id: product.id, quantity: 2 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['id']).to eq(product.id)
        expect(json_response['products'].first['quantity']).to eq(2)
      end
    end

    context "with a product that already exists in the cart" do
      it "increases the quantity of the existing product" do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }
        expect(response).to have_http_status(:ok)

        post '/cart/add_item', params: { product_id: product.id, quantity: 3 }
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(4)
        expect(json_response['total_price']).to eq("40.0")
      end
    end
  end
end