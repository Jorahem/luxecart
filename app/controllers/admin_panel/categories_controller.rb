module AdminPanel
  class CategoriesController < AdminPanel::BaseController
    before_action :set_category, only: %i[show edit update destroy]

    def index
      @categories = Category.ordered_by_name
    end

    def show
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_path, notice: "Category created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.destroy
        redirect_to admin_categories_path, notice: "Category deleted."
      else
        redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence.presence || "Could not delete category."
      end
    end

    # POST /admin/categories/sort
    # expects params[:order] to be an array of category IDs in the new order
    def sort
      order = Array(params[:order])

      Category.transaction do
        order.each_with_index do |id, index|
          Category.where(id: id).update_all(position: index) if Category.column_names.include?("position")
        end
      end

      respond_to do |format|
        format.html { redirect_to admin_categories_path, notice: "Categories sorted." }
        format.json { head :no_content }
      end
    end

    private

    def set_category
      @category = Category.friendly.find(params[:id])
    rescue StandardError
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description, :parent_id, :active)
    end
  end
end