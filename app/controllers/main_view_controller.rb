class MainViewController < UIViewController
  attr_accessor :tableView
  attr_accessor :crossingCell, :stateCell, :messageCell
  attr_accessor :stateCellTopLabel, :stateCellBottomLabel
  attr_accessor :adView, :adTimer, :adViewLoaded

  STATE_SECTION = 0
  MESSAGE_SECTION = 1
  ACTIONS_SECTION = 2



  def init() super
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
    
    self.stateCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleSubtitle, reuseIdentifier:NXDefaultCellID
    stateCell.textLabel.textAlignment = NSTextAlignmentCenter
    stateCell.detailTextLabel.textAlignment = NSTextAlignmentCenter
    stateCell.detailTextLabel.textColor = :darkGray.color
    stateCell.selectionStyle = UITableViewCellSelectionStyleNone
    
    self.messageCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:NXDefaultCellID
    messageCell.selectionStyle = UITableViewCellSelectionStyleNone
    messageCell.textLabel.textAlignment = NSTextAlignmentCenter
    
    self.tableView = UITableView.alloc.initWithFrame view.bounds, style:UITableViewStyleGrouped
    tableView.delegate = self
    tableView.dataSource = self
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    
    self.view.addSubview(tableView)
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
    
    setupAdView

    self.adTimer = NSTimer.scheduledTimerWithTimeInterval GAD_REFRESH_PERIOD, target:self, selector:'adTimerTicked', userInfo:nil, repeats:YES
  end

  def viewWillAppear(animated) super
    requestAdViewIfDelayed
  end

  def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
    puts 'willAnimateRotationToInterfaceOrientation'
    adSize = Device.portrait?(orientation) ? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape
    adView.adSize = adSize
    y = view.frame.height - CGSizeFromGADAdSize(adSize).height
    adView.frame = CGRectMake(0, y, adView.frame.width, adView.frame.height)
    tableView.frame = tableView.frame.change(height: view.bounds.height - adView.frame.height)
  end



  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
      when STATE_SECTION then 2
      when MESSAGE_SECTION then 1
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    case indexPath
    when NSIndexPath.indexPathForRow(0, inSection:STATE_SECTION)
      cell = crossingCell
      cell.detailTextLabel.text = Model.currentCrossing.localizedName
    when NSIndexPath.indexPathForRow(1, inSection:STATE_SECTION)
      cell = self.stateCell
      nextClosing = Model.currentCrossing.nextClosing
      cell.textLabel.text = "main.allegro will pass at $time".li(Format.munutes_as_hhmm(nextClosing.trainTime))
      cell.detailTextLabel.text = "main.crossing $closes at $time".li(
          Model.currentCrossing.state == Crossing::StateClosed ? "closed".l : "will be closed".l,
          Format.munutes_as_hhmm(nextClosing.closingTime)
      )
    when NSIndexPath.indexPathForRow(0, inSection:MESSAGE_SECTION)
      cell = messageCell
      cell.textLabel.adjustsFontSizeToFitWidth = YES
      cell.textLabel.text = Model.currentCrossing.subtitle
      Widgets.styleClosingCell(cell, Model.currentCrossing.color)
    end    
    return cell
  end

  def tableView(tableView, titleForFooterInSection:section)
    return "main.footer".l if section == MESSAGE_SECTION
    return nil
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    case tableView.cellForRowAtIndexPath(indexPath)
      when crossingCell then showCrossingListToChangeCurrent
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
    puts 'requesting ad'
    adRequest = GADRequest.request
    adRequest.testDevices = [ GAD_TESTING_IPHONE_ID, GAD_TESTING_IPAD_ID ]

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
        @adViewRequestPending = YES
      end
    end
  end

  def adViewDidReceiveAd(adView)
    puts 'receive an ad'
    if !adViewLoaded
      adView.frame = adView.frame.change(y: view.bounds.height)
      UIView.animateWithDuration 0.25, animations: -> do
        adView.hidden = NO
        adView.frame = adView.frame.change(y: view.bounds.height - adView.frame.height)
        tableView.frame = tableView.frame.change(height: view.bounds.height - adView.frame.height)
      end
      @adViewLoaded = YES
    end
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
  
  def screenDeactivated
    Widgets.styleClosingCell(messageCell, :gray.color)
    messageCell.textLabel.text = ""
  end
  
  def screenActivated
    tableView.reloadData
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
    tableView.reloadData
  end

  def showInfo
    aboutController = AboutController.alloc.init
    navigationController.pushViewController aboutController, animated:YES
  end
  
  def showLog
    logController = LogViewController.alloc.init
    navigationController.pushViewController logController, animated:YES
  end
end
