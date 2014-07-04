class MainViewController < UIViewController
  attr_accessor :crossingCell, :stateCell, :messageCell, :showScheduleCell, :showMapCell
  attr_accessor :stateCellTopLabel, :stateCellBottomLabel, :tableView
  attr_accessor :adReloadPending
  attr_accessor :bannerView, :adTimer, :bannerViewLoaded, :adReloadPending

  STATE_SECTION = 0
  MESSAGE_SECTION = 1
  ACTIONS_SECTION = 2

  # table_view do
  #   group :state do
  #     cell :crossing, :value1, accessory: 'disclosure', action: 'showCrossingListToChangeCurrent'
  #     cell :state, :default, text_alignment: 'center', detail_alignment: 'center', color: 'darkGray', selection: 'none'
  #   end
  #
  #   group :message do
  #     cell :message, :default, text_alignment: 'center', selection: 'none'
  #   end
  #
  #   group :actions do
  #     cell :show_schedule, :default, accessory: 'disclosure', action: 'showScheduleForCrossing'
  #     cell :show_map, :default, accessory: 'disclosure', action: 'showMap'
  #   end
  # end

  ### lifecycle

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end

  def loadView
    self.crossingCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleValue1, reuseIdentifier:MXDefaultCellID
    crossingCell.textLabel.text = 'main.crossing_cell'.l
    crossingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    
    self.stateCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleSubtitle, reuseIdentifier:MXDefaultCellID
    stateCell.textLabel.textAlignment = NSTextAlignmentCenter
    stateCell.detailTextLabel.textAlignment = NSTextAlignmentCenter
    stateCell.detailTextLabel.textColor = :darkGray.color
    stateCell.selectionStyle = UITableViewCellSelectionStyleNone
    
    self.messageCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:MXDefaultCellID
    messageCell.selectionStyle = UITableViewCellSelectionStyleNone
    messageCell.textLabel.textAlignment = NSTextAlignmentCenter

    self.showScheduleCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:MXDefaultCellID
    showScheduleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    showScheduleCell.textLabel.text = 'main.show_schedule'.l
    
    self.showMapCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:MXDefaultCellID
    showMapCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    showMapCell.textLabel.text = 'main.show_map'.l
    
    self.tableView = UITableView.alloc.initWithFrame CGRectNull, style:UITableViewStyleGrouped
    tableView.delegate = self
    tableView.dataSource = self

    self.view = tableView
  end

  def viewDidLoad
    self.title = "main.title".l
    navigationItem.backBarButtonItem = 
      UIBarButtonItem.alloc.initWithTitle "main.backbutton".l, style:UIBarButtonItemStyleBordered, target:nil, action:nil

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
      cell.detailTextLabel.text = model.currentCrossing.name;
    when Pair.new(STATE_SECTION, 1)
      cell = self.stateCell
      nextClosing = model.currentCrossing.nextClosing
      cell.textLabel.text = "main. allegro will pass at $time".li(Format.munutes_as_hhmm(nextClosing.trainTime))
      cell.detailTextLabel.text = "main. crossing $closes at $time".li(
          model.currentCrossing.state == CrossingStateClosed ? "closed".l : "will be closed".l,
          Format.munutes_as_hhmm(nextClosing.closingTime)
      )
    when Pair.new(MESSAGE_SECTION, 0)
      cell = messageCell
      Widgets.set_gradients_for_cell(cell, model.currentCrossing.color)
      cell.textLabel.adjustsFontSizeToFitWidth = YES
      cell.textLabel.text = model.currentCrossing.subtitle
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
    Log.warn "adView:didFailToReceiveAdWithError: #{error.description}"
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
