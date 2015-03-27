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
      message = "DEBUG #{format % args}"
      puts message if SIMULATOR
      
      message = "[#{Time.now.strftime('%d.%m %H:%M:%S')}] #{message}"
      
      if $logging_buffer.count > 200
        $logging_buffer.clear
        NSNotificationCenter.defaultCenter.postNotificationName NXDefaultCellIDLogConsoleFlushed, object:$logging_buffer
      end      
      
      $logging_buffer << message
      NSNotificationCenter.defaultCenter.postNotificationName NXDefaultCellIDLogConsoleUpdated, object:$logging_buffer
    end    
  end

  def warn(message, *args)
    debug(message, *args) if DEBUG
    NSLog message % args
  end
  
  def gai
    GAI.sharedInstance.defaultTracker
  end
  
  def trackUI(action, label=nil)
    track :ui, action, label
  end
  
  def trackSystem(action, label=nil)
    track :sys, action, label    
  end
  
  def track(category, action, label=nil)
    return unless TRACKING
    
    label = label.to_tracking_key if label && label.respond_to?(:to_tracking_key)
    
    gai.send GAIDictionaryBuilder.createEventWithCategory(category.to_s, action: action.to_s, label: label, value: nil).build

    full_action_name = "#{category}:#{action}"
    if label
      flurry_params = {}
      flurry_params['label'] = label if label
      Flurry.logEvent full_action_name, withParameters:flurry_params
    else
      Flurry.logEvent full_action_name
    end
    
    debug "EVENT #{full_action_name} [#{label}]" if DEBUG
  end
  
  def trackScreen(screenName, key=nil)
    return unless TRACKING

    key = key.to_tracking_key if key && key.respond_to?(:to_tracking_key)
    
    gai.set KGAIScreenName, value: screenName.to_s
    gai.send GAIDictionaryBuilder.createScreenView.build    
    
    Flurry.logPageView
    Flurry.logEvent "screen:#{screenName}", withParameters:{key: key}
    
    debug "SCREEN #{screenName} [#{key}]" if DEBUG
  end
  
  def minutes_from_hhmm(string)
    components = string.componentsSeparatedByString ":"
    hours = components.objectAtIndex(0).integerValue
    minutes = components.objectAtIndex(1).integerValue
    hours * 60 + minutes
  end  
end
