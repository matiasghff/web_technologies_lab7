class Appointment < ApplicationRecord
  belongs_to :pet
  belongs_to :vet
  has_many :treatments, dependent: :destroy

  enum :status, {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  validates :date, presence: true
  validates :reason, presence: true
  validates :pet, presence: true
  validates :vet, presence: true
  validates :status, presence: true

  validate :date_must_be_in_the_future
  validate :date_must_start_on_half_hour
  validate :vet_must_be_available

  scope :upcoming, -> { where("date > ?", Time.current).order(date: :asc) }
  scope :past, -> { where("date < ?", Time.current).order(date: :desc) }

  APPOINTMENT_DURATION = 1.hour

  private

  def date_must_be_in_the_future
    return if date.blank?

    if date <= Time.current
      errors.add(:date, "must be in the future")
    end
  end

  def date_must_start_on_half_hour
    return if date.blank?

    valid_minutes = [ 0, 30 ]

    unless valid_minutes.include?(date.min)
      errors.add(:date, "must start on the hour or half hour")
    end
  end

  def vet_must_be_available
    return if date.blank? || vet.blank?

    appointment_start = date
    appointment_end = appointment_start + APPOINTMENT_DURATION

    overlapping_appointment = Appointment
      .where(vet_id: vet_id)
      .where.not(id: id)
      .where("date < ? AND date + interval '1 hour' > ?", appointment_end, appointment_start)
      .exists?

    return unless overlapping_appointment

    errors.add(:date, "is already taken for this vet")
  end
end
