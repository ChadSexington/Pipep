class CreateTransmissions < ActiveRecord::Migration
  def change
    create_table :transmissions do |t|
      t.string :name
      t.string :url
      t.string :username
      t.text :password

      t.timestamps
    end
  end
end
