module Admin
  class BrandsController < AdminController
    before_action :set_brand, only: [:show, :edit, :update, :destroy]

    def index
      @brands = Brand.order(name: :asc).page(params[:page]).per(20)
    end

    def show
      @products = @brand.products.page(params[:page]).per(10)
    end

    def new
      @brand = Brand.new
    end

    def create
      @brand = Brand.new(brand_params)
      
      if @brand.save
        redirect_to admin_brand_path(@brand), notice: 'Brand was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @brand.update(brand_params)
        redirect_to admin_brand_path(@brand), notice: 'Brand was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @brand.destroy
        redirect_to admin_brands_url, notice: 'Brand was successfully deleted.'
      else
        redirect_to admin_brands_url, alert: 'Cannot delete brand with products.'
      end
    end

    private

    def set_brand
      @brand = Brand.friendly.find(params[:id])
    end

    def brand_params
      params.require(:brand).permit(:name, :description, :website, :active)
    end
  end
end
