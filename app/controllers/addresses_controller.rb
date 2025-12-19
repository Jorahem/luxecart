class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy, :set_default]

  def index
    @addresses = current_user.addresses
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)
    if @address.save
      redirect_to addresses_path, notice: 'Address added successfully.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: 'Address updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: 'Address deleted successfully.'
  end

  def set_default
    @address.update(is_default: true)
    redirect_to addresses_path, notice: 'Default address updated.'
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:first_name, :last_name, :street_address, :apartment, :city, :state, :postal_code, :country, :phone, :address_type, :is_default)
  end
end