class StatusViewController < UIViewController
  attr_accessor :statusView
  attr_accessor :adView, :adTimer, :adViewLoaded  
  
  def init() super
    self.title = "main.title".l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("main.tab".l, image:Device.image_named("ti-semaphore"), selectedImage:Device.image_named("ti-semaphore-filled"))
    self
  end

  def loadView
    self.statusView = StatusView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.statusView.delegate = self
    self.view = statusView
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
  end

  def viewWillAppear(animated) super
    reloadData
    statusView.requestAdIfNeeded
  end


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
    statusView.messageLabel.text = ''
    statusView.messageLabel.backgroundColor = Colors.closingCellBackgroundFor(:gray.color)
    statusView.messageLabel.textColor = Colors.messageCellColorFor(:gray.color)
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
    
    statusView.crossingLabel.text = crossing.localizedName
    statusView.crossingStatusLabel.text = "main.crossing $closes at $time".li \
        crossing.closed? ? "closed".l : "will be closed".l, Format.munutes_as_hhmm(crossing.nextClosing.closingTime)
    statusView.trainStatusLabel.text = "main.allegro will pass at $time".li(Format.munutes_as_hhmm(crossing.nextClosing.trainTime))
    statusView.messageLabel.text = crossing.subtitle
    statusView.messageLabel.backgroundColor = Colors.closingCellBackgroundFor(crossing.color)
    statusView.messageLabel.textColor = Colors.messageCellColorFor(crossing.color)
  end
end
