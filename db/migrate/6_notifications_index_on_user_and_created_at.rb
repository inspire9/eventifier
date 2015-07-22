class NotificationsIndexOnUserAndCreatedAt < ActiveRecord::Migration
  def up
    add_index :eventifier_notifications, [:user_id, :created_at],
      order: {created_at: :desc}
  end

  def down
    remove_index :eventifier_notifications, [:user_id, :created_at],
      order: {created_at: :desc}
  end
end
