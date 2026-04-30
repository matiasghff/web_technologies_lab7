class Vet < ApplicationRecord
  has_many :appointments, dependent: :destroy

  before_validation :normalize_email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :specialization, presence: true

  scope :by_specialization, ->(specialization) { where(specialization: specialization) }

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
