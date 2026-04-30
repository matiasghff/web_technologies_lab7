class VetsController < ApplicationController
  before_action :set_vet, only: [ :show, :edit, :update, :destroy ]

  def index
    @vets = Vet.order(:last_name, :first_name)
  end

  def show
    @appointments = @vet.appointments.includes(:pet).order(date: :asc)
  end

  def new
    @vet = Vet.new
  end

  def create
    @vet = Vet.new(vet_params)

    if @vet.save
      redirect_to @vet, notice: "Vet was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vet.update(vet_params)
      redirect_to @vet, notice: "Vet was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vet.destroy
    redirect_to vets_path, notice: "Vet was successfully deleted."
  end

  private

  def set_vet
    @vet = Vet.includes(appointments: :pet).find(params[:id])
  end

  def vet_params
    params.require(:vet).permit(:first_name, :last_name, :email, :phone, :specialization)
  end
end
