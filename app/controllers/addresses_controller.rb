class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy, :set_default]

  def index
    @addresses = current_user.addresses.order(created_at: :desc)
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)

    ActiveRecord::Base.transaction do
      if @address.is_default?
        current_user.addresses.where.not(id: @address.id).update_all(is_default: false)
      end

      if @address.save
        respond_to do |format|
          format.html do
            if params[:return_to] == 'checkout'
              begin
                redirect_to new_checkout_path(selected_address_id: @address.id), notice: 'Address saved — returning to checkout.'
              rescue NameError
                redirect_to "/checkout?selected_address_id=#{@address.id}", notice: 'Address saved — returning to checkout.'
              end
            else
              redirect_to addresses_path, notice: 'Address added successfully.'
            end
          end

          format.json do
            render json: {
              success: true,
              address_id: @address.id,
              address_html: render_to_string(partial: 'addresses/address_item', locals: { address: @address }, formats: [:html])
            }, status: :created
          end
        end
      else
        respond_to do |format|
          format.html do
            flash.now[:alert] = "Please fix the errors below."
            render :new, status: :unprocessable_entity
          end
          format.json do
            render json: { success: false, errors: @address.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      if address_params[:is_default].present? && ActiveModel::Type::Boolean.new.cast(address_params[:is_default])
        current_user.addresses.where.not(id: @address.id).update_all(is_default: false)
      end

      if @address.update(address_params)
        respond_to do |format|
          format.html { redirect_to addresses_path, notice: 'Address updated successfully.' }
          format.json {
            render json: {
              success: true,
              address_id: @address.id,
              address_html: render_to_string(partial: 'addresses/address_item', locals: { address: @address }, formats: [:html])
            }
          }
        end
      else
        respond_to do |format|
          format.html do
            flash.now[:alert] = "Please fix the errors below."
            render :edit, status: :unprocessable_entity
          end
          format.json do
            render json: { success: false, errors: @address.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end

  def destroy
    id = @address.id
    if @address.destroy
      respond_to do |format|
        format.html { redirect_to addresses_path, notice: 'Address deleted successfully.' }
        format.json { render json: { success: true, address_id: id } }
      end
    else
      respond_to do |format|
        format.html { redirect_to addresses_path, alert: 'Could not delete address.' }
        format.json { render json: { success: false, errors: ['Could not delete address'] }, status: :unprocessable_entity }
      end
    end
  end

  def set_default
    ActiveRecord::Base.transaction do
      current_user.addresses.where.not(id: @address.id).update_all(is_default: false)
      @address.update!(is_default: true)
    end
    redirect_to addresses_path, notice: 'Default address updated.'
  rescue ActiveRecord::RecordInvalid
    redirect_to addresses_path, alert: 'Could not set default address.'
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
      :first_name, :last_name, :street_address,
      :city, :state, :postal_code,
      :phone, :address_type, :is_default
    )
  end
end