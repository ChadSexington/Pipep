class ChangeLocationTypeToTextForDatafiles < ActiveRecord::Migration

  def change
    change_column :datafiles, :upstream_location, :text
    change_column :datafiles, :local_location, :text
  end

end
