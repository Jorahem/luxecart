module Api
  module V1
    class CategoriesController < BaseController
      def index
        @categories = Category.active.includes(:parent)
        @categories = @categories.root if params[:root_only] == 'true'
        @categories = @categories.page(params[:page]).per(params[:per_page] || 20)

        render json: {
          categories: @categories.as_json(
            include: :subcategories,
            methods: [:products_count]
          ),
          meta: pagination_metadata(@categories)
        }
      end

      def show
        @category = Category.friendly.find(params[:id])
        @products = @category.all_products.active.page(params[:page]).per(12)

        render json: {
          category: @category.as_json(
            include: :subcategories,
            methods: [:products_count]
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
