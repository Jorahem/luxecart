module Admin
  class CategoriesController < AdminController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      @categories = Category.includes(:parent_category).order(:name).page(params[:page]).per(20)
    end

    def show
    end

    def new
      @category = Category.new
      @categories = Category.active.ordered_by_name
    end

    def edit
      @categories = Category.active.where.not(id: @category.id).ordered_by_name
    end

    def create
      @category = Category.new(category_params)
      
      if @category.save
        redirect_to admin_categories_path, notice: 'Category was successfully created.'
      else
        @categories = Category.active.ordered_by_name
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: 'Category was successfully updated.'
      else
        @categories = Category.active.where.not(id: @category.id).ordered_by_name
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.products.any?
        redirect_to admin_categories_path, alert: 'Cannot delete category with products.'
      else
        @category.destroy
        redirect_to admin_categories_path, notice: 'Category was successfully deleted.'
      end
    end

    private

    def set_category
      @category = Category.friendly.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description, :parent_id, :position, :active, :meta_title, :meta_description)
    end
  end
end
