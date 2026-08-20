class Member < ApplicationRecord
  belongs_to :household
  belongs_to :user

  ROLES = %w[Admin Member].freeze

  validates :first_name, presence: true
  validates :role, presence: true, inclusion: { in: ROLES }
end
