class AppDelegate
  attr_accessor :window, :locationManager, :perMinuteTimer
  attr_accessor :navigationController, :tabBarController
  attr_accessor :mainController, :listController, :mapController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Object.const_set :App, self
    Object.const_set :Model, ModelManager.alloc

    Model.init

    UINavigationBar.appearance.translucent = NO
    UITabBar.appearance.translucent = NO

    # @mainController = MainViewController.alloc.init
    @mainController = StatusViewController.alloc.init
    @listController = CrossingListController.alloc.initWithStyle UITableViewStyleGrouped
    # @mapController = CrossingMapController.alloc.init
    @mapController = MainViewController.alloc.init
    @tabBarController = UITabBarController.new.tap do |tbc|
      tabItemControllers = [@mainController, @listController, @mapController]
      tbc.viewControllers = tabItemControllers.map { |c| UINavigationController.alloc.initWithRootViewController(c, withDelegate:self) }
      tbc.delegate = self
      tbc.selectedIndex = 0
    end

    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible
    @window.tintColor = Colors.windowTintColor

    @perMinuteTimer = NSTimer.scheduledTimerWithTimeInterval 1, target:self, selector:'timerTicked', userInfo:nil, repeats:YES
    @perMinuteTimer.fireDate = Time.next_full_minute_date unless DEBUG
    @lastFireTime = 0

    NSNotificationCenter.defaultCenter.addObserver self, selector:'currentCrossingChanged', name:NXDefaultCellIDCurrentCrossingChanged, object:nil

    updateAppColorsToCurrent

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

  def screenDeactivated
    @activate = false
    visibleViewController.performSelectorIfDefined(:screenDeactivated)
    updateAppColorsTo(:gray.color)
  end

  def screenActivated
    @active = true
    visibleViewController.performSelectorIfDefined(:screenActivated)
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
    triggerModelUpdate if animated
  end

  def timerTicked
    if @active && @lastFireTime != Device.currentTimeInMunutes
      @lastFireTime = Device.currentTimeInMunutes
      triggerModelUpdate      
    end
  end

  def currentCrossingChanged
    updateAppColorsToCurrent
  end

  def triggerModelUpdate
    visibleViewController.performSelectorIfDefined :modelUpdated
  end

  def updateAppColorsToCurrent
    updateAppColorsTo(Model.currentCrossing.color)
  end

  def updateAppColorsTo(baseColor)
    # barBackColor = Colors.barBackColorFor(baseColor)
    # barTextColor = Colors.barTextColorFor(baseColor)
    # barStyle = Colors.barStyleFor(baseColor)
    #
    # [@mainController.navigationController].each do |navController|
    #   navController.navigationBar.barTintColor = barBackColor
    #   navController.navigationBar.tintColor = barTextColor
    #   navController.navigationBar.barStyle = barStyle
    #   navController.navigationBar.setTitleTextAttributes NSForegroundColorAttributeName => barTextColor
    # end
  end

  def visibleViewController
    tabBarController.selectedViewController.visibleViewController
  end
end
