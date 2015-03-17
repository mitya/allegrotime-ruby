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
      puts message
      
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
  
  def tracker
    GAI.sharedInstance.defaultTracker
  end
  
  def track(action, label=nil, value=nil)
    tracker.send GAIDictionaryBuilder.createEventWithCategory('ui', action: action.to_s, label: label, value: value).build
    debug "EVENT #{action} '#{label}' (#{value})" if DEBUG
  end
  
  def trackScreen(screenName, key=nil)
    tracker.set KGAIScreenName, value: screenName.to_s
    tracker.send GAIDictionaryBuilder.createScreenView.build    
    debug "SCREEN #{screenName} [#{key}]" if DEBUG
  end
end
