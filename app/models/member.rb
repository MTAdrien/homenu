class Member < ApplicationRecord
  belongs_to :household
  belongs_to :user

  ROLES = %w[Admin Member].freeze

  validates :first_name, presence: true
  validates :role, presence: true, inclusion: { in: ROLES }

  def avatar_url
  "https://i.pravatar.cc/150?img=#{((id - 1) % 70) + 1}&u=member-#{id}"
  end
end
