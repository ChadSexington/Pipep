class AddLimitToSizeForTorrent < ActiveRecord::Migration
  def change
    change_column :torrents, :size, :integer, :limit => 8  
  end
end
