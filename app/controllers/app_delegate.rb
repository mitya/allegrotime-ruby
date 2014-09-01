DEBUG = true
YES = true
NO = false
NULL = nil

class AppDelegate
  attr_accessor :window, :locationManager, :perMinuteTimer, :mapController, :navigationController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Object.const_set :App, self
    Object.const_set :Model, ModelManager.alloc

    Model.init

    mainViewController = MainViewController.alloc.init
    @navigationController = UINavigationController.alloc.initWithRootViewController(mainViewController)
    @navigationController.delegate = self

    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.backgroundColor = UIColor.whiteColor
    @window.rootViewController = navigationController
    @window.makeKeyAndVisible

    @perMinuteTimer = NSTimer.scheduledTimerWithTimeInterval 20, target:self, selector:'timerTicked', userInfo:nil, repeats:YES
    @perMinuteTimer.fireDate = Time.next_full_minute_date

    NSNotificationCenter.defaultCenter.addObserver self, selector:'currentCrossingChanged', name:NXCurrentCrossingChanged, object:nil

    updateAppColors

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
    @locationManager ||= begin
      lm = CLLocationManager.new
      lm.delegate = self
      lm.desiredAccuracy = KCLLocationAccuracyHundredMeters
      lm.distanceFilter = 100
      lm
    end    
  end

  def locationManager(manager, didUpdateToLocation:newLocation, fromLocation:oldLocation)
    MXWriteToConsole(
      "didUpdateToLocation acc=%.f dist=%.f %@", 
      newLocation.horizontalAccuracy, newLocation.distanceFromLocation(oldLocation), Model.closestCrossing.localizedName)

    newClosestCrossing = Model.crossingClosestTo(newLocation)
    if newClosestCrossing != Model.closestCrossing
      Model.closestCrossing = newClosestCrossing
      NSNotificationCenter.defaultCenter.postNotificationName NXClosestCrossingChanged, object:Model.closestCrossing
    end
  end

  def locationManager(manager, didFailWithError:error)
    MXWriteToConsole("locationManager:didFailWithError: %@", error)
  
    Model.closestCrossing = nil
    NSNotificationCenter.defaultCenter.postNotificationName NXClosestCrossingChanged, object:Model.closestCrossing
  end
  
  ### handlers
  
  def navigationController(navController, willShowViewController:viewController, animated:animated)
    newControllerHasNoToolbar = viewController.toolbarItems.nil? || viewController.toolbarItems.count == 0
    navController.setToolbarHidden newControllerHasNoToolbar, animated:animated
    triggerModelUpdateFor viewController if animated
  end
  
  def timerTicked
    triggerModelUpdateFor navigationController.visibleViewController
    updateAppColors
  end
  
  def currentCrossingChanged
    updateAppColors
  end
  
  def triggerModelUpdateFor(controller)
    if controller.respondsToSelector 'modelUpdated'
      controller.performSelector 'modelUpdated'
    end
  end
  
  def updateAppColors
    baseColor = Model.currentCrossing.color
    barBackColor = Colors.barBackColorFor(baseColor)
    barTextColor = Colors.barTextColorFor(baseColor)

    @window.tintColor = Colors.windowTintColor
    @navigationController.toolbar.barTintColor = barBackColor
    @navigationController.toolbar.tintColor = barTextColor
    @navigationController.navigationBar.barStyle = Colors.barStyleFor(baseColor)
    @navigationController.navigationBar.barTintColor = barBackColor
    @navigationController.navigationBar.tintColor = barTextColor
    @navigationController.navigationBar.setTitleTextAttributes NSForegroundColorAttributeName => barTextColor
  end
  
  ### properties
  
  def mapController
    @mapController ||= CrossingMapController.alloc.init
  end
end

