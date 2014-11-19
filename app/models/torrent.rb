class Torrent < ActiveRecord::Base

  belongs_to :transmission
  has_one :download

  before_create :add_torrent_backend

  validates_presence_of :url

  def finished?
    self.finished
  end

  def get_file_list
    transmission = Transmission.find(self.transmission_id)
    torrent = transmission.get_torrent(self.upstream_id)
    torrent["files"]
  end

  def refresh(save = true)
    transmission = Transmission.find(self.transmission_id)
    torrent = transmission.get_torrent(self.upstream_id)
    torrent.delete("files")
    current = {"addedDate" => self.added_date.to_i, 
               "id"=> self.upstream_id, 
               "isFinished" => self.finished?, 
               "name" => self.name, 
               "percentDone"=> self.percent_complete, 
               "rateDownload" => self.d_rate, 
               "rateUpload" => self.u_rate, 
               "totalSize" => self.size
              }
    if current == torrent
      return true
    else
      if save
        if self.update_attributes(:added_date => Time.at(torrent["addedDate"]).to_datetime,
                               :upstream_id => torrent["id"],
                               :finished => torrent["isFinished"],
                               :name => torrent["name"],
                               :percent_complete => torrent["percentDone"],
                               :u_rate => torrent["rateUpload"],
                               :d_rate => torrent["rateDownload"],
                               :size => torrent["totalSize"]
                              )
          return true
        else
          return false
        end
      else
        self.assign_attributes(:added_date => Time.at(torrent["addedDate"]).to_datetime,
                               :upstream_id => torrent["id"],
                               :finished => torrent["isFinished"],
                               :name => torrent["name"],
                               :percent_complete => torrent["percentDone"],
                               :u_rate => torrent["rateUpload"],
                               :d_rate => torrent["rateDownload"],
                               :size => torrent["totalSize"]
                              )
        return true
      end
    end
  end

  def to_upstream
    {"addedDate" => self.added_date.to_i,
     "id" => self.upstream_id,
     "isFinished" => self.finished,
     "name" => self.name,
     "percentDone" => self.percent_complete,
     "rateUpload" => self.u_rate,
     "rateDownload" => self.d_rate,
     "totalSize" => self.size
    }
  end

  def update_from_upstream(torrent)
    self.update_attributes(:added_date => Time.at(torrent["addedDate"]).to_datetime,
                         :upstream_id => torrent["id"],
                         :finished => torrent["isFinished"],
                         :name => torrent["name"],
                         :percent_complete => torrent["percentDone"],
                         :u_rate => torrent["rateUpload"],
                         :d_rate => torrent["rateDownload"],
                         :size => torrent["totalSize"]
                        ) 
  end

private
  
  def add_torrent_backend
    # Don't do anything if this torrent wasn't added through the application
    if self.url == "upstream"
      return true
    end
    transmission = Transmission.find(self.transmission_id)
    backend = transmission.get_connection
    begin
      resp = backend.create(self.url)
      # example success response:
      # {"hashString"=>"fcffab062c3ea03d8212f200085a54f28c123d55", "id"=>176, "name"=>"Studio+Killers+-+Ode+to+the+bouncer+320kbps+2011"}
      self.upstream_id = resp["id"]
      self.name = resp["name"]   
    rescue TransmissionApi::Exception => e
      Rails.logger.error "Could not create torrent due to: #{e.message}"
      Rails.logger.error e.backtrace
      return false
    end
    self.refresh(false)
  end

end
