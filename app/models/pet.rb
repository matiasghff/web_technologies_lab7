class Pet < ApplicationRecord
  belongs_to :owner
  has_many :appointments, dependent: :destroy

  SPECIES = %w[dog cat rabbit bird reptile other].freeze

  before_save :capitalize_name

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }
  validates :date_of_birth, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :owner, presence: true
  validate :date_of_birth_cannot_be_in_the_future

  scope :by_species, ->(species) { where(species: species) }

  private

  def capitalize_name
    self.name = name.to_s.capitalize
  end

  def date_of_birth_cannot_be_in_the_future
    return if date_of_birth.blank?
    return unless date_of_birth > Date.current

    errors.add(:date_of_birth, "cannot be in the future")
  end
end
