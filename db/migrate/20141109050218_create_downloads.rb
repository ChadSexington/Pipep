class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.integer :torrent_id
      t.boolean :complete, :default => false
      t.boolean :started, :default => false
      t.string :location

      t.timestamps
    end
  end
end
