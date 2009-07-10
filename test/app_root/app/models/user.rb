class User < ActiveRecord::Base
  belongs_to :role
  has_many :contacts
end
