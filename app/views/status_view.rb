class StatusView < UIView
  attr_accessor :delegate
  attr_accessor :crossingLabel, :messageLabel, :footnoteLabel, :trainStatusLabel, :crossingStatusLabel

  TopM = 35 * 2
  RowH = 44
  MessageH = 70
  SmallRowH = 28
  ArrowH = 13
  ArrowW = 8
  ArrowRM = 23
  CrossingLabelTag = 500

  def initWithFrame(frame) super
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
      arrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
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
      border = UIView.alloc.initWithFrame(CGRectMake 0, 0, UIScreen.mainScreen.bounds.size.width, 0.5)
      border.backgroundColor = UIColor.grayShade(0.8)
      border.autoresizingMask = UIViewAutoresizingFlexibleWidth
      l.addSubview border
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
    addSubview @trainStatusLabel
    addSubview @crossingStatusLabel
    addSubview @footnoteLabel

    @viewMap = { 'crossing' => @crossingLabel, 'message' => @messageLabel, 'footnote' => @footnoteLabel,
        'trainStatus' => @trainStatusLabel, 'crossingStatus' => @crossingStatusLabel }
    @metrics = { 'padding' => 20, 'labelHeight' => 50, 'labelWidth' => 280, 'RowH' => RowH, 'SmallRowH' => SmallRowH, 'TopM' => TopM, 'MessageH' => MessageH }

    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossing(RowH)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[message(MessageH)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossingStatus(SmallRowH)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[trainStatus(SmallRowH)]", options:0, metrics:@metrics, views:@viewMap
    
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:|-TopM-[crossing][message][trainStatus][crossingStatus]-70-[footnote]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[crossing]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[message]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[trainStatus]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[crossingStatus]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[footnote]-|", options:0, metrics:@metrics, views:@viewMap

    # addConstraint NSLayoutConstraint.constraintWithItem @crossingLabel, attribute:NSLayoutAttributeHeight, relatedBy:NSLayoutRelationEqual, \
    #     toItem:@messageLabel, attribute:NSLayoutAttributeHeight, multiplier:2, constant:0.0

    self.backgroundColor = UIColor.hex 0xefeff4
    self
  end

  def layoutSubviews
    @crossingLabelArrow.frame = CGRectMake Device.screenWidth - ArrowRM, (RowH-ArrowH)/2, ArrowW, ArrowH
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
    puts "touchesCancelled is never called?"
  end
end
