class Closing
  DirectionToFinland = 1
  DirectionToRussia = 2


  attr_accessor :rawTime, :time, :crossing, :direction, :trainTime

  def closingTime
    trainTime - 10;
  end
  
  def time
    @time ||= begin
      hours = trainTime / 60
      minutes = trainTime.remainder(60)
      "%i:%02i" % [hours, minutes]
    end
  end

  def toRussia?
    direction == DirectionToRussia
  end

  def trainNumber
    position = crossing.closings.indexOfObject self
    780 + 1 + position
  end

  def directionCode
    if    direction == DirectionToFinland then "FIN"
    elsif direction == DirectionToRussia  then "RUS"
                                          else "N/A"
    end
  end

  def description
    NSString.stringWithFormat "Closing(%@, %@, %@)", crossing.localizedName, time, directionCode
  end

  def state
    crossing.state
  end

  def closest?
    self == crossing.currentClosing
  end

  def color
    crossing.color
  end
  
  def to_tracking_key
    "#{crossing.name}-#{time}"
  end


  # def self.closingWithCrossingName(crossingName, time:time, direction:direction)
  #   crossing = Crossing.getCrossingWithName crossingName
  #
  #   closing = Closing.new
  #   closing.crossing = crossing
  #   closing.time = time
  #   closing.trainTime = Device.minutes_from_military_string(time)
  #   closing.direction = direction
  #
  #   crossing.closings.addObject closing
  #
  #   closing
  # end
end
