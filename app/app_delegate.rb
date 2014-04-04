class AppDelegate
  attr_accessor :window, :locationManager, :perMinuteTimer, :mapController, :navigationController

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    model = ModelManager.alloc.init
    app = self
    
    mainViewController = MainViewController.alloc.initWithNibName("MainView", bundle:nil)
    self.navigationController = UINavigationController.alloc.initWithRootViewController(mainViewController)
    self.navigationController.delegate = self

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.window.backgroundColor = UIColor.whiteColor
    self.window.rootViewController = self.navigationController
    self.window.makeKeyAndVisible

    self.perMinuteTimer = NSTimer.scheduledTimerWithTimeInterval(20, target:self, selector:'timerTicked', userInfo:nil repeats:YES)
    self.perMinuteTimer.fireDate = Helper.nextFullMinuteDate

    true
  end

  def applicationDidBecomeActive(application)
    self.locationManager.startUpdatingLocation if CLLocationManager.locationServicesEnabled
  end

  # - (void)applicationWillResignActive:(UIApplication *)application {
  #   [self.locationManager stopUpdatingLocation];
  # }
  # 
  # - (void)applicationWillEnterForeground:(UIApplication *)application {
  #   [self triggerModelUpdateFor:self.navigationController.visibleViewController];
  # }
  # 
  # - (void)applicationDidEnterBackground:(UIApplication *)application {
  # }
  # 
  # - (void)applicationWillTerminate:(UIApplication *)application {
  # }
  # 
  # 
  # #pragma mark - Location Tracking
  # 
  # - (CLLocationManager *)locationManager {
  #   if (!locationManager) {
  #     locationManager = [CLLocationManager new];
  #     locationManager.delegate = self;
  #     locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  #     locationManager.distanceFilter = 100;
  #   }
  #   return locationManager;
  # }
  # 
  # - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  #   MXWriteToConsole(@"didUpdateToLocation acc=%.f dist=%.f %@", newLocation.horizontalAccuracy, [newLocation distanceFromLocation:oldLocation], model.closestCrossing.name);
  # 
  #   Crossing *const newClosestCrossing = [model crossingClosestTo:newLocation];
  #   if (newClosestCrossing != model.closestCrossing) {
  #     model.closestCrossing = newClosestCrossing;
  #     [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
  #   }
  # }
  # 
  # - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  #   MXWriteToConsole(@"locationManager:didFailWithError: %@", error);
  # 
  #   model.closestCrossing = nil;
  #   [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
  # }
  # 
  # #pragma mark - handlers
  # 
  # - (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  #   [self.navigationController setToolbarHidden:(viewController.toolbarItems.count == 0) animated:animated];
  # 
  #   if (animated)
  #     [self triggerModelUpdateFor:viewController];
  # }
  # 
  # - (void)timerTicked {
  #   [self triggerModelUpdateFor:self.navigationController.visibleViewController];
  # }
  # 
  # - (void)triggerModelUpdateFor:(UIViewController *)controller {
  #   if ([controller respondsToSelector:@selector(modelUpdated)]) {
  #     [controller performSelector:@selector(modelUpdated)];
  #   }
  # }
  # 
  # #pragma mark - properties
  # 
  # - (CrossingMapController *)mapController {
  #   if (!mapController)
  #     mapController = [[CrossingMapController alloc] init];
  #   return mapController;
  # }
  # 
  # @end

end

