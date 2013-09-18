class NotificationSentStatus < ActiveRecord::Migration
  def up
    add_column :eventifier_notifications, :sent,      :boolean, default: false
    add_column :eventifier_notifications, :relations, :text,    default: '[]'
    add_index  :eventifier_notifications, :sent

    Eventifier::Notification.reset_column_information
    Eventifier::Notification.update_all :sent => true
  end

  def down
    remove_column :eventifier_notifications, :sent
    remove_column :eventifier_notifications, :relations
  end
end
