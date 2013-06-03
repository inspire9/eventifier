class User < ActiveRecord::Base
  has_many :subscriptions
  validates :name, :presence => true, :uniqueness => true
end
