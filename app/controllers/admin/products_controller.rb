module Admin
  class ProductsController < AdminController
    before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_featured]

    def index
      @products = Product.includes(:category, :brand)
      @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
      @products = @products.where(brand_id: params[:brand_id]) if params[:brand_id].present?
      @products = @products.where(status: params[:status]) if params[:status].present?
      @products = @products.search_by_full_text(params[:query]) if params[:query].present?
      @products = @products.page(params[:page]).per(20)
    end

    def show
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      
      if @product.save
        redirect_to admin_product_path(@product), notice: 'Product was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_url, notice: 'Product was successfully deleted.'
    end

    def toggle_featured
      @product.update(featured: !@product.featured)
      redirect_to admin_products_path, notice: 'Product featured status updated.'
    end

    private

    def set_product
      @product = Product.friendly.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :price, :compare_price, :cost_price,
        :sku, :barcode, :stock_quantity, :track_inventory,
        :category_id, :brand_id, :status, :featured,
        :weight, :weight_unit, :meta_title, :meta_description,
        tags: []
      )
    end
  end
end
