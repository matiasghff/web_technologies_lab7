class Pet < ApplicationRecord
  belongs_to :owner
  has_many :appointments, dependent: :destroy
  has_one_attached :photo

  SPECIES = %w[dog cat rabbit bird reptile other].freeze
  ALLOWED_PHOTO_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_PHOTO_SIZE = 5.megabytes

  before_save :capitalize_name

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }
  validates :date_of_birth, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :owner, presence: true

  validate :date_of_birth_cannot_be_in_the_future
  validate :photo_must_be_valid

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

  def photo_must_be_valid
    return unless photo.attached?

    unless ALLOWED_PHOTO_TYPES.include?(photo.blob.content_type)
      errors.add(:photo, "must be a JPEG, PNG, or WebP image")
    end

    return unless photo.blob.byte_size > MAX_PHOTO_SIZE

    errors.add(:photo, "must be 5 MB or smaller")
  end
end
