class Payments< ActiveRecord::Migration
  def change
    add_column :payments, :actor_id,  :integer
    add_column :payments, :target_id, :integer
  end
end
