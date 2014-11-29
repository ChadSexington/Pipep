class Transmission < ActiveRecord::Base

  has_many :torrents

  before_save :verify_connection

  belongs_to :user

  def get_torrent(id)
    trans = get_connection
    if trans
      response = trans.find(id)
    else
      Rails.logger.error("Could not get torrent because a connection could not be established")
      return false
    end
    response
  end

  def torrent_list
    trans = get_connection
    if trans
      return trans.all
    else
      Rails.logger.error("Could not get torrent list because a connection could not be established")
      return false 
    end
  end
  
  # Sync torrents with backend server
  # Returns true or false, depending on whether changes were made
  def refresh_local_torrents
    changed = false
    list = self.torrent_list
    if list == false
      return false
    end
    local_list = self.torrents
    # Add torrents if the backend server has them and we don't
    list.each do |upstream_torrent|
      if local_list.where(:upstream_id => upstream_torrent["id"]).empty?
        t = self.torrents.create(:added_date => Time.at(upstream_torrent["addedDate"]).to_datetime,
                               :upstream_id => upstream_torrent["id"],
                               :finished => upstream_torrent["isFinished"],
                               :name => upstream_torrent["name"],
                               :percent_complete => upstream_torrent["percentDone"],
                               :u_rate => upstream_torrent["rateUpload"],
                               :d_rate => upstream_torrent["rateDownload"],
                               :size => upstream_torrent["totalSize"],
                               :ratio => upstream_torrent["uploadRatio"],
                               :url => "upstream"
                              )
        changed = true
      else
        local_torrent = local_list.where(:upstream_id => upstream_torrent["id"]).first
        if local_torrent.to_upstream != upstream_torrent
          local_torrent.update_from_upstream(upstream_torrent)
          changed = true
        end
      end
    end

    # Remove torrents if we have it and the backend server does not.
    local_list.each do |local_torrent|
      if list.select{|t| t["id"] == local_torrent.upstream_id}.empty?
        local_torrent.destroy
        changed = true
      end
    end
    changed
  end

  def refresher
    loop {
      self.refresh_local_torrents
      downloaded_torrents = self.torrents.where(:percent_complete => 1.0)
      downloaded_torrents.each do |t|
        if t.download
          if t.download.complete || t.download.started
            next
          end
          # Need to have a way to check to see if a job is running for the download
        end
        Rails.logger.info("Creating download for torrent #{t.name}...")
        t.create_download()
      end
      sleep 360
    }
  end
  handle_asynchronously :refresher, :queue => 'refresher'

  def verify_connection
    trans = get_connection
    response = trans.http_post({"method" => "port-test"})
    response.parsed_response["result"] == "success"
  end

  # Parameters:
  #   fields => Should be an array of strings
  def get_connection(fields = nil)
    # If some jackass sent us anything but an array, fuckem and make it an array
    if fields and fields.class != Array
      string = fields
      fields = Array.new
      fields << string
    end
    begin
      if fields
        connection = TransmissionApi::Client.new(
              :username => self.username,
              :password => self.password,
              :url      => self.url,
              :fields   => fields + TransmissionApi::Client::TORRENT_FIELDS
            )
      else
        connection = TransmissionApi::Client.new(
              :username => self.username,
              :password => self.password,
              :url      => self.url
            )
      end
    rescue ENETUNREACH => e
      Rails.logger.error("Could not create connection to transmission backend: #{e.message}")
      return false
    rescue => e
      Rails.logger.error("Could not create connection to transmission backend: #{e.message}")
      return false
    end
    connection
  end

end
