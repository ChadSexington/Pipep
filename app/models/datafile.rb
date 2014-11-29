class Datafile < ActiveRecord::Base

  belongs_to :download

  def name
    self.upstream_location.split('/').last
  end

  def complete
    self.percent_complete < 100
  end

  # Transfer this single file to the local host
  # Params:
  #   transmission_id: ID of the transmission host(int)
  #   percentage_of_total: percent to add to download's total when transfer is complete(float)
  def transfer(transmission_id, percentage_of_total)
    Rails.logger.debug("TRANSFER: Starting transfer of file #{self.upstream_location.split('/').last}")
    transmission = Transmission.find(transmission_id)
    begin
      sftp = Net::SFTP.start(transmission.sftp_host, transmission.sftp_username, :password => transmission.sftp_password)
      sftp.download!(self.upstream_location, self.local_location, :recursive => false) do |event, downloader, *args|
        case event
  #      when :open
  #      when :get
  #        size_written = args[2].length
  #        percent = size_written / self.size
  #        self.update_attributes(:percent_complete => percent)
        #when :close
        when :finish
          Rails.logger.debug("TRANSFER: Completed transfer of file #{self.upstream_location.split('/').last}")
          self.update_attributes(:percent_complete => 100)
        end
      end
    rescue => e
      Rails.logger.error("TRANSFER: FAILURE: Datafile ##{self.id} failed with #{e.message}")
      Rails.logger.error("TRANSFER: #{e.backtrace}")
      self.update_attributes(:failed => true)
      return false
    end

    download = Download.find(self.download_id)
    download.update_attributes(:percent_complete => (download.percent_complete + percentage_of_total)) 
    Rails.logger.debug("TRANSFER: Completed transfer of file #{self.upstream_location.split('/').last}")
  end
  handle_asynchronously :transfer, :queue => 'downloads', :run_at => Proc.new { DateTime.now }

end
