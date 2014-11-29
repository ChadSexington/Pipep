class TorrentsController < ApplicationController

  before_action :check_auth

  def index
    @torrents = Torrent.all
    @downloading = @torrents.where.not(:percent_complete => 1.0)
    @seeding = @torrents.where(:percent_complete => 1.0)
    @transferring = @torrents.select {|t| t.download and t.download.in_progress?}
    @completed = @torrents.select {|t| t.finished and t.download and t.download.complete}
  end

  def refresh
    t = Transmission.where(:user_id => session[:user]).first
    if t.refresh_local_torrents
      @torrents = Torrent.all
      @downloading = @torrents.where.not(:percent_complete => 1.0)
      @seeding = @torrents.where(:percent_complete => 1.0)
      @transferring = @torrents.select {|t| t.download and t.download.in_progress?}
      @completed = @torrents.select {|t| t.finished and t.download and t.download.complete}
      respond_to do |format|
        format.json { render :json => {
            :changed => "true", 
            :all => render_to_string(:partial => 'torrent_list.html.erb', :locals => {:torrents => @torrents }),
            :all_count => @torrents.count,
            :transferring => render_to_string(:partial => 'torrent_list.html.erb', :locals => {:torrents => @transferring }),
            :transferring_count => @transferring.count,
            :downloading => render_to_string(:partial => 'torrent_list.html.erb', :locals => {:torrents => @downloading }),
            :downloading_count => @downloading.count,
            :seeding => render_to_string(:partial => 'torrent_list.html.erb', :locals => {:torrents => @seeding }),
            :seeding_count => @seeding.count,
            :completed => render_to_string(:partial => 'torrent_list.html.erb', :locals => {:torrents => @completed }),
            :completed_count => @completed.count
          } 
        }
      end
    else
      respond_to do |format|
        format.json { render :json => {:changed => "false"} }
      end
    end
  end

  def new
  end

  def create
    @torrent = Torrent.new(:url => torrent_params[:url], :transmission_id => 1)
    Rails.logger.info @torrent.inspect
    if @torrent.save
      respond_to do |format|
        format.json { render :json => {:created => "true"} }
      end
    else
      respond_to do |format|
        format.json { render :json => {:created => "false"} }
      end
    end
  end

  def destroy
    @torrent = Torrent.find(params[:id])
    if @torrent.destroy
      respond_to do |format|
        format.json { render :json => {:deleted => "true"} }
      end
    else
      respond_to do |format|
        format.json { render :json => {:deleted => "false"} }
      end
    end
  end

private

  def check_auth
    session[:user]
  end

  def torrent_params
    params.permit(:url)
  end

end
