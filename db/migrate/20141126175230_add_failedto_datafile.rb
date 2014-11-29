class AddFailedtoDatafile < ActiveRecord::Migration

  def change
    add_column :datafiles, :failed, :boolean, :default => false
  end

end
