class AddUserIdToTransmission < ActiveRecord::Migration
  def change
    add_column :transmissions, :user_id, :integer
  end
end
