class Household < ApplicationRecord
  belongs_to :user

  has_many :members, dependent: :destroy
  has_many :users, through: :members
  has_many :fridge_items, dependent: :destroy
  has_many :chats, dependent: :destroy
  has_many :recipes, dependent: :destroy
end
