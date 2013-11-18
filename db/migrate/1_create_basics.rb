class CreateBasics< ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name
      t.decimal :balance
    end

    create_table :cards do |t|
      t.string :number
    end

    create_table :payments do |t|
      t.decimal :amount
      t.string  :note
    end
  end
end
