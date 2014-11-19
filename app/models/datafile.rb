class Datafile < ActiveRecord::Base

  belongs_to :download

  def name
    self.upstream_location.split('/').last
  end

  def complete
    self.percent_complete < 100
  end

end
