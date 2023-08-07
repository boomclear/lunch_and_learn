class User < ApplicationRecord
  validates :email, uniqueness: true
  validates :name, presence: true
  has_secure_password
  validates :password_digest, presence: true

  has_many :api_keys

end