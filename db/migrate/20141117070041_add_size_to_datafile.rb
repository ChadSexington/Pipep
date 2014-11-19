class AddSizeToDatafile < ActiveRecord::Migration
  def change
    add_column :datafiles, :size, :integer
  end
end
