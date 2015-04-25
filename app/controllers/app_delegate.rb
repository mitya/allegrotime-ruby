class AppDelegate
  attr_accessor :window, :locationManager, :perMinuteTimer
  attr_accessor :navigationController, :tabBarController
  attr_accessor :mainController, :mapController, :crossingScheduleController

  def uncaughtExceptionHandler(exception)
    if Env::TRACKING_FLURRY
      Flurry.logError exception.name, message:exception.reason, exception:exception
      NSLog "--- Logged error to Flurry"
    end

    # NSLog "--- Error Name: #{exception.name}\n--- Reason: #{exception.reason}\n--- UserInfo: #{exception.userInfo}"

    # if Env::TRACKING_GA
    #   Device.gai.send GAIDictionaryBuilder.createExceptionWithDescription("#{exception.name}, #{exception.reason}", withFatal:YES).build
    #   NSLog "--- Logged error to Google"
    # end
  end

  def application(application, didFinishLaunchingWithOptions:launchOptions)  
    if Env::TRACKING_FLURRY    
      # Flurry.setCrashReportingEnabled YES
      # Flurry.setDebugLogEnabled YES
      Flurry.startSession FLURRY_TOKEN
    end
    
    # Crittercism.enableWithAppID "553b7d6c7365f84f7d3d6fa3"
    
    @exceptionHandler = method :uncaughtExceptionHandler
    NSSetUncaughtExceptionHandler @exceptionHandler

    initTrackers
        
    # boom
        
    Object.const_set :App, self
    Object.const_set :Model, ModelManager.alloc
    Model.init

    @mainController = StatusViewController.alloc.init
    @crossingScheduleController = CrossingScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    @mapController = CrossingMapController.alloc.init
    @tabBarController = UITabBarController.new.tap do |tbc|
      tabItemControllers = [@mainController, @crossingScheduleController, @mapController]
      tbc.viewControllers = tabItemControllers.map do |c|
         nav = UINavigationController.alloc.initWithRootViewController(c)
         nav.delegate = self
         nav.navigationBar.translucent = NO
         nav
      end
      tbc.delegate = self
      tbc.selectedIndex = 0
    end
    @tabBarController.tabBar.translucent = NO

    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible
    @window.tintColor = Colors.windowTintColor

    @perMinuteTimer = NSTimer.scheduledTimerWithTimeInterval 1, target:self, selector:'timerTicked', userInfo:nil, repeats:YES
    @perMinuteTimer.fireDate = Time.next_full_minute_date unless DEBUG
    @perMinuteTimerLastFireTime = 0
    
    true
  end

  def applicationDidBecomeActive(application)
    screenActivated
    startUpdatingLocation    
    Device.notify(ATModelUpdated)
    resetScreenIfNeeded    
  end

  def applicationWillResignActive(application)
    locationManager.stopUpdatingLocation
    screenDeactivated
    @applicationDeactivatedAt = Time.now
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
    Device.debug "updated location acc=%.f dist=%.f %s", nl.horizontalAccuracy, nl.distanceFromLocation(ol), Model.closestCrossing.localizedName
    
    return if nl.horizontalAccuracy > 1_000
    
    newClosestCrossing = Model.crossingClosestTo(nl, :active)
    if newClosestCrossing != Model.closestCrossing
      Device.trackSystem :closest_crossing_changed, newClosestCrossing
      Model.closestCrossing = newClosestCrossing
      if (Model.currentCrossingChangeTime || 0) < Time.now - 10*60
        Model.currentCrossing = newClosestCrossing
      end
      NSNotificationCenter.defaultCenter.postNotificationName ATModelUpdated
    end
    
    if Env::TRACKING_FLURRY
      Flurry.setLatitude nl.coordinate.latitude, longitude:nl.coordinate.longitude, horizontalAccuracy:nl.horizontalAccuracy, verticalAccuracy:nl.verticalAccuracy
    end
  end

  def locationManager(manager, didFailWithError:error)
    Device.debug "location update failed: #{error.description}"
    Device.trackSystem :location_failed, error.description
    Model.closestCrossing = nil
    NSNotificationCenter.defaultCenter.postNotificationName ATModelUpdated
  end


  def screenDeactivated
    @active = false
    visibleViewController.performSelectorIfDefined(:screenDeactivated)
  end

  def screenActivated
    Device.trackSystem :app_activated
    @active = true
  end

  def timerTicked
    if @active && @perMinuteTimerLastFireTime != Device.currentTimeInMunutes
      @perMinuteTimerLastFireTime = Device.currentTimeInMunutes
      Device.notify(ATModelUpdated)
    end
  end

  def visibleViewController
    tabBarController.selectedViewController.visibleViewController
  end
  
  def initTrackers
    if Env::TRACKING_GA
      GAI.sharedInstance.trackerWithTrackingId GAI_TOKEN
      GAI.sharedInstance.dispatchInterval = GAI_DISPATCH_INTERVAL
      GAI.sharedInstance.logger.setLogLevel DEBUG ? KGAILogLevelWarning : KGAILogLevelInfo
    end
  end
  
  def locationAvailable?
    CLLocationManager.locationServicesEnabled && locationManager && locationManager.location
  end
  
  def resetScreenIfNeeded
    @applicationDeactivatedAt ||= 0
    timeSinceLastLaunch = (Time.now - @applicationDeactivatedAt).to_i
    Device.debug "Time since last launch: #{timeSinceLastLaunch / 60}:#{timeSinceLastLaunch % 60}"
    if timeSinceLastLaunch > 5 * 60
      tabBarController.selectedViewController = App.mainController.navigationController
      App.mainController.navigationController.popToRootViewControllerAnimated(NO)
      Model.currentCrossing = Model.closestCrossing if Model.closestCrossing
    end
  end
  
  def startUpdatingLocation
    if CLLocationManager.locationServicesEnabled
      locationManager.requestWhenInUseAuthorization if locationManager.respondsToSelector 'requestWhenInUseAuthorization'
      locationManager.startUpdatingLocation
    end    
  end
end
