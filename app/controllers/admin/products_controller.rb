module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[show edit update destroy toggle_active]

    def index
      @products = Product.includes(:category).order(created_at: :desc)
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Product created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Product updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Product deleted."
    end

    def toggle_active
      @product.update(active: !@product.active)
      redirect_to admin_products_path, notice: "Product status updated."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :sku, :price, :stock_quantity,
        :image, :active, category_ids: []
      )
    end
  end
end