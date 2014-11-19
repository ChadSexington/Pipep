class AddSftpDetailsToTransmission < ActiveRecord::Migration
  def change
    add_column :transmissions, :sftp_username, :string
    add_column :transmissions, :sftp_password, :string
    add_column :transmissions, :sftp_host, :string
  end
end
