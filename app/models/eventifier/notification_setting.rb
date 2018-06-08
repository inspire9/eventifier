class Eventifier::NotificationSetting < ActiveRecord::Base
  self.table_name = 'eventifier_notification_settings'

  belongs_to :user

  serialize :preferences, JSON

  validates :user,    :presence   => true
  validates :user_id, :uniqueness => true

  def self.for_user(user)
    where(:user_id => user.id).first || create!(:user => user)
  end
end
