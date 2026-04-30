class TreatmentsController < ApplicationController
  before_action :set_appointment
  before_action :set_treatment, only: [:edit, :update, :destroy]

  def new
    @treatment = @appointment.treatments.build
  end

  def create
    @treatment = @appointment.treatments.build(treatment_params)

    if @treatment.save
      redirect_to @appointment, notice: "Treatment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @treatment.update(treatment_params)
      redirect_to @appointment, notice: "Treatment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @treatment.destroy
    redirect_to @appointment, notice: "Treatment was successfully deleted."
  end

  private

  def set_appointment
    @appointment = Appointment.includes(:pet, :vet).find(params[:appointment_id])
  end

  def set_treatment
    @treatment = @appointment.treatments.find(params[:id])
  end

  def treatment_params
    params.require(:treatment).permit(:name, :medication, :dosage, :administered_at, :notes)
  end
end