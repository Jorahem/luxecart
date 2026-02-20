module AdminPanel
  class ProductsController < AdminPanel::BaseController
    before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_featured]

    def index
      @products = Product.order(created_at: :desc)
    end

    def show
      redirect_to admin_products_path
    end

    def new
      @product = Product.new
    end

    def edit; end

    def create
      @product = Product.new(product_params)
      
      # Set default status to active so product is visible
      @product.status = :active if @product.status.blank?

      if @product.save
        redirect_to admin_products_path, notice: "Product created successfully and is now visible to customers."
      else
        render :new, status: :unprocessable_entity
      end
    end

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

    def toggle_featured
      unless @product.respond_to?(:featured)
        redirect_to admin_products_path, alert: "This product model has no featured field." and return
      end

      @product.update(featured: !@product.featured)
      redirect_to admin_products_path, notice: "Featured updated."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    # FIXED: Changed :stock to :stock_quantity to match model
    def product_params
      params.require(:product).permit(
        :name,
        :description,
        :price,
        :stock_quantity,  # ← FIXED
        :sku,
        :category_id,
        :brand_id,        # ← ADDED
        :image_url,
        :status          # ← ADDED so admin can control visibility
      )
    end
  end
end