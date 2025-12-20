module Admin
  class ProductsController < AdminController
    before_action :set_product, only: [:show, :edit, :update, :destroy]

    def index
      @products = Product.includes(:category, :brand).order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
    end

    def new
      @product = Product.new
      @categories = Category.active.ordered_by_name
      @brands = Brand.active.ordered_by_name
    end

    def edit
      @categories = Category.active.ordered_by_name
      @brands = Brand.active.ordered_by_name
    end

    def create
      @product = Product.new(product_params)
      
      if @product.save
        redirect_to admin_product_path(@product), notice: 'Product was successfully created.'
      else
        @categories = Category.active.ordered_by_name
        @brands = Brand.active.ordered_by_name
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
      else
        @categories = Category.active.ordered_by_name
        @brands = Brand.active.ordered_by_name
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_url, notice: 'Product was successfully deleted.'
    end

    private

    def set_product
      @product = Product.friendly.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :price, :compare_price, :cost_price, :sku, :barcode,
        :stock_quantity, :track_inventory, :status, :featured, :weight, :weight_unit,
        :meta_title, :meta_description, :category_id, :brand_id, tags: []
      )
    end
  end
end
