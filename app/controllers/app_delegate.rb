class AppDelegate
  attr_accessor :window, :locationManager, :perMinuteTimer
  attr_accessor :navigationController, :tabBarController
  attr_accessor :mainController, :listController, :mapController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Object.const_set :App, self
    Object.const_set :Model, ModelManager.alloc

    Model.init

    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    # @window.backgroundColor = UIColor.whiteColor
    @window.tintColor = Colors.windowTintColor

    @mainController = MainViewController.alloc.init
    @listController = CrossingListController.alloc.initWithStyle UITableViewStyleGrouped
    @mapController = CrossingMapController.alloc.init    
    
    @tabBarController = UITabBarController.new.tap do |tbc|
      tabItemControllers = [@mainController, @listController, @mapController]
      tbc.viewControllers = tabItemControllers.map { |c| UINavigationController.alloc.initWithRootViewController(c, withDelegate:self) }
      tbc.delegate = self
      tbc.selectedIndex = 0
    end
    @tabBarController.tabBar.translucent = NO
    @tabBarController.tabBar.tintColor = UIColor.darkGrayColor

    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible

    @perMinuteTimer = NSTimer.scheduledTimerWithTimeInterval 5, target:self, selector:'timerTicked', userInfo:nil, repeats:YES
    @perMinuteTimer.fireDate = Time.next_full_minute_date unless DEBUG

    NSNotificationCenter.defaultCenter.addObserver self, selector:'currentCrossingChanged', name:NXDefaultCellIDCurrentCrossingChanged, object:nil

    updateAppColorsToCurrent

    true
  end

  def applicationDidBecomeActive(application)    
    activateScreen
    if CLLocationManager.locationServicesEnabled
      locationManager.requestWhenInUseAuthorization if locationManager.respondsToSelector 'requestWhenInUseAuthorization'
      locationManager.startUpdatingLocation
    end
    triggerModelUpdateFor visibleViewController
  end
  
  def applicationWillResignActive(application)
    locationManager.stopUpdatingLocation
    deactivateScreen
  end

  def deactivateScreen
    @activate = false
    tabBarController.selectedViewController.visibleViewController.performSelectorIfDefined(:deactivateScreen)
    updateAppColorsTo(:gray.color)
  end
  
  def activateScreen
    @active = true
    tabBarController.selectedViewController.visibleViewController.performSelectorIfDefined(:activateScreen)
    updateAppColorsToCurrent
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
  
  # def locationManager(manager, didChangeAuthorizationStatus:status)
  #   case status
  #   when KCLAuthorizationStatusAuthorizedWhenInUse, KCLAuthorizationStatusAuthorized
  #     locationManager.startUpdatingLocation
  #   else # status > KCLAuthorizationStatusNotDetermined
  #   end
  # end

  def locationManager(manager, didUpdateToLocation:newLocation, fromLocation:oldLocation)
    MXWriteToConsole(
      "didUpdateToLocation acc=%.f dist=%.f %@", 
      newLocation.horizontalAccuracy, newLocation.distanceFromLocation(oldLocation), Model.closestCrossing.localizedName)

    newClosestCrossing = Model.crossingClosestTo(newLocation)
    if newClosestCrossing != Model.closestCrossing
      Model.closestCrossing = newClosestCrossing
      NSNotificationCenter.defaultCenter.postNotificationName NXDefaultCellIDClosestCrossingChanged, object:Model.closestCrossing
    end
  end

  def locationManager(manager, didFailWithError:error)
    MXWriteToConsole("locationManager:didFailWithError: %@", error)
  
    Model.closestCrossing = nil
    NSNotificationCenter.defaultCenter.postNotificationName NXDefaultCellIDClosestCrossingChanged, object:Model.closestCrossing
  end
  
  def startLocationTracking
    locationManager.startUpdatingLocation
  end
    
  
  
  def navigationController(navController, willShowViewController:viewController, animated:animated)
    newControllerHasNoToolbar = viewController.toolbarItems.nil? || viewController.toolbarItems.count == 0
    navController.setToolbarHidden newControllerHasNoToolbar, animated:animated
    triggerModelUpdateFor viewController if animated
  end

  def timerTicked
    return unless @active
    triggerModelUpdateFor visibleViewController
    updateAppColorsToCurrent
  end
  
  def currentCrossingChanged
    updateAppColorsToCurrent
  end
  
  def triggerModelUpdateFor(controller)
    controller.modelUpdated if controller.respondsToSelector 'modelUpdated'
  end
  
  def updateAppColorsToCurrent
    updateAppColorsTo(Model.currentCrossing.color)
  end
  
  def updateAppColorsTo(baseColor)
    barBackColor = Colors.barBackColorFor(baseColor)
    barTextColor = Colors.barTextColorFor(baseColor)
    barStyle = Colors.barStyleFor(baseColor)
    
    [@mainController.navigationController].each do |navController|
      navController.navigationBar.barTintColor = barBackColor
      navController.navigationBar.tintColor = barTextColor
      navController.navigationBar.barStyle = barStyle
      navController.navigationBar.setTitleTextAttributes NSForegroundColorAttributeName => barTextColor
    end
    
    # if @tabBarController.selectedViewController.is_a?(UINavigationController)
    #   navigationController = @tabBarController.selectedViewController
    #   navigationController.toolbar.barTintColor = barBackColor
    #   navigationController.toolbar.tintColor = barTextColor
    #   navigationController.navigationBar.barStyle = barStyle
    #   navigationController.navigationBar.barTintColor = barBackColor
    #   navigationController.navigationBar.tintColor = barTextColor
    #   navigationController.navigationBar.setTitleTextAttributes NSForegroundColorAttributeName => barTextColor
    # end
  end

  
  
  def visibleViewController
    @tabBarController
  end
end
