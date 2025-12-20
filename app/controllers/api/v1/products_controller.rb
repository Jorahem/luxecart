module Api
  module V1
    class ProductsController < BaseController
      def index
        @products = ProductSearchService.new(params).search
        @products = @products.page(params[:page]).per(params[:per_page] || 12)

        render json: {
          products: @products.as_json(
            include: {
              category: { only: [:id, :name, :slug] },
              brand: { only: [:id, :name, :slug] }
            },
            methods: [:average_rating, :in_stock?, :on_sale?, :discount_percentage]
          ),
          meta: pagination_metadata(@products)
        }
      end

      def show
        @product = Product.friendly.find(params[:id])
        @product.increment!(:views_count)

        render json: {
          product: @product.as_json(
            include: {
              category: { only: [:id, :name, :slug] },
              brand: { only: [:id, :name, :slug] },
              reviews: { include: :user }
            },
            methods: [:average_rating, :in_stock?, :on_sale?, :discount_percentage]
          )
        }
      end
    end
  end
end
