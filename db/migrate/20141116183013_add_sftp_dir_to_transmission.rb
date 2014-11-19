class AddSftpDirToTransmission < ActiveRecord::Migration
  def change
    add_column :transmissions, :sftp_dir, :string
  end
end
