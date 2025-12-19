module Admin
  class CategoriesController < AdminController
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      @categories = Category.all.order(:name)
    end

    def new
      @category = Category.new
      @parent_categories = Category.where(parent_category_id: nil)
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: 'Category created successfully.'
      else
        @parent_categories = Category.where(parent_category_id: nil)
        render :new
      end
    end

    def edit
      @parent_categories = Category.where(parent_category_id: nil).where.not(id: @category.id)
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: 'Category updated successfully.'
      else
        @parent_categories = Category.where(parent_category_id: nil).where.not(id: @category.id)
        render :edit
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_categories_path, notice: 'Category deleted successfully.'
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description, :active, :parent_category_id)
    end
  end
end
