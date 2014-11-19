class AddDownloadIdToDatafiles < ActiveRecord::Migration
  def change
    add_column :datafiles, :download_id, :integer
  end
end
