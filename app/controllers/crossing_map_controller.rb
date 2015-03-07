class CrossingMapController < UIViewController
 attr_accessor :mapView, :pinMapping, :timer, :lastRegion, :lastMapType, :crossingToShowOnNextAppearance

  def init
    super
    self.title = 'map.title'.l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("map.tab".l, image:Device.image_named("ti-map"), selectedImage:Device.image_named("ti-map-filled"))    
    self.lastMapType ||= MKMapTypeHybrid
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
    
    if lastRegion
      mapView.setRegion lastRegion, animated:animated
    elsif Model.closestCrossing
      showCrossing Model.closestCrossing, animated:animated
    else
      showCrossing Crossing.getCrossingWithName("Парголово"), animated:animated
    end
  end
  
  def viewDidAppear(animated)
    super
    if crossingToShowOnNextAppearance
      showCrossing crossingToShowOnNextAppearance, animated:YES
      self.crossingToShowOnNextAppearance = nil
    end    
  end
  
  def viewWillDisappear(animated)
    super  
    @lastMapType = mapView.mapType
    @lastRegion = mapView.region
  end
  

  
  def mapView(aMapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass Crossing
  
    crossing = annotation
  
    av = mapView.dequeueReusableAnnotationViewWithIdentifier NXDefaultCellID
    if !av
      av = MKAnnotationView.alloc.initWithAnnotation nil, reuseIdentifier:NXDefaultCellID
      av.canShowCallout = YES
      av.leftCalloutAccessoryView = UIImageView.alloc.initWithImage Widgets.stripeForCrossing(crossing)
      av.rightCalloutAccessoryView = UIButton.buttonWithType UIButtonTypeDetailDisclosure
    end
    av.annotation = crossing
    av.leftCalloutAccessoryView.image = Widgets.stripeForCrossing(crossing)
    av.image = pinMappingFor(crossing.color)
    av
  end
  
  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)
    return unless view.annotation.isKindOfClass Crossing
  
    crossing = view.annotation
    
    App.listController.navigationController.popToViewController App.listController, animated:NO
    tabBarController.selectedViewController = App.listController.navigationController
    UIView.animateWithDuration(0.3,
      animations: lambda { App.listController.selectCrossing(crossing, animated:NO) },
      completion: lambda { |finished| App.listController.showScheduleForCrossing(crossing, animated:YES) }
    )
  end
  

  
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
      newImage = pinMappingFor(crossing.color)
      annotationView.image = newImage
      annotationView.leftCalloutAccessoryView.image = Widgets.stripeForCrossing(crossing)
    end
  end

  def activateScreen
    modelUpdated
  end
  
  def deactivateScreen
    visibleAnnotations = mapView.annotationsInMapRect(mapView.visibleMapRect)
    visibleAnnotations.each do |annotation|
      annotationView = mapView.viewForAnnotation(annotation)
      next unless annotationView      
      annotationView.image = pinMappingFor(:gray.color)
      annotationView.leftCalloutAccessoryView.image = Device.image_named("cell-stripe-gray") if annotationView.leftCalloutAccessoryView
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
  

  
  def pinMappingFor(color)
    color.api_name ? Device.image_named("crossing-pin-#{color.api_name}") : nil
  end
end
