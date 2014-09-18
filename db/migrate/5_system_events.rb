class SystemEvents < ActiveRecord::Migration
  def up
    add_column :eventifier_events, :system, :boolean
  end

  def down
    remove_column :eventifier_events, :system
  end
end
