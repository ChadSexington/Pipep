class RemoveFilesFromTorrent < ActiveRecord::Migration
  def change
    remove_column :torrents, :files, :text
  end
end
