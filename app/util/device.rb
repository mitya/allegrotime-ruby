module Device
  module_function
  
  def image_named(filename)
    UIImage.imageNamed "images/#{filename}.png"
  end
  
  # 'ru' or 'en'
  def language
    'lang'.l
  end
  
  def portrait?(orientation = UIApplication.sharedApplication.statusBarOrientation)
     orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown
  end  
  
  def landscape?
    !portrait?
  end

  def iphone?
    $device_is_iphone != nil ? $device_is_iphone : $device_is_iphone = 
      UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
  end
  
  def ipad?
    !iphone?
  end
  
  def landscapePhone?
    iphone? && landscape?
  end
  
  def roundedCornersFor(view, withRadius:radius, width:width, color:color)
    view.layer.cornerRadius = radius
    view.layer.borderColor = color.CGColor
    view.layer.borderWidth = width
    view.layer.masksToBounds = true     
  end
  
  def screenSize
    UIScreen.mainScreen.bounds
  end

  def screenWidth
    screenSize.width
  end

  def screenHeight
    screenSize.height
  end
  
  def currentTimeInMunutes
    Time.now.to_i / 60
  end
  
  def debug(format, *args)
    if DEBUG
      message = format % args
      # NSLog message
      
      message = "[#{Time.now.strftime('%d.%m %H:%M:%S')}] #{message}"
      
      if $logging_buffer.count > 200
        $logging_buffer.clear
        NSNotificationCenter.defaultCenter.postNotificationName ATLogConsoleFlushed, object:$logging_buffer
      end      
      
      $logging_buffer << message
      NSNotificationCenter.defaultCenter.postNotificationName ATLogConsoleUpdated, object:$logging_buffer
    end    
  end

  def warn(message, *args)
    debug(message, *args) if DEBUG
    NSLog message % args
  end
  
  def gai
    if Env::TRACKING_GA
      @gai ||= GAI.sharedInstance.defaultTracker
    else
      nil
    end
  end
  
  def flurry
    if Env::TRACKING_FLURRY
      @flurry ||= Flurry
    else
      nil
    end
  end
  
  def trackUI(action, label=nil)
    track :ui, action, label
  end
  
  def trackSystem(action, label=nil)
    track :sys, action, label    
  end
  
  def track(category, action, label=nil)
    return unless Env::TRACKING
    
    action_name = "#{category}:#{action}"
    label = label.to_tracking_key if label && label.respond_to?(:to_tracking_key)
    
    if gai
      gai.send GAIDictionaryBuilder.createEventWithCategory(category.to_s, action: action.to_s, label: label, value: nil).build
    end

    if flurry
      if label
        flurry_params = {'label' => label}
        flurry.logEvent action_name, withParameters:flurry_params
      else
        flurry.logEvent action_name
      end
    end
    
    debug "EVENT #{action_name} [#{label}]" if DEBUG
  end
  
  def trackScreen(screenName, key=nil)
    return unless Env::TRACKING

    key = key.to_tracking_key if key && key.respond_to?(:to_tracking_key)
    
    if gai
      gai.set KGAIScreenName, value: screenName.to_s
      gai.send GAIDictionaryBuilder.createScreenView.build
    end
    
    if flurry
      flurry.logPageView
      flurry.logEvent "screen:#{screenName}", withParameters:{key: key}
    end
    
    debug "SCREEN #{screenName} [#{key}]" if DEBUG
  end
  
  def minutes_from_hhmm(string)
    components = string.componentsSeparatedByString ":"
    hours = components.objectAtIndex(0).integerValue
    minutes = components.objectAtIndex(1).integerValue
    hours * 60 + minutes
  end
  
  def minutes_from_military_string(string)
    hours = string[0..1].integerValue
    minutes = string[2..3].integerValue
    hours * 60 + minutes
  end
  
  def testTrackers
    5.times do
      Device.trackScreen :test_screen1, Model.currentCrossing
      Device.trackUI :test_tap_button2
      Device.trackScreen :test_screen2, Model.currentCrossing
      Device.trackSystem :test_system_event2
      Device.trackUI :test_tap_button3
      Device.trackScreen :test_screen3, Model.currentCrossing
      Device.trackSystem :test_system_event1
      Device.trackUI :test_tap_button1
      Device.trackScreen :test_screen1, Model.currentCrossing
      Device.trackUI :test_tap_button2
      Device.trackScreen :test_screen2, Model.currentCrossing
      Device.trackSystem :test_system_event3
    end
  end
  
  def addObserver(observer, selector, event)
    NSNotificationCenter.defaultCenter.addObserver observer, selector:selector, name:event, object:nil
  end
  
  def removeObserver(observer)
    NSNotificationCenter.defaultCenter.removeObserver(observer)
  end
  
  def notify(event)
    NSNotificationCenter.defaultCenter.postNotificationName(event)
  end
end
