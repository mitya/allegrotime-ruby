class StatusView < UIView
  attr_accessor :delegate
  attr_accessor :crossingLabel, :messageLabel, :footnoteLabel, :trainStatusLabel, :crossingStatusLabel

  TopM = 35 * 2
  TopM_LS = 35
  RowH = 44
  MessageH = 70
  MessageH_LS = 44
  SmallRowH = 28
  ArrowH = 13
  ArrowW = 8
  ArrowRM = 23
  FootnoteTM = 70
  FootnoteTM_LS = 5
  CrossingLabelTag = 500

  def initWithFrame(frame) super
    self.backgroundColor = UIColor.hex 0xefeff4
    NSNotificationCenter.defaultCenter.addObserver self, selector:'onRotation', name:UIApplicationWillChangeStatusBarOrientationNotification, object:nil

    @crossingLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Poklonnogorskaya"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.boldSystemFontOfSize(22)
      l.color = UIColor.grayShade 0.2
      l.shadowColor = UIColor.colorWithWhite 1, alpha:1
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
      l.color = UIColor.grayShade(0.6)
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
      l.numberOfLines = 0
      l.shadowColor = UIColor.colorWithWhite 1, alpha:1
      l.shadowOffset = CGSizeMake(0, 1)
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.textAlignment = NSTextAlignmentJustified
    end

    addSubview @crossingLabel
    addSubview @messageLabel
    addSubview @crossingStatusLabel
    addSubview @trainStatusLabel
    addSubview @footnoteLabel

    setStaticConstraints
    setNeedsUpdateConstraints

    # layer.borderColor = UIColor.greenColor.CGColor
    # layer.borderWidth = 1

    return self
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end

  def layoutSubviews
    @crossingLabelArrow.frame = CGRectMake Device.screenWidth - ArrowRM, (RowH-ArrowH)/2, ArrowW, ArrowH
    @footnoteLabel.hidden = Device.landscapePhone?
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
      NSLayoutConstraint.constraintsWithVisualFormat("V:|-TopM-[crossing][message][crossingStatus][trainStatus]-FootnoteTM-[footnote]", options:0, metrics:currentMetrics, views:views),
    ].flatten
    addConstraints @dynamicConstraints
    super
  end


  def onRotation
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
    puts "touchesCancelled is never called?"
  end


  def views
    @views ||= {
      'crossing' => @crossingLabel,
      'message' => @messageLabel,
      'footnote' => @footnoteLabel,
      'trainStatus' => @trainStatusLabel,
      'crossingStatus' => @crossingStatusLabel
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
end


# addConstraint NSLayoutConstraint.constraintWithItem @crossingLabel, attribute:NSLayoutAttributeHeight, relatedBy:NSLayoutRelationEqual, \
#     toItem:@messageLabel, attribute:NSLayoutAttributeHeight, multiplier:2, constant:0.0
