class MainViewController < UIViewController
  attr_accessor :tableView
  attr_accessor :crossingCell, :stateCell, :messageCell, :showScheduleCell, :showMapCell
  attr_accessor :stateCellTopLabel, :stateCellBottomLabel
  attr_accessor :adView, :adTimer, :adViewLoaded

  STATE_SECTION = 0
  MESSAGE_SECTION = 1
  ACTIONS_SECTION = 2



  def init
    super
    self.title = "main.title".l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("main.tab".l, image:Device.image_named("ti-semaphore"), selectedImage:Device.image_named("ti-semaphore-filled"))
    self
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end

  def loadView
    self.view = UIView.alloc.init

    self.crossingCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleValue1, reuseIdentifier:NXDefaultCellID
    crossingCell.textLabel.text = 'main.crossing_cell'.l
    crossingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    crossingCell.detailTextLabel.font = UIFont.boldSystemFontOfSize(17)
    crossingCell.detailTextLabel.color = UIColor.blackColor
    
    self.stateCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleSubtitle, reuseIdentifier:NXDefaultCellID
    stateCell.textLabel.textAlignment = NSTextAlignmentCenter
    stateCell.detailTextLabel.textAlignment = NSTextAlignmentCenter
    stateCell.detailTextLabel.textColor = :darkGray.color
    stateCell.selectionStyle = UITableViewCellSelectionStyleNone
    
    self.messageCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:NXDefaultCellID
    messageCell.selectionStyle = UITableViewCellSelectionStyleNone
    messageCell.textLabel.textAlignment = NSTextAlignmentCenter
    
    self.showScheduleCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:NXDefaultCellID
    showScheduleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    showScheduleCell.textLabel.text = 'main.show_schedule'.l
    
    self.showMapCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:NXDefaultCellID
    showMapCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    showMapCell.textLabel.text = 'main.show_map'.l
    
    self.tableView = UITableView.alloc.initWithFrame view.bounds, style:UITableViewStyleGrouped
    tableView.delegate = self
    tableView.dataSource = self
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    
    self.view.addSubview(tableView)
  end

  def viewDidLoad
    navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle "main.backbutton".l, style:UIBarButtonItemStyleBordered, target:nil, action:nil

    NSNotificationCenter.defaultCenter.addObserver self, selector:'closestCrossingChanged', name:NXDefaultCellIDClosestCrossingChanged, object:nil

    setupInfoButton
    setupLogConsoleGesture
    setupAdView

    self.adTimer = NSTimer.scheduledTimerWithTimeInterval GAD_REFRESH_PERIOD, target:self, selector:'adTimerTicked', userInfo:nil, repeats:YES
  end

  def viewWillAppear(animated)
    super
    requestAdViewIfDelayed
  end

  def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
    adSize = Device.portrait?(orientation) ? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape
    adView.adSize = adSize
    y = view.frame.height - CGSizeFromGADAdSize(adSize).height
    adView.frame = CGRectMake(0, y, adView.frame.width, adView.frame.height)
    tableView.frame = tableView.frame.change(height: view.bounds.height - adView.frame.height)
  end

  def setupInfoButton 
    infoButton = UIButton.buttonWithType UIButtonTypeInfoLight
    infoButton.addTarget self, action:'showInfo', forControlEvents:UIControlEventTouchUpInside
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView infoButton
  end

  def setupLogConsoleGesture
    if DEBUG
      swipeRecognizer = UISwipeGestureRecognizer.alloc.initWithTarget self, action:'recognizedSwipe:'
      swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft
      view.addGestureRecognizer swipeRecognizer
    end
  end



  def numberOfSectionsInTableView(tableView)
    3
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
      when STATE_SECTION then 2
      when MESSAGE_SECTION then 1
      when ACTIONS_SECTION then 2
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    case Pair.new(indexPath.section, indexPath.row)
    when Pair.new(STATE_SECTION, 0)
      cell = crossingCell
      cell.detailTextLabel.text = Model.currentCrossing.localizedName
    when Pair.new(STATE_SECTION, 1)
      cell = self.stateCell
      nextClosing = Model.currentCrossing.nextClosing
      cell.textLabel.text = "main.allegro will pass at $time".li(Format.munutes_as_hhmm(nextClosing.trainTime))
      cell.detailTextLabel.text = "main.crossing $closes at $time".li(
          Model.currentCrossing.state == Crossing::StateClosed ? "closed".l : "will be closed".l,
          Format.munutes_as_hhmm(nextClosing.closingTime)
      )
    when Pair.new(MESSAGE_SECTION, 0)
      cell = messageCell
      cell.textLabel.adjustsFontSizeToFitWidth = YES
      cell.textLabel.text = Model.currentCrossing.subtitle
      Widgets.styleClosingCell(cell, Model.currentCrossing.color)
    when Pair.new(ACTIONS_SECTION, 0)
      cell = showScheduleCell
    when Pair.new(ACTIONS_SECTION, 1)
      cell = showMapCell
    end

    cell
  end

  def tableView(tableView, titleForFooterInSection:section)
    return "main.footer".l if section == ACTIONS_SECTION
    return nil
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    case tableView.cellForRowAtIndexPath(indexPath)
      when crossingCell then showCrossingListToChangeCurrent
      when showScheduleCell then showCrossingListForSchedule
      when showMapCell then showMap
    end
  end



  def setupAdView
    self.adView = GADBannerView.alloc.initWithAdSize Device.portrait?? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape
    adView.adUnitID = Device.iphone? ? GAD_IPHONE_AD_UNIT_ID : GAD_IPAD_AD_UNIT_ID
    adView.rootViewController = self
    adView.backgroundColor = UIColor.clearColor
    adView.delegate = self
    adView.hidden = YES
    adView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
    adView.origin = CGPointMake(0, App.window.bounds.height - adView.bounds.height)
    
    view.addSubview adView
    requestAdView
  end

  def requestAdView
    adRequest = GADRequest.request
    adRequest.testing = GAD_TESTING_MODE
    adRequest.testDevices = [ GAD_SIMULATOR_ID, GAD_TESTING_IPHONE_ID, GAD_TESTING_IPAD_ID ]

    if location = App.locationManager.location
      adRequest.setLocationWithLatitude location.coordinate.latitude, longitude:location.coordinate.longitude, accuracy:location.horizontalAccuracy
    end

    adView.loadRequest adRequest
  end

  def requestAdViewIfDelayed
    if @adViewRequestPending
      @adViewRequestPending = NO
      requestAdView
    end
  end

  def adTimerTicked
    if adViewLoaded
      if navigationController.visibleViewController == self
        requestAdView
      else
        @adViewRequestPending = YES;
      end
    end
  end

  def adViewDidReceiveAd(adView)
    # if !adViewLoaded
    #   adView.frame = adView.frame.change(y: view.bounds.height)
    #   UIView.animateWithDuration 0.25, animations: -> do
    #     adView.hidden = NO
    #     adView.frame = adView.frame.change(y: view.bounds.height - adView.frame.height)
    #     tableView.frame = tableView.frame.change(height: view.bounds.height - adView.frame.height)
    #   end
    #   @adViewLoaded = YES
    # end
  end

  def adView(view, didFailToReceiveAdWithError:error)
    Log.warn "adView:didFailToReceiveAdWithError: #{error.description}"
  end



  def recognizedSwipe(recognizer)
    point = recognizer.locationInView view
    showLog if point.y > 300
  end

  def modelUpdated
    tableView.reloadData
  end

  def closestCrossingChanged
    tableView.reloadData
  end

  def showInfo
    aboutController = AboutController.alloc.init
    navigationController.pushViewController aboutController, animated:YES
  end

  def showMap
    navigationController.pushViewController App.mapController, animated:YES
  end

  def showCrossingListForSchedule
    crossingsController = CrossingListController.alloc.initWithStyle UITableViewStyleGrouped
    crossingsController.target = self
    crossingsController.action = 'showScheduleForCrossing:'
    crossingsController.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    navigationController.pushViewController crossingsController, animated:YES
  end

  def showCrossingListToChangeCurrent
    crossingsController = CrossingListController.alloc.initWithStyle UITableViewStyleGrouped
    crossingsController.target = self;
    crossingsController.action = 'changeCurrentCrossing:'
    crossingsController.accessoryType = UITableViewCellAccessoryCheckmark;
    navigationController.pushViewController crossingsController, animated:YES
  end

  def showScheduleForCrossing(crossing)
    scheduleController = CrossingScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    scheduleController.crossing = crossing;
    navigationController.pushViewController scheduleController, animated:YES
  end

  def changeCurrentCrossing(crossing)
    Model.currentCrossing = crossing
    navigationController.popViewControllerAnimated YES
    tableView.reloadData
  end
  
  def showLog
    logController = LogViewController.alloc.init
    navigationController.pushViewController logController, animated:YES
  end
  
  def deactivateScreen
    Widgets.styleClosingCell(messageCell, :gray.color)
    messageCell.textLabel.text = ""
  end
  
  def activateScreen
    tableView.reloadData
  end
end
