class Transmission < ActiveRecord::Base

  has_many :torrents

  before_save :verify_connection

  belongs_to :user

  def get_torrent(id)
    trans = get_connection
    response = trans.find(id)
  end

  def torrent_list
    trans = get_connection
    trans.all
  end
  
  # Sync torrents with backend server
  # Returns true or false, depending on whether changes were made
  def refresh_local_torrents
    changed = false
    list = self.torrent_list
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
            Rails.logger.info("Skipping torrent #{name} because download already exists")
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

  def get_connection
    TransmissionApi::Client.new(
      :username => self.username,
      :password => self.password,
      :url      => self.url
    )
  end

end
