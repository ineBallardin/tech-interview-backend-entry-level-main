require 'rails_helper'

RSpec.describe "Carts", type: :request do
  let!(:product) { create(:product) }

  describe "GET /cart" do
    it "creates a new cart if one doesn't exist in the session" do
      get '/cart'

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).not_to be_nil
      expect(json_response['products']).to be_empty
    end

    it "returns an existing cart from the session" do
      post '/cart', params: { product_id: product.id, quantity: 1 }
      expect(response).to have_http_status(:created)
      created_cart_id = JSON.parse(response.body)['id']

      get '/cart'
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(created_cart_id)
      expect(json_response['products'].first['id']).to eq(product.id)
    end
  end

  describe "POST /cart" do
    context "with valid parameters" do
      it "adds a product to a new cart" do
        post '/cart', params: { product_id: product.id, quantity: 2 }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['id']).to eq(product.id)
        expect(json_response['products'].first['quantity']).to eq(2)
      end

      it "increases the quantity of an existing product in the cart" do
        post '/cart', params: { product_id: product.id, quantity: 1 }
        expect(response).to have_http_status(:created)

        post '/cart', params: { product_id: product.id, quantity: 3 }
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(4)
      end
    end

    context "with invalid parameters" do
      it "returns a not_found status if the product_id is invalid" do
        post '/cart', params: { product_id: -1, quantity: 1 }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end