class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]

  def index
    @appointments = Appointment.includes(:pet, :vet).order(date: :asc)
  end

  def show
    @treatments = @appointment.treatments.order(administered_at: :desc)
  end

  def new
    @appointment = Appointment.new(vet_id: params[:vet_id])

    build_calendar_context(params[:vet_id])
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.status = :scheduled

    if @appointment.save
      redirect_to @appointment, notice: "Appointment was successfully created."
    else
      build_calendar_context(@appointment.vet_id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to @appointment, notice: "Appointment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.destroy
    redirect_to appointments_path, notice: "Appointment was successfully deleted."
  end

  private

  def set_appointment
    @appointment = Appointment.includes(:pet, :vet, :treatments).find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:date, :reason, :status, :pet_id, :vet_id)
  end

  def build_calendar_context(vet_id)
    @selected_year = selected_year
    @selected_month = selected_month
    @selected_day = selected_day

    @calendar_date = Date.new(@selected_year, @selected_month, 1)
    @calendar_days = calendar_days_for(@calendar_date)

    @previous_month_date = @calendar_date.prev_month
    @next_month_date = @calendar_date.next_month

    @available_slots = available_slots_for_day(vet_id, @selected_day)
  end

  def selected_year
    params[:year].presence&.to_i || Date.current.year
  end

  def selected_month
    month = params[:month].presence&.to_i || Date.current.month
    month.clamp(1, 12)
  end

  def selected_day
    return nil if params[:day].blank?

    Date.new(selected_year, selected_month, params[:day].to_i)
  rescue Date::Error
    nil
  end

  def calendar_days_for(date)
    first_day = date.beginning_of_month
    last_day = date.end_of_month

    calendar_start = first_day.beginning_of_week(:monday)
    calendar_end = last_day.end_of_week(:monday)

    (calendar_start..calendar_end).to_a
  end

  def available_slots_for_day(vet_id, day)
    return [] if vet_id.blank? || day.blank?

    vet = Vet.find(vet_id)
    working_hours = 9..17

    taken_appointments = vet.appointments
      .where(date: day.beginning_of_day..day.end_of_day)
      .pluck(:date)

    slots = []

    working_hours.each do |hour|
      [ 0, 30 ].each do |minute|
        slot_start = day.to_time.change(hour: hour, min: minute, sec: 0)
        slot_end = slot_start + Appointment::APPOINTMENT_DURATION

        next if slot_start <= Time.current

        taken = taken_appointments.any? do |taken_date|
          taken_start = taken_date
          taken_end = taken_start + Appointment::APPOINTMENT_DURATION

          taken_start < slot_end && taken_end > slot_start
        end

        slots << {
          datetime: slot_start,
          available: !taken
        }
      end
    end

    slots
  end
end
