require 'mongoid'

class User
  include Mongoid::Document

  field :name, :type => String

  has_many :subscriptions
  validates :name, :presence => true, :uniqueness => true
end

class Subscription
  include Mongoid::Document

  belongs_to :user
  belongs_to :post
end

class Post
  include Mongoid::Document

  belongs_to :author, :class_name => "User"
  has_many :subscriptions

  def readers
    subscriptions.map &:user
  end

  alias_method :user, :author
end