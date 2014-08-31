ClosingDirectionToFinland = 1
ClosingDirectionToRussia = 2

CrossingStateClear = 0
CrossingStateSoon = 1
CrossingStateVerySoon = 2
CrossingStateClosing = 3
CrossingStateClosed = 4
CrosingsStateJustOpened = 5

StateColorGreen = 0
StateColorYellow = 1
StateColorRed = 2

PREVIOUS_TRAIN_LAG_TIME = 5
CLOSING_TIME = 10

class ModelManager
  ### properties

  attr_accessor :crossings, :closings, :closestCrossing, :selectedCrossing

  def defaultCrossing
    Crossing.getCrossingWithName "Удельная"
  end

  def closestCrossing
    unless @closestCrossing
      if location = CLLocationManager.new.location
        @closestCrossing = crossingClosestTo location
      end
    end
    @closestCrossing
  end

  def selectedCrossing
    crossingName = NSUserDefaults.standardUserDefaults.objectForKey "selectedCrossing"
    crossingName ? Crossing.getCrossingWithName(crossingName) : nil
  end

  def selectedCrossing=(crossing)
    NSUserDefaults.standardUserDefaults.setObject crossing ? crossing.name : nil, forKey:"selectedCrossing"
  end

  def currentCrossing
    selectedCrossing || closestCrossing || defaultCrossing
  end

  def currentCrossing=(crossing)
    self.selectedCrossing = crossing.closest? ? nil : crossing
  end

  ### methods

  def crossingClosestTo(location)
    crossings.minimumObject -> (crossing) do 
      currentLocation = CLLocation.alloc.initWithLatitude crossing.latitude, longitude:crossing.longitude
      currentLocation.distanceFromLocation location
    end
  end

  ### initialization

  def init
    super
    loadFile
    self
  end

  def loadFile
    @crossings = NSMutableArray.arrayWithCapacity 30

    dataPath = NSBundle.mainBundle.pathForResource("data/schedule", ofType:"csv")
    dataString = NSString.stringWithContentsOfFile(dataPath, encoding:NSUTF8StringEncoding, error:NULL)
    dataRows = dataString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet).reject(&:empty?)

    dataRows.each do |dataRow| 
      components = dataRow.componentsSeparatedByString ","

      crossing = Crossing.new
      crossing.name = components.objectAtIndex 0
      crossing.distance = components.objectAtIndex(1).intValue
      crossing.latitude = components.objectAtIndex(2).floatValue
      crossing.longitude = components.objectAtIndex(3).floatValue
      crossing.closings = NSMutableArray.arrayWithCapacity(8)

      lastDatumIndex = 3
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 1), direction:ClosingDirectionToFinland
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 2), direction:ClosingDirectionToRussia
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 3), direction:ClosingDirectionToFinland
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 4), direction:ClosingDirectionToRussia
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 5), direction:ClosingDirectionToFinland
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 6), direction:ClosingDirectionToRussia
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 7), direction:ClosingDirectionToFinland
      crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 8), direction:ClosingDirectionToRussia

      @crossings.addObject crossing
    end

    @closings = NSMutableArray.arrayWithCapacity crossings.count * 8
    for crossing in crossings
      @closings.addObjectsFromArray crossing.closings
    end
  end
end
