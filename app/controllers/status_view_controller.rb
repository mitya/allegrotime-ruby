class StatusViewController < UIViewController
  def init() super
    self.title = "main.title".l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("main.tab".l, image:Device.image_named("ti-semaphore"), selectedImage:Device.image_named("ti-semaphore-filled"))
    self
  end

  def loadView
    self.view = StatusView.alloc.initWithFrame(CGRectZero)
    self.view.delegate = self
  end

  def viewDidLoad() super
    NSNotificationCenter.defaultCenter.addObserver self, selector:'closestCrossingChanged', name:NXDefaultCellIDClosestCrossingChanged, object:nil

    navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle "main.backbutton".l, style:UIBarButtonItemStyleBordered, target:nil, action:nil

    # setup info button
    infoButton = UIButton.buttonWithType UIButtonTypeInfoLight
    infoButton.addTarget self, action:'showInfo', forControlEvents:UIControlEventTouchUpInside
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView infoButton

    # setup log console gestures
    if DEBUG
      swipeRecognizer = UISwipeGestureRecognizer.alloc.initWithTarget self, action:'recognizedSwipe:'
      swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft
      view.addGestureRecognizer swipeRecognizer
    end

    # setupAdView

    # self.adTimer = NSTimer.scheduledTimerWithTimeInterval GAD_REFRESH_PERIOD, target:self, selector:'adTimerTicked', userInfo:nil, repeats:YES
  end

  def viewWillAppear(animated) super
    reloadData
    # requestAdViewIfDelayed
  end

  # def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
  #   adSize = Device.portrait?(orientation) ? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape
  #   adView.adSize = adSize
  #   y = view.frame.height - CGSizeFromGADAdSize(adSize).height
  #   adView.frame = CGRectMake(0, y, adView.frame.width, adView.frame.height)
  #   tableView.frame = tableView.frame.change(height: view.bounds.height - adView.frame.height)
  # end



  # def setupAdView
  #   self.adView = GADBannerView.alloc.initWithAdSize Device.portrait?? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape
  #   adView.adUnitID = Device.iphone? ? GAD_IPHONE_AD_UNIT_ID : GAD_IPAD_AD_UNIT_ID
  #   adView.rootViewController = self
  #   adView.backgroundColor = UIColor.clearColor
  #   adView.delegate = self
  #   adView.hidden = YES
  #   adView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
  #   adView.origin = CGPointMake(0, App.window.bounds.height - adView.bounds.height)
  #
  #   view.addSubview adView
  #   requestAdView
  # end
  #
  # def requestAdView
  #   adRequest = GADRequest.request
  #   adRequest.testing = GAD_TESTING_MODE
  #   adRequest.testDevices = [ GAD_SIMULATOR_ID, GAD_TESTING_IPHONE_ID, GAD_TESTING_IPAD_ID ]
  #
  #   if location = App.locationManager.location
  #     adRequest.setLocationWithLatitude location.coordinate.latitude, longitude:location.coordinate.longitude, accuracy:location.horizontalAccuracy
  #   end
  #
  #   adView.loadRequest adRequest
  # end
  #
  # def requestAdViewIfDelayed
  #   if @adViewRequestPending
  #     @adViewRequestPending = NO
  #     requestAdView
  #   end
  # end
  #
  # def adTimerTicked
  #   if adViewLoaded
  #     if navigationController.visibleViewController == self
  #       requestAdView
  #     else
  #       @adViewRequestPending = YES
  #     end
  #   end
  # end
  #
  # def adViewDidReceiveAd(adView)
  #   # if !adViewLoaded
  #   #   adView.frame = adView.frame.change(y: view.bounds.height)
  #   #   UIView.animateWithDuration 0.25, animations: -> do
  #   #     adView.hidden = NO
  #   #     adView.frame = adView.frame.change(y: view.bounds.height - adView.frame.height)
  #   #     tableView.frame = tableView.frame.change(height: view.bounds.height - adView.frame.height)
  #   #   end
  #   #   @adViewLoaded = YES
  #   # end
  # end
  #
  # def adView(view, didFailToReceiveAdWithError:error)
  #   Log.warn "adView:didFailToReceiveAdWithError: #{error.description}"
  # end
  #
  #

  def recognizedSwipe(recognizer)
    point = recognizer.locationInView view
    showLog if point.y > 300
  end

  def modelUpdated
    reloadData
  end

  def closestCrossingChanged
    reloadData
  end

  def screenActivated
    reloadData
  end

  def screenDeactivated
    view.messageLabel.text = ''
    view.messageLabel.backgroundColor = Colors.closingCellBackgroundFor(:gray.color)
    view.messageLabel.textColor = Colors.messageCellColorFor(:gray.color)
  end


  def statusViewCrossingLabelTouched
    showCrossingListToChangeCurrent
  end

  def showCrossingListToChangeCurrent
    crossingsController = CrossingListController.alloc.initWithStyle UITableViewStyleGrouped
    crossingsController.target = self
    crossingsController.action = 'changeCurrentCrossing:'
    crossingsController.accessoryType = UITableViewCellAccessoryCheckmark
    navigationController.pushViewController crossingsController, animated:YES
  end

  def changeCurrentCrossing(crossing)
    Model.currentCrossing = crossing
    navigationController.popViewControllerAnimated YES
    reloadData
  end

  def showInfo
    aboutController = AboutController.alloc.init
    navigationController.pushViewController aboutController, animated:YES
  end

  def showLog
    logController = LogViewController.alloc.init
    navigationController.pushViewController logController, animated:YES
  end

  def reloadData
    crossing = Model.currentCrossing
    
    view.crossingLabel.text = crossing.localizedName
    view.crossingStatusLabel.text = "main.crossing $closes at $time".li \
        crossing.closed? ? "closed".l : "will be closed".l, Format.munutes_as_hhmm(crossing.nextClosing.closingTime)
    view.trainStatusLabel.text = "main.allegro will pass at $time".li(Format.munutes_as_hhmm(crossing.nextClosing.trainTime))
    view.messageLabel.text = crossing.subtitle
    view.messageLabel.backgroundColor = Colors.closingCellBackgroundFor(crossing.color)
    view.messageLabel.textColor = Colors.messageCellColorFor(crossing.color)
  end
end
