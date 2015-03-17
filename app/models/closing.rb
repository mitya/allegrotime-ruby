class Closing
  DirectionToFinland = 1
  DirectionToRussia = 2


  attr_accessor :time, :crossing, :direction, :trainTime

  def closingTime
    trainTime - 10;
  end

  def toRussia?
    direction == DirectionToRussia
  end

  def trainNumber
    position = crossing.closings.indexOfObject self
    150 + 1 + position
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
  
  def key
    "#{crossing.distance}-#{time}"
  end


  def self.closingWithCrossingName(crossingName, time:time, direction:direction)
    crossing = Crossing.getCrossingWithName crossingName

    closing = Closing.new
    closing.crossing = crossing
    closing.time = time
    closing.trainTime = time.minutes_from_hhmm
    closing.direction = direction

    crossing.closings.addObject closing

    closing
  end
end
