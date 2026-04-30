require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  def setup
    @owner = Owner.create!(
      first_name: "Owner",
      last_name: "Appointment",
      email: "owner_appointment_test@example.com",
      phone: "333333333",
      address: "Address"
    )

    @pet = Pet.create!(
      name: "Rocky",
      species: "dog",
      breed: "Labrador",
      date_of_birth: Date.current - 2.years,
      weight: 12,
      owner: @owner
    )

    @vet = Vet.create!(
      first_name: "Vet",
      last_name: "Doctor",
      email: "vet_appointment_test@example.com",
      phone: "444444444",
      specialization: "Surgery"
    )

    @appointment = Appointment.new(
      date: 1.day.from_now.change(hour: 10, min: 0, sec: 0),
      reason: "Checkup",
      pet: @pet,
      vet: @vet,
      status: :scheduled
    )
  end

  test "should save valid appointment" do
    assert @appointment.valid?
  end

  test "should require date" do
    @appointment.date = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:date], "can't be blank"
  end

  test "should require reason" do
    @appointment.reason = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:reason], "can't be blank"
  end

  test "should require pet" do
    @appointment.pet = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:pet], "can't be blank"
  end

  test "should require vet" do
    @appointment.vet = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:vet], "can't be blank"
  end

  test "should require status" do
    @appointment.status = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:status], "can't be blank"
  end

  test "should require date to start on the hour or half hour" do
    @appointment.date = 1.day.from_now.change(hour: 10, min: 15, sec: 0)

    assert_not @appointment.valid?
    assert_includes @appointment.errors[:date], "must start on the hour or half hour"
  end
end
