class AddPercentCompleteToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :percent_complete, :float, :default => 0.0
  end
end
