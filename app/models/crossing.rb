class Crossing
  ### properties

  attr_accessor :name, :latitude, :longitude, :closings, :distance

  # - осталось более часа — зеленый
  # - осталось примерно 55/50/.../20 минут — желтый
  # - осталось примерно 15/10/5 минут — красный
  # - вероятно уже закрыт — красный
  # - Аллегро только что прошел — желтый
  def state
    currentTime = Time.minutes_since_midnight
    trainTime = currentClosing.trainTime

    return CrossingStateClear if currentTime > trainTime + PREVIOUS_TRAIN_LAG_TIME # next train will be tomorrow
    return CrosingsStateJustOpened if currentTime >= trainTime && currentTime <= trainTime + PREVIOUS_TRAIN_LAG_TIME
    return CrossingStateClosed if (currentTime >= trainTime - CLOSING_TIME && currentTime < trainTime)

    timeTillClosing = trainTime - CLOSING_TIME - currentTime

    return CrossingStateClear    if timeTillClosing > 60
    return CrossingStateSoon     if timeTillClosing > 20
    return CrossingStateVerySoon if timeTillClosing > 5
    return CrossingStateClosing  if timeTillClosing > 0

    return CrossingStateClosed
  end

  def color
    case state
    when CrossingStateClear      then UIColor.greenColor
    when CrossingStateSoon       then UIColor.greenColor
    when CrossingStateVerySoon   then UIColor.yellowColor
    when CrossingStateClosing    then UIColor.redColor
    when CrossingStateClosed     then UIColor.redColor
    when CrosingsStateJustOpened then UIColor.yellowColor
                                 else UIColor.greenColor
    end
  end

  def coordinate
    CLLocationCoordinate2DMake(latitude, longitude);
  end

  def title
    'crossing.title'.li(localizedName, distance)
  end
  
  def localizedName
    name.l
  end

  def subtitle
    case state
    when CrossingStateClear, CrossingStateSoon, CrossingStateVerySoon, CrossingStateClosing
      minutesTillClosing == 0 ? 'crossing.just_closed'.l : 'crossing.will be closed in X mins'.li(Format.minutes_as_text(minutesTillClosing))
    when CrossingStateClosed
      minutesTillOpening == 0 ? 'crossing.just_opened'.l : 'crossing.will be opened in X mins'.li(Format.minutes_as_text(minutesTillOpening))
    when CrosingsStateJustOpened
      minutesSinceOpening == 0 ? 'crossing.just_opened'.l : 'crossing.opened X min ago'.li(Format.minutes_as_text(minutesSinceOpening))
    else
      nil
    end
  end

  def nextClosing
    currentTime = Time.minutes_since_midnight;

    for closing in closings
      return closing if closing.trainTime >= currentTime
    end

    closings.firstObject
  end

  def previousClosing
    currentTime = Time.minutes_since_midnight

    for closing in closings.reverseObjectEnumerator
      return closing if closing.trainTime <= currentTime
    end

    closings.lastObject
  end

  def currentClosing
    currentTime = Time.minutes_since_midnight
    nextClosing = self.nextClosing;
    previousClosing = self.previousClosing;
    currentTime <= previousClosing.trainTime + PREVIOUS_TRAIN_LAG_TIME && currentTime > previousClosing.trainTime - 1 ? 
      previousClosing : nextClosing;
  end

  def minutesTillClosing
    # int nextClosingTime = self.nextClosing.closingTime;
    # int currentTime = Time.minutes_since_midnight
    # 
    # int result = nextClosingTime - currentTime;
    # if (result < 0)
    #   result = 24 * 60 + result;
    # 
    # return result;
    minutesTillOpening - CLOSING_TIME
  end

  def minutesTillOpening
    trainTime = nextClosing.trainTime
    currentTime = Time.minutes_since_midnight

    result = trainTime - currentTime
    result = 24 * 60 + result if result < 0
    result
  end

  def minutesSinceOpening
    previousTrainTime = previousClosing.trainTime
    currentTime = Time.minutes_since_midnight

    result = currentTime - previousTrainTime;
    result = 24 * 60 + result if (result < 0)
    result
  end

  def closest?
    self == Model.closestCrossing
  end

  def current?
    self == Model.currentCrossing
  end

  def description
    "<Crossing: #{name}, #{latitude}, #{longitude}, #{closings.count}>"
  end

  def index
    Model.crossings.indexOfObject self
  end

  def addClosingWithTime(time, direction:direction)
    closing = Closing.new
    closing.crossing = self
    closing.time = time
    closing.trainTime = time.minutes_from_hhmm
    closing.direction = direction
    closings.addObject closing
  end

  ### static

  def self.crossingWithName(name, latitude:lat, longitude:lng)
    crossing = new
    crossing.name = name;
    crossing.latitude = lat;
    crossing.longitude = lng;
    crossing.closings = NSMutableArray.arrayWithCapacity(8)
    crossing
  end

  def self.getCrossingWithName(name)
    for crossing in Model.crossings
      return crossing if crossing.name == name
    end

    Log.warn("[%@] crossing is not found for name = '%@'", __method__, name)

    nil
  end
end
