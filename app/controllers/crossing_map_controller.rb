class CrossingMapController < UIViewController
 attr_accessor :mapView, :pinMapping, :timer, :lastRegion, :lastMapType

  def init
    super
    @lastMapType ||= MKMapTypeStandard
    @lastRegion ||= MKCoordinateRegionMakeWithDistance Crossing.getCrossingWithName("Парголово").coordinate, 10000, 10000
    self
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
  
    self.title = 'map.title'.l

    segmentedControl = UISegmentedControl.alloc.initWithItems ['map.standard'.l, 'map.hybrid'.l, 'map.satellite'.l]
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl.selectedSegmentIndex = lastMapType
    segmentedControl.addTarget self, action:'changeMapType:', forControlEvents:UIControlEventValueChanged
  
    navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle "Карта", style:UIBarButtonItemStylePlain, target:nil, action:nil
  
    itemsForToolbar = [
        UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
        UIBarButtonItem.alloc.initWithCustomView(segmentedControl),
        UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
      ]
    if mapView.showsUserLocation
      userLocationIcon = Device.image_named("bb-location")
      userLocationButton = UIBarButtonItem.alloc.initWithImage userLocationIcon, 
        style:UIBarButtonItemStyleBordered, target:self, action:'showUserLocation'
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
  
  ### methods
  
  def showCrossing(aCrossing)
    view # ensure that it's laoded
    mapView.setRegion MKCoordinateRegionMakeWithDistance(aCrossing.coordinate, 7000, 7000), animated:NO
    mapView.selectAnnotation aCrossing, animated:NO
  end
  
  ### map view
  
  def mapView(aMapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass Crossing
  
    crossing = annotation
  
    pin = mapView.dequeueReusableAnnotationViewWithIdentifier MXDefaultCellID
    if !pin
      pin = MKAnnotationView.alloc.initWithAnnotation nil, reuseIdentifier:MXDefaultCellID
      pin.canShowCallout = YES
      pin.rightCalloutAccessoryView = UIButton.buttonWithType UIButtonTypeDetailDisclosure
    end
    pin.annotation = crossing
    pin.image = pinMapping[crossing.color]
    pin
  end
  
  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)
    return unless view.annotation.isKindOfClass Crossing
  
    crossing = view.annotation
    scheduleController = CrossingScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    scheduleController.crossing = crossing
    navigationController.pushViewController scheduleController, animated:YES
  end
  
  ### callbacks
  
  def changeMapType(segment)
    mapView.mapType = case segment.selectedSegmentIndex
      when 0 then MKMapTypeStandard
      when 1 then MKMapTypeHybrid
      when 2 then MKMapTypeSatellite
    end
  end
  
  def modelUpdated
    for crossing in mapView.annotations
      annotationView = mapView.viewForAnnotation crossing
      next unless Crossing === crossing
      next unless annotationView
      newImage = pinMapping[crossing.color]
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
    @pinMapping ||= {
      :green.color  => Device.image_named("crossing-pin-green"),
      :yellow.color => Device.image_named("crossing-pin-yellow"),
      :red.color    => Device.image_named("crossing-pin-red")
    }
  end
end
