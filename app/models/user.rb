class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :members, dependent: :destroy
  has_many :households, through: :members
  has_many :owned_households, class_name: "Household", foreign_key: "user_id", dependent: :destroy
  has_many :chats, dependent: :destroy
  has_many :messages, through: :chats

  def avatar_url
  "https://i.pravatar.cc/150?img=#{((id - 1) % 70) + 1}&u=user-#{id}"
  end
end
