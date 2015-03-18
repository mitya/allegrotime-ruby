class StatusView < UIView
  attr_accessor :delegate
  attr_accessor :crossingLabel, :messageLabel, :footnoteLabel, :trainStatusLabel, :crossingStatusLabel
  attr_accessor :adView

  TopM = 35 * 2
  TopM_LS = 35
  RowH = 44
  MessageH = 70
  MessageH_LS = 44
  SmallRowH = 28
  ArrowH = 13
  ArrowW = 8
  ArrowRM = 23
  FootnoteTM = 50
  FootnoteTM_LS = 5
  CrossingLabelTag = 500

  def initWithFrame(frame) super
    self.backgroundColor = UIColor.hex 0xefeff4
    NSNotificationCenter.defaultCenter.addObserver self, selector:'deviceRotated', name:UIApplicationWillChangeStatusBarOrientationNotification, object:nil

    @crossingLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Poklonnogorskaya"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.boldSystemFontOfSize(21)
      l.color = UIColor.grayShade 0.2
      l.shadowColor = UIColor.colorWithWhite 0.90, alpha:0.70
      l.shadowOffset = CGSizeMake(1, 1)
      l.backgroundColor = UIColor.whiteColor
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.tag = CrossingLabelTag
      l.userInteractionEnabled = YES

      border = UIView.alloc.initWithFrame(CGRectMake 0, 0, Device.screenWidth, 0.5)
      border.backgroundColor = UIColor.grayShade(0.8)
      border.autoresizingMask = UIViewAutoresizingFlexibleWidth
      l.addSubview border

      arrow = UIImageView.alloc.initWithImage UIImage.imageNamed("images/i-disclosure.png").imageWithRenderingMode(UIImageRenderingModeAlwaysTemplate)
      arrow.tintColor = UIColor.grayShade(0.78)
      l.addSubview arrow
      @crossingLabelArrow = arrow
    end

    @messageLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Will be closed in an hour"
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
      l.textAlignment = NSTextAlignmentCenter
      l.adjustsFontSizeToFitWidth = YES
      l.translatesAutoresizingMaskIntoConstraints = NO
    end

    @crossingStatusLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "crossing status"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.backgroundColor = UIColor.whiteColor
      l.color = UIColor.grayShade(0.4)
      border = UIView.alloc.initWithFrame(CGRectMake 0, 27.5, UIScreen.mainScreen.bounds.size.width, 0.5)
      border.backgroundColor = UIColor.grayShade(0.8)
      border.autoresizingMask = UIViewAutoresizingFlexibleWidth
      l.addSubview border
    end

    @trainStatusLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "train status"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
      l.color = UIColor.grayShade(0.4)
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.backgroundColor = UIColor.whiteColor
      border = UIView.alloc.initWithFrame(CGRectMake 0, 27.5, UIScreen.mainScreen.bounds.size.width, 0.5)
      border.backgroundColor = UIColor.grayShade(0.8)
      border.autoresizingMask = UIViewAutoresizingFlexibleWidth
      l.addSubview border
    end

    @footnoteLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "main.footer".l
      l.color = UIColor.grayShade(0.5)
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
      l.numberOfLines = 0
      l.shadowColor = UIColor.colorWithWhite 1, alpha:1
      l.shadowOffset = CGSizeMake(0, 1)
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.textAlignment = Device.ipad?? NSTextAlignmentCenter : NSTextAlignmentJustified
    end

    @adView = GADBannerView.alloc.initWithAdSize(Device.portrait?? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape).tap do |av|
      av.backgroundColor = UIColor.clearColor
      av.alpha = 0.0
      av.translatesAutoresizingMaskIntoConstraints = NO
    end

    @adViewController = StatusAdViewController.new(@adView)
    
    addSubview @crossingLabel
    addSubview @messageLabel
    addSubview @crossingStatusLabel
    addSubview @trainStatusLabel
    addSubview @footnoteLabel
    addSubview @adView

    setStaticConstraints
    setNeedsUpdateConstraints
    
    @adViewController.requestAd

    return self
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end


  def layoutSubviews
    @crossingLabelArrow.frame = CGRectMake Device.screenWidth - ArrowRM, (RowH-ArrowH)/2, ArrowW, ArrowH
    @footnoteLabel.hidden = Device.landscapePhone?
    @adView.adSize = Device.portrait?? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape  
    super
  end

  def setStaticConstraints
    addConstraints [
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[crossing]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[message]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[trainStatus]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[crossingStatus]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|-[footnote]-|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:[crossingStatus(SmallRowH)]", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:[trainStatus(SmallRowH)]", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:[crossing(RowH)]", options:0, metrics:defaultMetrics, views:views)
    ].flatten
  end

  def updateConstraints
    removeConstraints @dynamicConstraints if @dynamicConstraints
    @dynamicConstraints = [
      NSLayoutConstraint.constraintsWithVisualFormat("V:[message(MessageH)]", options:0, metrics:currentMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:|-TopM-[crossing][message][crossingStatus][trainStatus][ad]-FootnoteTM-[footnote]", options:0, metrics:currentMetrics, views:views),
    ].flatten
    addConstraints @dynamicConstraints
    super
  end


  def deviceRotated
    Device.trackSystem :status_view_rotated, UIApplication.sharedApplication.statusBarOrientation
    setNeedsUpdateConstraints
  end

  def touchesBegan(touches, withEvent:event)
    touch = touches.anyObject
    point = touch.locationInView @crossingLabel
    if touch.view.tag == CrossingLabelTag
      @crossingLabel.backgroundColor = UIColor.grayShade(0.85)
    end
  end

  def touchesEnded(touches, withEvent:event)
    touch = touches.anyObject
    if touch.view.tag == CrossingLabelTag
      point = touch.locationInView(self)
      inside = CGRectContainsPoint @crossingLabel.frame, point
      @crossingLabel.backgroundColor = UIColor.whiteColor
      if inside
        delegate.statusViewCrossingLabelTouched if delegate && delegate.respond_to?(:statusViewCrossingLabelTouched)
      end
    end
  end

  def touchesCancelled(touches, withEvent:event)
    @crossingLabel.backgroundColor = UIColor.whiteColor
  end


  def views
    @views ||= {
      'crossing' => @crossingLabel,
      'message' => @messageLabel,
      'footnote' => @footnoteLabel,
      'trainStatus' => @trainStatusLabel,
      'crossingStatus' => @crossingStatusLabel,
      'ad' => @adView,
    }
  end

  def currentMetrics
    Device.landscapePhone?? landscapeMetrics : defaultMetrics
  end

  def defaultMetrics
    @defaultMetrics ||= {
      'padding' => 20,
      'labelHeight' => 50,
      'labelWidth' => 280,
      'RowH' => RowH,
      'SmallRowH' => SmallRowH,
      'TopM' => TopM,
      'MessageH' => MessageH,
      'FootnoteTM' => FootnoteTM,
    }
  end

  def landscapeMetrics
    @landscapeMetrics ||= begin
      m = @defaultMetrics.dup
      m['MessageH'] = MessageH_LS
      m['TopM'] = TopM_LS
      m['FootnoteTM'] = FootnoteTM_LS
      m
    end
  end


  def setCrossing(crossing)
    crossingLabel.text = crossing.localizedName
    crossingStatusLabel.text = "main.crossing $closes at $time".li \
        crossing.closed? ? "closed".l : "will be closed".l, Format.munutes_as_hhmm(crossing.nextClosing.closingTime)
    trainStatusLabel.text = "main.allegro will pass at $time".li(Format.munutes_as_hhmm(crossing.nextClosing.trainTime))
    messageLabel.text = crossing.subtitle
    messageLabel.backgroundColor = Colors.closingCellBackgroundFor(crossing.color)
    messageLabel.textColor = Colors.messageCellColorFor(crossing.color)
    adView.hidden = NO
  end
  
  def deactivate
    messageLabel.backgroundColor = Colors.closingCellBackgroundFor(:gray.color)
    messageLabel.text = ''
    crossingStatusLabel.text = "main.crossing $closes at $time".li("will be closed".l, '—')
    trainStatusLabel.text = "main.allegro will pass at $time".li('—')
    adView.hidden = YES
  end

  def requestAdIfNeeded
    @adViewController.requestAdIfNeeded
  end
end


class StatusAdViewController 
  attr_accessor :adView
  
  def initialize(adView)
    @adView = adView
    @adView.delegate = self
    @adView.adUnitID = Device.iphone? ? GAD_IPHONE_AD_UNIT_ID : GAD_IPAD_AD_UNIT_ID
    @adView.rootViewController = App.mainController
    @adTimer = NSTimer.scheduledTimerWithTimeInterval GAD_REFRESH_PERIOD, target:self, selector:'adTimerTicked', userInfo:nil, repeats:YES
  end
  
  def requestAd
    return unless ADVERTISEMENT
    adRequest = GADRequest.request
    adRequest.testDevices = [ GAD_TESTING_IPHONE_ID, GAD_TESTING_IPAD_ID ]
    if loc = App.locationManager.location
      adRequest.setLocationWithLatitude loc.coordinate.latitude, longitude:loc.coordinate.longitude, accuracy:loc.horizontalAccuracy 
    end
    adView.loadRequest adRequest
    Device.debug "ad_requested"
  end

  def requestAdIfNeeded
    requestAd if @adRequestPending
    @adRequestPending = NO
  end

  def adTimerTicked
    if adView.window
       requestAd
    else
       @adRequestPending = YES
    end
  end

  def adViewDidReceiveAd(adView)
    Device.trackSystem :ad_received
    UIView.animateWithDuration 1.5, animations: -> { adView.alpha = 1.0 }
  end
  
  def adView(view, didFailToReceiveAdWithError:error)
    Device.trackSystem :ad_failed
    Device.warn "failed receiving ad: #{error.description}"
  end  
end
