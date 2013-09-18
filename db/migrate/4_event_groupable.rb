class EventGroupable < ActiveRecord::Migration
  def up
    add_column :eventifier_events, :groupable_id,   :integer
    add_column :eventifier_events, :groupable_type, :string

    Eventifier::Event.reset_column_information
    Eventifier::Event.update_all(
      'groupable_id = eventable_id, groupable_type = eventable_type'
    )

    change_column :eventifier_events, :groupable_id,   :integer, :null => false
    change_column :eventifier_events, :groupable_type, :string,  :null => false
  end

  def down
    remove_column :eventifier_events, :groupable_id
    remove_column :eventifier_events, :groupable_type
  end
end
