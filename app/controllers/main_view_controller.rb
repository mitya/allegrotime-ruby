class MainViewController < UIViewController
  attr_accessor :crossingCell, :stateCell, :stateDetailsCell, :showScheduleCell, :showMapCell
  attr_accessor :stateCellTopLabel, :stateCellBottomLabel, :tableView
  attr_accessor :adReloadPending
  attr_accessor :bannerView, :adTimer, :bannerViewLoaded, :adReloadPending

  StateSection = 0
  ActionsSection = 1

  ### lifecycle

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end

  def loadView
    views = NSBundle.mainBundle.loadNibNamed "MainView", owner:self, options:nil    
  
    self.view = views.last
    self.crossingCell = views.detect { |v| v.tag == 11 }
    self.stateCell = views.detect { |v| v.tag == 23 }
    self.stateDetailsCell = views.detect { |v| v.tag == 12 }
    self.showScheduleCell = views.detect { |v| v.tag == 24 }
    self.showMapCell = views.detect { |v| v.tag == 15 }
    self.stateCellTopLabel = stateCell.viewWithTag(31)
    self.stateCellBottomLabel = stateCell.viewWithTag(32)

    self.tableView = view.subviews.detect { |v| UITableView === v }
    tableView.delegate = self
    tableView.dataSource = self
  end

  def viewDidLoad
    self.title = T("main.title");
    navigationItem.backBarButtonItem = 
      UIBarButtonItem.alloc.initWithTitle T("main.backbutton"), style:UIBarButtonItemStyleBordered, target:nil, action:nil

    NSNotificationCenter.defaultCenter.addObserver self, selector:'closestCrossingChanged', name:NXClosestCrossingChanged, object:nil

    createInfoButton
    setupBanner
    setupLogConsoleGesture

    self.adTimer = NSTimer.scheduledTimerWithTimeInterval GAD_REFRESH_PERIOD, target:self, selector:'adTimerTicked', userInfo:nil, repeats:YES
  end

  def viewWillAppear(animated)
    super
    performDelayedBannerReload
  end

  def createInfoButton 
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

  def performDelayedBannerReload
    if adReloadPending
      @adReloadPending = NO
      reloadBanner
    end
  end

  ### table view stuff

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return 3 if (section == StateSection)
    return 2 if (section == ActionsSection)
    return 0
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    if indexPath.section == StateSection && indexPath.row == 0
      cell = crossingCell
      cell.detailTextLabel.text = model.currentCrossing.name;
    elsif indexPath.section == StateSection && indexPath.row == 1
      cell = stateCell;
      nextClosing = model.currentCrossing.nextClosing;
      stateCellTopLabel.text = TF("main. allegro will pass at $time", Helper.formatTimeInMunutesAsHHMM(nextClosing.trainTime))
      stateCellBottomLabel.text = TF("main. crossing $closes at $time",
          model.currentCrossing.state == CrossingStateClosed ? "закрыли" : "закроют",
          Helper.formatTimeInMunutesAsHHMM(nextClosing.closingTime));
    elsif indexPath.section == StateSection && indexPath.row == 2
      cell = stateDetailsCell
      MXSetGradientForCell(cell, model.currentCrossing.color)
      cell.textLabel.adjustsFontSizeToFitWidth = YES
      cell.textLabel.text = model.currentCrossing.subtitle
    elsif indexPath.section == ActionsSection
      cell = showScheduleCell if indexPath.row == 0
      cell = showMapCell if indexPath.row == 1
    end

    cell
  end

  def tableView(tableView, titleForFooterInSection:section)
    return T("main.footer") if section == ActionsSection
    return nil
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    cell = tableView.cellForRowAtIndexPath indexPath

    if cell == crossingCell
      showCrossingListToChangeCurrent
    elsif cell == showScheduleCell
      showCrossingListForSchedule
    elsif cell == showMapCell
      showMap
    end
  end

  ### banner

  def setupBanner
    self.bannerView = GADBannerView.alloc.initWithAdSize IPHONE ? KGADAdSizeBanner : KGADAdSizeLeaderboard
    bannerView.adUnitID = IPHONE ? GAD_IPHONE_KEY : GAD_IPAD_KEY;
    bannerView.rootViewController = self;
    bannerView.backgroundColor = UIColor.clearColor;
    bannerView.delegate = self;
    bannerView.hidden = YES;
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    bannerView.frame = CGRectMake(
      bannerView.bounds.origin.x, view.bounds.size.height - bannerView.bounds.size.height,
      bannerView.bounds.size.width, bannerView.bounds.size.height
    )

    view.addSubview bannerView
    reloadBanner
  end

  def reloadBanner
    adRequest = GADRequest.request
    adRequest.testing = GAD_TESTING_MODE
    adRequest.testDevices = [ GAD_SIMULATOR_ID, '398a17d1387d6fa3ac0e24597718c091' ]

    location = app.locationManager.location
    if location
      adRequest.setLocationWithLatitude location.coordinate.latitude,
        longitude:location.coordinate.longitude, accuracy:location.horizontalAccuracy
    end

    bannerView.loadRequest adRequest
  end

  def adTimerTicked
    if bannerViewLoaded
      if navigationController.visibleViewController == self
        reloadBanner
      else
        @adReloadPending = YES;
      end
    end
  end

  def adViewDidReceiveAd(banner)
    if !bannerViewLoaded
      bannerView.frame = CGRectMake(banner.frame.origin.x, view.bounds.size.height, banner.frame.size.width, banner.frame.size.height);
      UIView.animateWithDuration 0.25, animations: -> do
        banner.hidden = NO;
        banner.frame = CGRectMake(banner.frame.origin.x, view.bounds.size.height - banner.frame.size.height, 
          banner.frame.size.width, banner.frame.size.height);
      end
      @bannerViewLoaded = YES;
    end
  end

  def adView(view, didFailToReceiveAdWithError:error)
    Helper.warn "adView:didFailToReceiveAdWithError: %@", error
  end

  ### handlers

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
    navigationController.pushViewController app.mapController, animated:YES
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

  def showLog
    logController = LogViewController.alloc.init
    navigationController.pushViewController logController, animated:YES
  end

  def changeCurrentCrossing(crossing)
    model.setCurrentCrossing crossing
    navigationController.popViewControllerAnimated YES
    tableView.reloadData
  end
end
