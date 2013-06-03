ActiveRecord::Schema.define do
  create_table :ghosts, :force => true do |t|
    t.string  :ghost_class
    t.integer :ghost_id
    t.text    :data_hash

    t.timestamps
  end

  create_table :users, :force => true do |t|
    t.column :name, :string
    t.column :email, :string
  end

  create_table :posts, :force => true do |t|
    t.column :title, :string
    t.column :author_id, :integer
    t.column :body, :text
  end

  create_table :subscriptions, :force => true do |t|
    t.column :user_id, :integer
    t.column :post_id, :integer
  end
end
