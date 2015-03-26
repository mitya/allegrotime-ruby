class CrossingMapController < UIViewController
 attr_accessor :mapView, :pinMapping, :timer, :crossingToShowOnNextAppearance
 attr_accessor :lastRegion, :lastMapType, :lastCrossing, :lastAccessTime
 

  def init() super
    self.title = 'map.title'.l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle "map.tab".l, image:Device.image_named("ti-map"), selectedImage:Device.image_named("ti-map-filled")
    self.lastMapType ||= MKMapTypeHybrid
    self
  end

  def loadView
    self.mapView = MKMapView.alloc.init.tap do |mv|
      mv.delegate = self
      mv.mapType = lastMapType
      mv.showsUserLocation = YES
    end
    self.view = mapView
  end
  
  def viewDidLoad() super  
    navigationItem.titleView = segmentedControl
    mapView.addAnnotations Model.crossings
  end
  
  def viewWillAppear(animated) super
    setupShowLocationButton
    mapView.setRegion MKCoordinateRegionMakeWithDistance(Model.currentCrossing.coordinate, 30_000, 30_000), animated:NO unless lastRegion
    # if lastRegion
    #   mapView.setRegion lastRegion, animated:animated
    #   mapView.setCenterCoordinate Model.currentCrossing.coordinate, animated:YES
    # else
    #   showCrossing Model.currentCrossing, animated:animated
    # end
  end
  
  def viewDidAppear(animated) super
    Device.trackScreen :map
    if lastCrossing != Model.currentCrossing || (lastAccessTime || 0) < Time.now - 5*60
      showCrossing Model.currentCrossing, animated:YES
    end
    @lastAccessTime = Time.now
  end
  
  def viewWillDisappear(animated) super
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
    Device.trackUI :tap_map_accessory, crossing
    openCrossingSchedule(crossing)
  end
  
  
  def changeMapType(segment)
    mapView.mapType = segment.selectedSegmentIndex
    Device.trackUI :change_map_type, mapView.mapType
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

  def screenActivated
    modelUpdated
  end
  
  def screenDeactivated
    visibleAnnotations = mapView.annotationsInMapRect(mapView.visibleMapRect)
    visibleAnnotations.each do |annotation|
      annotationView = mapView.viewForAnnotation(annotation)
      next unless annotationView      
      annotationView.image = pinMappingFor(:gray.color)
      annotationView.leftCalloutAccessoryView.image = Device.image_named("cell-stripe-gray") if annotationView.leftCalloutAccessoryView
    end
  end
  
  def showUserLocation
    coordinate = mapView.userLocation.location && mapView.userLocation.location.coordinate
    Device.trackUI :tap_show_location
    if coordinate && coordinate.latitude != 0 && coordinate.latitude != 0
      mapView.setCenterCoordinate coordinate, animated:YES
    end
  end
  
  def showCrossing(crossing, animated:animated)
    mapView.setRegion MKCoordinateRegionMakeWithDistance(crossing.coordinate, 10_000, 10_000), animated:animated
    mapView.selectAnnotation crossing, animated:animated    
    @lastCrossing = crossing
  end
  
  def openCrossingSchedule(crossing)
    Model.currentCrossing = crossing
    App.crossingScheduleController.navigationController.popToRootViewControllerAnimated(NO)
    tabBarController.selectedViewController = App.crossingScheduleController.navigationController
  end
  

  def pinMappingFor(color)
    color.api_name ? Device.image_named("crossing-pin-#{color.api_name}") : nil
  end
  
  def segmentedControl
    @segmentedControl ||= begin
      sc = UISegmentedControl.alloc.initWithItems ['map.standard'.l, 'map.satellite'.l, 'map.hybrid'.l]
      sc.segmentedControlStyle = UISegmentedControlStyleBar
      sc.selectedSegmentIndex = lastMapType
      sc.addTarget self, action:'changeMapType:', forControlEvents:UIControlEventValueChanged
    end
  end  
  
  def setupShowLocationButton
    @showLocationButton ||= UIBarButtonItem.alloc.initWithImage \
        Device.image_named("bb-location"), style:UIBarButtonItemStyleBordered, target:self, action:'showUserLocation'    
    navigationItem.rightBarButtonItem = App.locationAvailable? ? @showLocationButton : nil    
  end
end
