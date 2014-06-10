class CrossingMapController < UIViewController
 attr_accessor :mapView, :pinMapping, :timer, :lastRegion, :lastMapType

  def initialize
    @lastMapType = MKMapTypeStandard
    @lastRegion = MKCoordinateRegionMakeWithDistance Crossing.getCrossingWithName("Парголово").coordinate, 10000, 10000
  end

  def loadView
    self.mapView = MKMapView.alloc.init
    mapView.showsUserLocation = CLLocationManager.locationServicesEnabled
    mapView.delegate = self
    mapView.mapType = lastMapType
    self.view = mapView
  end
  
  def viewDidLoad
    super
  
    self.title = "Карта"
  
    segmentedItems = NSArray.arrayWithObjects "Стандарт", "Спутник", "Гибрид", nil
    segmentedControl = UISegmentedControl.alloc.initWithItems segmentedItems
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl.selectedSegmentIndex = lastMapType
    segmentedControl.addTarget self, action:'changeMapType', forControlEvents:UIControlEventValueChanged
  
    navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle "Карта", style:UIBarButtonItemStylePlain, target:nil, action:nil
  
    itemsForToolbar = NSMutableArray.arrayWithObjects(
        UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
        UIBarButtonItem.alloc.initWithCustomView(segmentedControl),
        UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
        nil)
    if mapView.showsUserLocation
      userLocationIcon = MXImageFromFile("bb-location.png")
      userLocationButton = UIBarButtonItem.alloc.
        initWithImage userLocationIcon, style:UIBarButtonItemStyleBordered, target:self, action:'showUserLocation'
      itemsForToolbar.insertObject userLocationButton, atIndex:0
    end
    self.toolbarItems = itemsForToolbar
  
    mapView.addAnnotations model.crossings
  end
  
  def viewWillAppear(animated)
    super
    mapView.setRegion lastRegion, animated:NO
  end
  
  def viewWillDisappear(animated)
    super
  
    @lastMapType = mapView.mapType
    @lastRegion = mapView.region
  end
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    MXAutorotationPolicy(interfaceOrientation)
  end
  
  ### methods
  
  def showCrossing(aCrossing)
    mapView.setRegion MKCoordinateRegionMakeWithDistance(aCrossing.coordinate, 7000, 7000), animated:NO
    mapView.selectAnnotation aCrossing, animated:NO
  end
  
  ### map view
  
  def mapView(aMapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass Crossing.class
  
    crossing = annotation
  
    pin = mapView.dequeueReusableAnnotationViewWithIdentifier MXDefaultCellID
    if !pin
      pin = MKAnnotationView.alloc.initWithAnnotation nil, reuseIdentifier:MXDefaultCellID
      pin.canShowCallout = YES
      pin.rightCalloutAccessoryView = UIButton.buttonWithType UIButtonTypeDetailDisclosure
    end
    pin.annotation = crossing
    pin.image = pinMapping.objectForKey crossing.color
    pin
  end
  
  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)
    return unless view.annotation.isKindOfClass Crossing.class
  
    crossing = view.annotation
    scheduleController = CrossingScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    scheduleController.crossing = crossing
    navigationController.pushViewController scheduleController, animated:YES
  end
  
  ### callbacks
  
  def changeMapType(segment)
    mapView.mapType = segment.selectedSegmentIndex
  end
  
  def modelUpdated
    for crossing in mapView.annotations
      annotationView = mapView.viewForAnnotation crossing
      next unless crossing.isKindOfClass Crossing.class
      next unless annotationView
      newImage = pinMapping.objectForKey crossing.color
      annotationView.image = newImage if annotationView.image != newImage
    end
  end
  
  def showUserLocation
    userLocation = mapView.userLocation
    if userLocation.coordinate.latitude != 0 && userLocation.coordinate.latitude != 0
      mapView.setCenterCoordinate userLocation.coordinate, animated:YES
    end
  end
  
  ### helpers
  
  def pinMapping
    @pinMapping ||= NSDictionary.dictionaryWithObjectsAndKeys(
      MXImageFromFile("crossing-pin-green.png"), UIColor.greenColor,
      MXImageFromFile("crossing-pin-yellow.png"), UIColor.yellowColor,
      MXImageFromFile("crossing-pin-red.png"), UIColor.redColor,
      nil)
  end
end
