class AppDelegate
  attr_accessor :window, :locationManager, :perMinuteTimer, :mapController, :navigationController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    model = ModelManager.alloc.init
    app = self # WTF
    
    mainViewController = MainViewController.alloc.initWithNibName "MainView", bundle:nil
    @navigationController = UINavigationController.alloc.initWithRootViewController mainViewController
    @navigationController.delegate = self

    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.backgroundColor = UIColor.whiteColor
    @window.rootViewController = self.navigationController
    @window.makeKeyAndVisible

    @perMinuteTimer = NSTimer.scheduledTimerWithTimeInterval 20, target:self, selector:'timerTicked', userInfo:nil, repeats:YES
    @perMinuteTimer.fireDate = Helper.nextFullMinuteDate

    true
  end

  def applicationDidBecomeActive(application)
    locationManager.startUpdatingLocation if CLLocationManager.locationServicesEnabled
  end

  def applicationWillResignActive(application)
    locationManager.stopUpdatingLocation
  end

  def applicationWillEnterForeground(application)
    triggerModelUpdateFor navigationController.visibleViewController
  end
  
  def applicationDidEnterBackground(application)
  end
  
  def applicationWillTerminate(application)
  end
    
  ### Location Tracking
  
  def locationManager
    unless @locationManager
      @locationManager = CLLocationManager.new
      @locationManager.delegate = self
      @locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
      @locationManager.distanceFilter = 100
    end
    @locationManager
  end

  def locationManager(manager, didUpdateToLocation:newLocation, fromLocation:oldLocation)
    MXWriteToConsole(
      "didUpdateToLocation acc=%.f dist=%.f %@", 
      newLocation.horizontalAccuracy, newLocation.distanceFromLocation(oldLocation), model.closestCrossing.name)
  
    newClosestCrossing = model.crossingClosestTo(newLocation)
    if newClosestCrossing != model.closestCrossing
      model.closestCrossing = newClosestCrossing
      NSNotificationCenter.defaultCenter.postNotificationName NXClosestCrossingChanged, object:model.closestCrossing
    end
  end

  def locationManager(manager, didFailWithError:error)
    MXWriteToConsole("locationManager:didFailWithError: %@", error)
  
    model.closestCrossing = nil
    NSNotificationCenter.defaultCenter.postNotificationName NXClosestCrossingChanged, object:model.closestCrossing
  end
  
  ### handlers
  
  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navigationController.setToolbarHidden viewController.toolbarItems.count == 0, animated:animated
    triggerModelUpdateFor.viewController if (animated)
  end
  
  def timerTicked
    triggerModelUpdateFor navigationController.visibleViewController
  end
  
  def triggerModelUpdateFor(controller)
    if controller.respondsToSelector 'modelUpdated'
      controller.performSelector 'modelUpdated'
    end
  end
  
  ### properties
  
  def mapController
    @mapController ||= CrossingMapController.alloc.init
  end
end

