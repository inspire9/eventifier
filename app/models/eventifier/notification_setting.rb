class Eventifier::NotificationSetting < ActiveRecord::Base
  belongs_to :user

  serialize :preferences, MultiJson

  attr_accessible :user

  validates :user,    :presence   => true
  validates :user_id, :uniqueness => true

  def self.for_user(user)
    where(:user_id => user.id).first || create!(:user => user)
  end
end
