class AppDelegate
  attr_accessor :window, :locationManager, :perMinuteTimer
  attr_accessor :navigationController, :tabBarController
  attr_accessor :mainController, :listController, :mapController, :crossingScheduleController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Object.const_set :App, self
    Object.const_set :Model, ModelManager.alloc
    Model.init

    UINavigationBar.appearance.translucent = NO
    UITabBar.appearance.translucent = NO

    @mainController = StatusViewController.alloc.init
    @listController = CrossingListController.alloc.initWithStyle UITableViewStyleGrouped
    @crossingScheduleController = CrossingScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    @mapController = CrossingMapController.alloc.init
    @tabBarController = UITabBarController.new.tap do |tbc|
      tabItemControllers = [@mainController, @crossingScheduleController, @mapController]
      tbc.viewControllers = tabItemControllers.map do |c|
         nav = UINavigationController.alloc.initWithRootViewController(c)
         nav.delegate = self
         nav
      end
      tbc.delegate = self
      tbc.selectedIndex = 0
    end

    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible
    @window.tintColor = Colors.windowTintColor

    @perMinuteTimer = NSTimer.scheduledTimerWithTimeInterval 1, target:self, selector:'timerTicked', userInfo:nil, repeats:YES
    @perMinuteTimer.fireDate = Time.next_full_minute_date unless DEBUG
    @perMinuteTimerLastFireTime = 0

    NSNotificationCenter.defaultCenter.addObserver self, selector:'currentCrossingChanged', name:NXDefaultCellIDCurrentCrossingChanged, object:nil

    initTrackers

    true
  end

  def applicationDidBecomeActive(application)
    screenActivated
    if CLLocationManager.locationServicesEnabled
      locationManager.requestWhenInUseAuthorization if locationManager.respondsToSelector 'requestWhenInUseAuthorization'
      locationManager.startUpdatingLocation
    end
    triggerModelUpdate
  end

  def applicationWillResignActive(application)
    locationManager.stopUpdatingLocation
    screenDeactivated
  end


  def locationManager
    @locationManager ||= begin
      lm = CLLocationManager.new
      lm.delegate = self
      lm.desiredAccuracy = KCLLocationAccuracyHundredMeters
      lm.distanceFilter = 100
      lm
    end
  end

  def locationManager(manager, didChangeAuthorizationStatus:status)
    Device.trackSystem :location_authorization_changed, status
    case status
    when KCLAuthorizationStatusAuthorizedWhenInUse, KCLAuthorizationStatusAuthorizedAlways
      locationManager.startUpdatingLocation
    else
      locationManager.stopUpdatingLocation
    end
  end

  def locationManager(manager, didUpdateToLocation:nl, fromLocation:ol)
    Device.debug "didUpdateToLocation acc=%.f dist=%.f %s", nl.horizontalAccuracy, nl.distanceFromLocation(ol), Model.closestCrossing.localizedName
    
    newClosestCrossing = Model.crossingClosestTo(nl)
    if newClosestCrossing != Model.closestCrossing
      Device.trackSystem :closest_crossing_changed, newClosestCrossing
      Model.closestCrossing = newClosestCrossing
      if (Model.currentCrossingChangeTime || 0) < Time.now - 10*60
        Model.currentCrossing = newClosestCrossing
      end
      NSNotificationCenter.defaultCenter.postNotificationName NXDefaultCellIDClosestCrossingChanged, object:Model.closestCrossing
    end
    
    Flurry.setLatitude nl.coordinate.latitude, longitude:nl.coordinate.longitude, horizontalAccuracy:nl.horizontalAccuracy, verticalAccuracy:nl.verticalAccuracy
  end

  def locationManager(manager, didFailWithError:error)
    Device.debug "locationManager.didFailWithError: #{error.description}"
    Device.trackSystem :location_failed, error.description
    Model.closestCrossing = nil
    NSNotificationCenter.defaultCenter.postNotificationName NXDefaultCellIDClosestCrossingChanged, object:Model.closestCrossing
  end


  def screenDeactivated
    @active = false
    visibleViewController.performSelectorIfDefined(:screenDeactivated)
  end

  def screenActivated
    Device.trackSystem :app_activated
    @active = true
    visibleViewController.performSelectorIfDefined(:screenActivated)
  end

  def timerTicked
    if @active && @perMinuteTimerLastFireTime != Device.currentTimeInMunutes
      @perMinuteTimerLastFireTime = Device.currentTimeInMunutes
      triggerModelUpdate      
    end
  end

  def currentCrossingChanged
  end

  def triggerModelUpdate
    visibleViewController.performSelectorIfDefined :modelUpdated
  end

  def visibleViewController
    tabBarController.selectedViewController.visibleViewController
  end
  
  def initTrackers
    return unless TRACKING    
    
    GAI.sharedInstance.trackerWithTrackingId "UA-60863161-1"
    GAI.sharedInstance.dispatchInterval = 20
    GAI.sharedInstance.trackUncaughtExceptions = YES
    GAI.sharedInstance.logger.setLogLevel DEBUG ? KGAILogLevelWarning : KGAILogLevelInfo
    GAI.sharedInstance.setDryRun YES if DEBUG
    
    Flurry.startSession FLURRY_TOKEN
  end
  
  def locationAvailable?
    CLLocationManager.locationServicesEnabled && locationManager && locationManager.location
  end
end
