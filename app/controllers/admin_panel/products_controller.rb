module AdminPanel
  class ProductsController < AdminPanel::BaseController
    before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_featured]

    def index
      @products = Product.order(created_at: :desc)
    end

    def show
      # optional: you can add a show page later
      redirect_to admin_products_path
    end

    def new
      @product = Product.new
    end

    def edit; end

    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_products_path, notice: "Product created."
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

    # PATCH /admin/products/:id/toggle_featured
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

    # NOTE: adjust fields to your Product schema if some are different.
    def product_params
      params.require(:product).permit(
        :name,
        :description,
        :price,
        :stock,
        :sku,
        :category_id,
        :brand_id,
        :image_url
      )
    end
  end
end