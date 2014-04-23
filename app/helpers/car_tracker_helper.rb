module CarTrackerHelper

  def self.set_positions positions
    @positions = positions
  end

  def self.get_positions
    @positions ||= Hash.new
  end

end
