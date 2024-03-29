class ModelManager
  ### properties

  attr_accessor :crossings, :closings, :closestCrossing, :selectedCrossing
  attr_accessor :currentCrossingChangeTime

  def defaultCrossing
    Crossing.getCrossingWithName "Удельная"
  end

  def closestCrossing
    return nil unless App.locationAvailable?
    @closestCrossing ||= crossingClosestTo App.locationManager.location, :active
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
    @currentCrossingChangeTime = Time.now
    Device.notify ATModelUpdated
  end
  
  def reverseCrossings
    @reverseCrossings ||= crossings.reverse
  end
  
  def activeCrossings
    @activeCrossings ||= crossings.select { |crossing| crossing.hasSchedule? } - [Crossing.getCrossingWithName('Поклонногорская')]
  end

  def realClosestCrossing
    crossingClosestTo App.locationManager.location, :all
  end

  ### methods

  def crossingClosestTo(location, collection)
    source = collection == :active ? activeCrossings : crossings
    source.minimumObject -> (crossing) do 
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
    s = Time.now
    @crossings = NSMutableArray.arrayWithCapacity 30

    dataPath = NSBundle.mainBundle.pathForResource("data/schedule", ofType:"csv")
    dataString = NSString.stringWithContentsOfFile(dataPath, encoding:NSUTF8StringEncoding, error:NULL)
    dataRows = dataString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet).reject(&:empty?)

    dataRows.each do |dataRow| 
      components = dataRow.componentsSeparatedByString ","
      record_name = components.objectAtIndex 0

      next if record_name == 'Санкт-Петербург' || record_name == 'Выборг'

      crossing = Crossing.new
      crossing.name = record_name
      crossing.distance = components.objectAtIndex(1).intValue
      crossing.latitude = components.objectAtIndex(2).floatValue
      crossing.longitude = components.objectAtIndex(3).floatValue
      
      if components.objectAtIndex(4) != ''
        crossing.closings = NSMutableArray.arrayWithCapacity(8)

        lastDatumIndex = 3
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 1), direction:Closing::DirectionToFinland
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 5), direction:Closing::DirectionToRussia
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 2), direction:Closing::DirectionToFinland
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 6), direction:Closing::DirectionToRussia
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 3), direction:Closing::DirectionToFinland
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 7), direction:Closing::DirectionToRussia
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 4), direction:Closing::DirectionToFinland
        crossing.addClosingWithTime components.objectAtIndex(lastDatumIndex + 8), direction:Closing::DirectionToRussia
      else
        crossing.closings = []
      end
      
      @crossings.addObject crossing
    end

    @closings = NSMutableArray.arrayWithCapacity crossings.count * 8
    for crossing in crossings
      @closings.addObjectsFromArray crossing.closings
    end
  end
end
