class Download < ActiveRecord::Base
  
  require 'net/sftp'

  belongs_to :torrent
  has_many :datafiles
  before_save :check_percent_complete
  after_create :start
  after_destroy :remove_datafiles

  def complete?
    complete
  end
  
  def complete
    self.percent_complete >= 100.0
  end

  def start
    self.update_attributes(:started => true)
    # Generate datafiles if not already generated
    self.get_files
    # Set up sftp connection and other variables
    torrent = Torrent.find(self.torrent_id)
    dlog("Starting downloads for torrent #{torrent.name} with upstream id #{torrent.upstream_id}")
    local_download_dir = CONFIG[:download_dir]

    # Determine percentage of completion for each file
    num_files = self.datafiles.count
    percentage_of_each = 100.0 / num_files

    # Iterate through each file
    self.datafiles.each do |file|
      tree = file.local_location.split('/')
      local_download_dir.split('/').each {|dir| tree.delete(dir)}

      # If the file is not in a directory, just download it
      if tree.count == 1
        dlog("Creating transfer job for #{file.name}")
        file.transfer(torrent.transmission_id, percentage_of_each)
        next 
      end

      dlog("Checking directory creation needs for #{tree[-1]}")
      
      # Remove the file name from the array, so we just have directories  
      tree.delete_at(-1)

      # Create all necessary directories for this file
      directories = Array.new
      tree.each do |dir|
        if not directories.empty?
          dir = "#{directories.last}/#{dir}"
          directories << dir
        else
          directories << "#{local_download_dir}/#{dir}"
        end
      end
      directories.uniq!
      directories.each do |dir|
        if not Dir.exists?(dir)
          dlog("Creating directory #{dir}")
          Dir.mkdir(dir)
        end
      end
      
      dlog("Creating transfer job for #{file.name}")
      file.transfer(torrent.transmission_id, percentage_of_each)
    end
  end

  def get_files
    t = Torrent.find(self.torrent_id)
    file_list = t.get_file_list
    file_list.each do |file|
      if self.datafiles.where(:size => file["length"]).empty? and not (self.datafiles.map {|d| d.name}).include?(file["name"])
        name = file["name"]
        size = file["length"]
        percent_complete = 0.0
        upstream_location = Transmission.find(t.transmission_id).sftp_dir + "/" + name
        local_location = CONFIG[:download_dir] + "/" + name
        self.datafiles.create(:upstream_location => upstream_location,
                             :local_location => local_location,
                             :percent_complete => percent_complete,
                             :size => size)
      end
    end
  end

  def in_progress?
    self.started && !self.complete
  end

private

  def check_percent_complete
    if self.percent_complete > 99.8 && self.percent_complete < 100.0
      self.percent_complete = 100.0
    end
  end

  def dlog(message, level=:debug)
    log_string = "#{DateTime.now} | DLID: #{self.id} | "
    case level
    when :debug
      Rails.logger.debug(log_string + message)
    when :error
      Rails.logger.error(log_string + message)
    when :info
      Rails.logger.info(log_string + message)
    end
  end

  def remove_datafiles
    self.datafiles.destroy_all
  end
end
