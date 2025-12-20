module Admin
  class CategoriesController < AdminController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      @categories = Category.includes(:parent)
                            .order(position: :asc, name: :asc)
                            .page(params[:page]).per(20)
    end

    def show
      @products = @category.products.page(params[:page]).per(10)
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      
      if @category.save
        redirect_to admin_category_path(@category), notice: 'Category was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_category_path(@category), notice: 'Category was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.destroy
        redirect_to admin_categories_url, notice: 'Category was successfully deleted.'
      else
        redirect_to admin_categories_url, alert: 'Cannot delete category with products.'
      end
    end

    private

    def set_category
      @category = Category.friendly.find(params[:id])
    end

    def category_params
      params.require(:category).permit(
        :name, :description, :parent_id, :position, :active,
        :meta_title, :meta_description
      )
    end
  end
end
