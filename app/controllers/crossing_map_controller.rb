class CrossingMapController < UIViewController
 attr_accessor :mapView, :pinMapping, :timer, :lastRegion, :lastMapType, :crossingToShowOnNextAppearance

  def init
    super
    @lastMapType ||= MKMapTypeStandard
    # @lastRegion ||= MKCoordinateRegionMakeWithDistance Crossing.getCrossingWithName("Парголово").coordinate, 10000, 10000
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
      userLocationButton = UIBarButtonItem.alloc.initWithImage Device.image_named("bb-location"), style:UIBarButtonItemStyleBordered, 
          target:self, action:'showUserLocation'
      itemsForToolbar.insertObject userLocationButton, atIndex:0
    end
    self.toolbarItems = itemsForToolbar
  
    mapView.addAnnotations Model.crossings
  end
  
  def viewWillAppear(animated)
    super
    if crossingToShowOnNextAppearance
      showCrossing crossingToShowOnNextAppearance, animated:animated
      self.crossingToShowOnNextAppearance = nil
    elsif lastRegion
      mapView.setRegion lastRegion, animated:animated
    elsif Model.closestCrossing
      showCrossing Model.closestCrossing, animated:animated
    else
      showCrossing Crossing.getCrossingWithName("Парголово"), animated:animated
    end
  end
  
  def viewWillDisappear(animated)
    super  
    @lastMapType = mapView.mapType
    @lastRegion = mapView.region
  end
  
  ### map view
  
  def mapView(aMapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass Crossing
  
    crossing = annotation
  
    av = mapView.dequeueReusableAnnotationViewWithIdentifier MXDefaultCellID
    if !av
      av = MKAnnotationView.alloc.initWithAnnotation nil, reuseIdentifier:MXDefaultCellID
      av.canShowCallout = YES
      av.leftCalloutAccessoryView = UIImageView.alloc.initWithImage VX.stripeForCrossing(crossing)
      av.rightCalloutAccessoryView = UIButton.buttonWithType UIButtonTypeDetailDisclosure
    end
    av.annotation = crossing
    av.leftCalloutAccessoryView.image = VX.stripeForCrossing(crossing)
    av.image = pinMapping[crossing.color]
    av
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
      annotationView.image = newImage
      annotationView.leftCalloutAccessoryView.image = VX.stripeForCrossing(crossing)
    end
  end
  
  def showUserLocation
    userLocation = mapView.userLocation
    if userLocation.coordinate.latitude != 0 && userLocation.coordinate.latitude != 0
      mapView.setCenterCoordinate userLocation.coordinate, animated:YES
    end
  end
  
  def showCrossing(crossing, animated:animated)
    mapView.setRegion MKCoordinateRegionMakeWithDistance(crossing.coordinate, 10_000, 10_000), animated:animated
    mapView.selectAnnotation crossing, animated:animated    
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
