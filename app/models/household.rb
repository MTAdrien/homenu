class Household < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: :user_id
  has_many :members, dependent: :destroy
  has_many :users, through: :members
  has_many :fridge_items, dependent: :destroy
  has_many :chats, dependent: :destroy
  # has_many :recipes, dependent: :destroy

  validates :name, presence: true

  def members_count
    users.count
  end
end
