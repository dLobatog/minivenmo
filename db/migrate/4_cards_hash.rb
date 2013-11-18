class CardsHash < ActiveRecord::Migration
  def change
    add_column :cards, :number_hash, :string
  end
end
