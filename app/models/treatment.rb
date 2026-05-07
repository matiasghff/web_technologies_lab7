class Treatment < ApplicationRecord
  belongs_to :appointment

  has_rich_text :clinical_notes

  validates :name, presence: true
  validates :administered_at, presence: true
  validates :appointment, presence: true
end
