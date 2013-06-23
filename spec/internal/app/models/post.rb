class Post < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  belongs_to :category
  has_many :subscriptions
  has_many :readers, :through => :subscriptions, :source => :user

  alias_method :user, :author
end
