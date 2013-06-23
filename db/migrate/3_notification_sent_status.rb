class NotificationSentStatus < ActiveRecord::Migration
  def up
    add_column :notifications, :sent,      :boolean, :default => false
    add_column :notifications, :relations, :text,    :default => '[]'
    add_index  :notifications, :sent

    Eventifier::Notification.reset_column_information
    Eventifier::Notification.update_all :sent => true
  end

  def down
    remove_column :notifications, :sent
    remove_column :notifications, :relations
  end
end
