module Admin
  class ProductsController < AdminController
    before_action :set_product, only: [:edit, :update, :destroy]

    def index
      @products = Product.includes(:category, :brand).page(params[:page]).per(20)
    end

    def new
      @product = Product.new
      @categories = Category.all
      @brands = Brand.all
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: 'Product created successfully.'
      else
        @categories = Category.all
        @brands = Brand.all
        render :new
      end
    end

    def edit
      @categories = Category.all
      @brands = Brand.all
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: 'Product updated successfully.'
      else
        @categories = Category.all
        @brands = Brand.all
        render :edit
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: 'Product deleted successfully.'
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price, :sale_price, :sku, :stock_quantity, :category_id, :brand_id, :active, :featured)
    end
  end
end
