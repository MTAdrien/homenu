class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :members, dependent: :destroy
  has_many :households, through: :members
  has_many :created_households, class_name: "Household", foreign_key: "user_id", dependent: :destroy
  has_many :chats, dependent: :nullify
end
