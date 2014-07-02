class Closing
  ### properties

  attr_accessor :time, :crossing, :direction, :trainTime

  def closingTime
    trainTime - 10;
  end

  def toRussia?
    direction == ClosingDirectionToRussia;
  end

  def trainNumber
    position = crossing.closings.indexOfObject self
    150 + 1 + position
  end

  def directionCode
    if (direction == ClosingDirectionToFinland) then "FIN"
    elsif direction == ClosingDirectionToRussia then "RUS"
                                                else "N/A"
    end
  end

  def description
    NSString.stringWithFormat "Closing(%@, %@, %@)", crossing.name, time, directionCode
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

  ### static

  def self.closingWithCrossingName(crossingName, time:time, direction:direction)
    crossing = Crossing.getCrossingWithName crossingName

    closing = Closing.new
    closing.crossing = crossing;
    closing.time = time;
    closing.trainTime = Helper.parseStringAsHHMM(time)
    closing.direction = direction

    crossing.closings.addObject closing

    return closing;
  end
end
