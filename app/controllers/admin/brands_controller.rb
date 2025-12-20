module Admin
  class BrandsController < AdminController
    before_action :set_brand, only: [:show, :edit, :update, :destroy]

    def index
      @brands = Brand.order(:name).page(params[:page]).per(20)
    end

    def show
    end

    def new
      @brand = Brand.new
    end

    def edit
    end

    def create
      @brand = Brand.new(brand_params)
      
      if @brand.save
        redirect_to admin_brands_path, notice: 'Brand was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @brand.update(brand_params)
        redirect_to admin_brands_path, notice: 'Brand was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @brand.products.any?
        redirect_to admin_brands_path, alert: 'Cannot delete brand with products.'
      else
        @brand.destroy
        redirect_to admin_brands_path, notice: 'Brand was successfully deleted.'
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
