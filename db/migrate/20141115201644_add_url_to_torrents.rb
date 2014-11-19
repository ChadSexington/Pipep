class AddUrlToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :url, :text
  end
end
