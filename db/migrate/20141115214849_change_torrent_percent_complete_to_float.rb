class ChangeTorrentPercentCompleteToFloat < ActiveRecord::Migration
  def change
    change_column :torrents, :percent_complete, :float
  end
end
