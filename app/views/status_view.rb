class StatusView < UIView
  attr_accessor :delegate
  attr_accessor :crossingLabel, :messageLabel, :footnoteLabel, :trainStatusLabel, :crossingStatusLabel
  attr_accessor :adView

  TopM = 25 * 2
  TopM_LS = 25
  RowH = 50
  RowH_LS = 44
  MessageH = 50
  MessageH_LS = 44
  SmallRowH = 25
  ArrowH = 13
  ArrowW = 8
  ArrowRM = 23
  FootnoteTM = 25
  FootnoteTM_LS = 5
  CrossingLabelTag = 500
  BottomM = 25

  def initWithFrame(frame) super
    self.backgroundColor = UIColor.hex 0xefeff4
    self.translatesAutoresizingMaskIntoConstraints = NO

    @crossingLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.boldSystemFontOfSize(21)
      l.color = UIColor.grayShade 0.2
      l.shadowColor = UIColor.colorWithWhite 0.90, alpha:0.70
      l.shadowOffset = CGSizeMake(1, 1)
      l.backgroundColor = UIColor.whiteColor
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.autoresizingMask = UIViewAutoresizingFlexibleWidth
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
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
      l.textAlignment = NSTextAlignmentCenter
      l.adjustsFontSizeToFitWidth = YES
      l.autoresizingMask = UIViewAutoresizingFlexibleWidth
      l.translatesAutoresizingMaskIntoConstraints = NO
    end

    @crossingStatusLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
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

    # @footnoteLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
    #   l.color = UIColor.grayShade(0.5)
    #   l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    #   l.numberOfLines = 0
    #   l.shadowColor = UIColor.colorWithWhite 1, alpha:1
    #   l.shadowOffset = CGSizeMake(0, 1)
    #   l.translatesAutoresizingMaskIntoConstraints = NO
    #   l.textAlignment = Device.ipad?? NSTextAlignmentCenter : NSTextAlignmentJustified
    #
    #   email = "allegrotime@yandex.ru"
    #   string = "ВНИМАНИЕ: Расписание Аллегро сильно изменилось, и к сожалению у меня в данный момент нет нового расписания, и так как я больше не байкер, то объезжать все переезды мне очень неохота. Я постараюсь достать его из РЖД, а пока что приложение отображает расписание только Удельной, Шувалово и Песочной. Если вам не трудно вы можете прислать фото синей таблички с расписанием расположенной у любого другого переезда на #{email} и я добавлю его в приложение."
    #   text = NSMutableAttributedString.alloc.init
    #   text.appendAttributedString NSAttributedString.alloc.initWithString(string)
    #   text.addAttribute NSLinkAttributeName, value: "mailto:#{email}", range: NSMakeRange(string.index(email), email.length)
    #
    #   l.userInteractionEnabled = YES
    #   l.attributedText = text
    # end

    @footnoteLabel = UITextView.alloc.initWithFrame(CGRectZero).tap do |l|
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.editable = NO
      l.textColor = UIColor.grayShade(0.5)
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
      l.backgroundColor = UIColor.clearColor
      l.textAlignment = Device.ipad?? NSTextAlignmentCenter : NSTextAlignmentCenter
      l.dataDetectorTypes = UIDataDetectorTypeLink
      l.scrollEnabled = NO
      l.layer.shadowColor = UIColor.colorWithWhite 1, alpha:1
      l.layer.shadowOffset = CGSizeMake(0, 1)

      string = "new_footnote".l

      l.text = string
    end

    if Env.ads?
      @adView = GADBannerView.alloc.initWithAdSize(KGADAdSizeBanner)
      if @adView
        # @adView = GADBannerView.alloc.initWithAdSize(Device.ipad?? KGADAdSizeMediumRectangle : KGADAdSizeLargeBanner).tap do |av|
        # @adView = GADBannerView.alloc.initWithAdSize(Device.portrait?? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape).tap do |av|
        # @adView = GADBannerView.alloc.initWithAdSize(Device.ipad?? GADAdSizeFromCGSize(CGSizeMake(728, 90)) : KGADAdSizeLargeBanner).tap do |av|
        # @adView = GADBannerView.alloc.initWithAdSize(GADAdSizeFromCGSize(CGSizeMake(728, 90))).tap do |av|        
        @adView.backgroundColor = UIColor.clearColor
        @adView.alpha = 0.0
        @adView.translatesAutoresizingMaskIntoConstraints = NO
        @adViewController = StatusAdViewController.new(@adView)
      else
        @adView = UIView.alloc.init
        @adView.translatesAutoresizingMaskIntoConstraints = NO
      end
    else
      @adView = UIView.alloc.init
      @adView.translatesAutoresizingMaskIntoConstraints = NO
    end

    addSubview @crossingLabel
    addSubview @messageLabel
    addSubview @crossingStatusLabel
    addSubview @trainStatusLabel
    addSubview @footnoteLabel
    addSubview @adView

    setStaticConstraints
    setNeedsUpdateConstraints

    @adViewController.requestAd if @adViewController

    return self
  end

  def dealloc
    # NSNotificationCenter.defaultCenter.removeObserver self
  end


  def layoutSubviews
    @crossingLabelArrow.frame = CGRectMake Device.screenWidth - ArrowRM, (RowH-ArrowH)/2, ArrowW, ArrowH
    # @adView.adSize = Device.portrait?? KGADAdSizeSmartBannerPortrait : KGADAdSizeSmartBannerLandscape if Env.ads?
    super
  end



  def staticConstraints
    [ NSLayoutConstraint.constraintsWithVisualFormat("H:|[crossing]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[message]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[trainStatus]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[crossingStatus]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|[ad]|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("H:|-[footnote]-|", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:[crossingStatus(SmallRowH)]", options:0, metrics:defaultMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:[trainStatus(SmallRowH)]", options:0, metrics:defaultMetrics, views:views),      
    ].flatten
  end

  def setStaticConstraints
    addConstraints staticConstraints
  end

  def updateConstraints
    removeConstraints @dynamicConstraints if @dynamicConstraints
    @dynamicConstraints = [
      NSLayoutConstraint.constraintsWithVisualFormat("V:[crossing(RowH)]", options:0, metrics:currentMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:[message(MessageH)]", options:0, metrics:currentMetrics, views:views),
      NSLayoutConstraint.constraintsWithVisualFormat("V:|-TopM-[crossing][message][crossingStatus][trainStatus][ad]-FootnoteTM-[footnote]-BottomM-|", options:0, metrics:currentMetrics, views:views),
    ].flatten
    addConstraints @dynamicConstraints
    super
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
      'RowH' => RowH,
      'SmallRowH' => SmallRowH,
      'TopM' => TopM,
      'MessageH' => MessageH,
      'FootnoteTM' => FootnoteTM,
      'BottomM' => BottomM,
    }
  end

  def landscapeMetrics
    @landscapeMetrics ||= begin
      m = @defaultMetrics.dup
      m['MessageH'] = MessageH_LS
      m['RowH'] = RowH_LS
      m['TopM'] = TopM_LS
      m['BottomM'] = TopM_LS
      m['FootnoteTM'] = FootnoteTM_LS
      m
    end
  end


  def setCrossing(crossing)
    crossingLabel.text = crossing.localizedName
    messageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    messageLabel.backgroundColor = Colors.closingCellBackgroundFor(crossing.color)
    messageLabel.textColor = Colors.messageCellColorFor(crossing.color)
    if crossing.hasSchedule?
      messageLabel.text = crossing.subtitle
      crossingStatusLabel.text = "main.crossing $closes at $time".li \
          crossing.closed? ? "closed".l : "will be closed".l, Format.munutes_as_hhmm(crossing.nextClosing.closingTime)
      trainStatusLabel.text = "main.allegro will pass at $time".li(Format.munutes_as_hhmm(crossing.nextClosing.trainTime))
    elsif crossing.name == 'Поклонногорская'
      messageLabel.text = " #{crossing.subtitle} "
      crossingStatusLabel.text = 'poklonnogorskaya_open_estimate'.l
      trainStatusLabel.text = ''
    else
      messageLabel.text = 'no_schedule'.l
      crossingStatusLabel.text = ''
      trainStatusLabel.text = ''
    end

    adView.hidden = NO
  end

  def deactivate
    messageLabel.backgroundColor = Colors.closingCellBackgroundFor(:gray.color)
    messageLabel.font = UIFont.systemFontOfSize(32)
    messageLabel.text = ''
    crossingStatusLabel.text = ''
    trainStatusLabel.text = ''
    adView.hidden = YES
  end

  def requestAdIfNeeded
    @adViewController.requestAdIfNeeded if @adViewController
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
    return unless Env::ads?
    adRequest = GADRequest.request
    adRequest.testDevices = [ GAD_TESTING_IPHONE_ID, GAD_TESTING_IPAD_ID ] if DEBUG
    if loc = App.locationManager.location
      adRequest.setLocationWithLatitude loc.coordinate.latitude, longitude:loc.coordinate.longitude, accuracy:loc.horizontalAccuracy
    end
    adView.loadRequest adRequest
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
    Device.warn "Failed receiving ad: #{error.description}"
  end
end
