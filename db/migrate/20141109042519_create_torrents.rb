class CreateTorrents < ActiveRecord::Migration
  def change
    create_table :torrents do |t|
      t.datetime :added_date
      t.text :files
      t.integer :upstream_id
      t.boolean :finished
      t.string :name
      t.integer :percent_complete
      t.integer :d_rate
      t.integer :u_rate
      t.integer :size
      t.integer :transmission_id

      t.timestamps
    end
  end
end
