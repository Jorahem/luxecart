module Api
  module V1
    class BrandsController < BaseController
      def index
        @brands = Brand.active.order(:name)
        @brands = @brands.page(params[:page]).per(params[:per_page] || 20)

        render json: {
          brands: @brands.as_json(
            methods: [:products_count, :active_products_count]
          ),
          meta: pagination_metadata(@brands)
        }
      end

      def show
        @brand = Brand.friendly.find(params[:id])
        @products = @brand.products.active.page(params[:page]).per(12)

        render json: {
          brand: @brand.as_json(
            methods: [:products_count, :active_products_count]
          ),
          products: @products.as_json(
            include: {
              category: { only: [:id, :name, :slug] },
              brand: { only: [:id, :name, :slug] }
            },
            methods: [:average_rating, :in_stock?]
          ),
          meta: pagination_metadata(@products)
        }
      end
    end
  end
end
