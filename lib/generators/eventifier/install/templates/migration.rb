class EventifierSetup < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string  :eventable_type
      t.integer :eventable_id
      t.string  :verb
      t.text    :change_data

      t.timestamps
    end
    
    add_index :events, :user_id
    add_index :events, [:eventable_id, :eventable_type]

    create_table :notifications do |t|
      t.integer :event_id
      t.integer :user_id
      t.integer :parent_id

      t.timestamps
    end
    add_index :notifications, :event_id
    add_index :notifications, :user_id
    add_index :notifications, :parent_id
    
    add_column :users, :notifications_last_read_at, :datetime
  end

end
