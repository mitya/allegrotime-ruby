class StatusViewController < UIViewController
  attr_accessor :statusView
  attr_accessor :adView, :adTimer, :adViewLoaded  
  attr_accessor :lastAccessTime
  
  def init() super
    self.title = "main.title".l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("main.tab".l, image:Device.image_named("ti-semaphore"), selectedImage:Device.image_named("ti-semaphore-filled"))
    self
  end

  def dealloc
    Device.removeObserver self
  end

  def loadView
    self.statusView = StatusView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.statusView.delegate = self
    self.view = statusView
  end

  def viewDidLoad() super
    # setup info button
    infoButton = UIButton.buttonWithType UIButtonTypeInfoLight
    infoButton.addTarget self, action:'showInfo', forControlEvents:UIControlEventTouchUpInside
    navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithCustomView infoButton

    # setup log console gestures
    if DEBUG
      swipeRecognizer = UISwipeGestureRecognizer.alloc.initWithTarget self, action:'recognizedSwipe:'
      swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft
      view.addGestureRecognizer swipeRecognizer
    end

    titleLabel = UILabel.alloc.initWithFrame(CGRectZero)
    titleLabel.text = "main.title".l
    titleLabel.font = UIFont.fontWithName('HelveticaNeue-BoldItalic', size: 17)
    titleLabel.textColor = UIColor.grayShade 0.2
    titleLabel.sizeToFit

    navigationItem.titleView = titleLabel
    navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle "main.backbutton".l, style:UIBarButtonItemStyleBordered, target:nil, action:nil
    
    Device.addObserver self, 'modelUpdated', ATModelUpdated
  end

  def viewWillAppear(animated) super
    Device.trackScreen :status, Model.currentCrossing
    reloadData
    setupSelectClosestCrossingButton
    statusView.requestAdIfNeeded
    @lastAccessTime = Time.now
  end


  def recognizedSwipe(recognizer)
    point = recognizer.locationInView view
    showLog if point.y > 300
  end

  def modelUpdated
    puts "update status"
    reloadData
    setupSelectClosestCrossingButton
  end

  def screenDeactivated
    statusView.deactivate
  end

  def statusViewCrossingLabelTouched
    showCrossingListToChangeCurrent
  end


  def showCrossingListToChangeCurrent
    crossingsController = CrossingListController.alloc.initWithStyle UITableViewStyleGrouped
    crossingsController.target = self
    crossingsController.action = 'changeCurrentCrossing:'
    crossingsController.accessoryType = UITableViewCellAccessoryCheckmark
    crossingsController.screenName = "status.crossing_list"
    navigationController.pushViewController crossingsController, animated:YES
  end

  def changeCurrentCrossing(crossing)
    Model.currentCrossing = crossing    
    navigationController.popViewControllerAnimated YES
    reloadData
  end
  
  def selectClosestCrossing
    Model.currentCrossing = Model.closestCrossing
    reloadData
    setupSelectClosestCrossingButton
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
    statusView.setCrossing Model.currentCrossing
  end
  
  def setupSelectClosestCrossingButton
    @selectClosestCrossingButton ||= UIBarButtonItem.alloc.initWithImage Device.image_named("bb-define_location"), style:UIBarButtonItemStylePlain, target:self, action:'selectClosestCrossing'
    navigationItem.rightBarButtonItem = Model.closestCrossing && Model.currentCrossing != Model.closestCrossing ? @selectClosestCrossingButton : nil
  end
end
