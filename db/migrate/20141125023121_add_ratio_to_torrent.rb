class AddRatioToTorrent < ActiveRecord::Migration

  def change
    add_column :torrents, :ratio, :integer, :limit => 8
  end

end
