module Admin
  class ProductsController < AdminController
    before_action :set_product, only: [:edit, :update, :destroy, :toggle_featured]

    def index
      @products = Product.order(created_at: :desc).limit(50)
    end

    def new
      @product = Product.new
      @categories = Category.where(active: true)
      @brands = Brand.where(active: true)
    end

    def create
      @product = Product.new(product_params)
      
      if @product.save
        redirect_to admin_products_path, notice: 'Product created successfully.'
      else
        @categories = Category.where(active: true)
        @brands = Brand.where(active: true)
        render :new
      end
    end

    def edit
      @categories = Category.where(active: true)
      @brands = Brand.where(active: true)
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: 'Product updated successfully.'
      else
        @categories = Category.where(active: true)
        @brands = Brand.where(active: true)
        render :edit
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: 'Product deleted successfully.'
    end

    def toggle_featured
      @product.update(featured: !@product.featured)
      redirect_to admin_products_path, notice: 'Product featured status updated.'
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :price, :compare_price, :cost_price,
        :sku, :barcode, :stock_quantity, :track_inventory,
        :status, :featured, :weight, :weight_unit,
        :meta_title, :meta_description, :category_id, :brand_id,
        images: []
      )
    end
  end
end
