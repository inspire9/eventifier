class EventifierNotificationSettings < ActiveRecord::Migration
  def change
    create_table :eventifier_notification_settings do |t|
      t.integer :user_id,     :null => false
      t.text    :preferences, :null => false, :default => '{}'
      t.timestamps
    end

    add_index :eventifier_notification_settings, :user_id, :unique => true
  end
end
