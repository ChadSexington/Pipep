class AddLimitToSizeForDatafile < ActiveRecord::Migration
  def change
    change_column :datafiles, :size, :integer, :limit => 8
  end
end
