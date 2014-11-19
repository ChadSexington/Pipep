class CreateDatafiles < ActiveRecord::Migration
  def change
    create_table :datafiles do |t|
      t.string :upstream_location
      t.string :local_location
      t.float :percent_complete, :default => 0.0

      t.timestamps
    end
  end
end
