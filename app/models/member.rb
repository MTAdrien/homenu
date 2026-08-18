class Member < ApplicationRecord
  belongs_to :household
  belongs_to :user
end
