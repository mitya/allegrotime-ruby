class StatusView < UIView
  attr_accessor :crossingLabel, :messageLabel, :footnoteLabel, :trainStatusLabel, :crossingStatusLabel

  TopM = 35 * 2
  RowH = 44
  SmallRowH = 28
  ArrowH = 13
  ArrowW = 8
  ArrowRM = 23
  CrossingLabelTag = 500

  def initWithFrame(frame) super
    @crossingLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Poklonnogorskaya"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.boldSystemFontOfSize(24)
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


      # label.userInteractionEnabled = YES;
      # UITapGestureRecognizer *tapGesture =
      #       [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
      # [label addGestureRecognizer:tapGesture];
      

      arrow = UIImageView.alloc.initWithImage UIImage.imageNamed("images/i-disclosure.png").imageWithRenderingMode(UIImageRenderingModeAlwaysTemplate)
      arrow.tintColor = UIColor.grayShade(0.78)
      arrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
      l.addSubview arrow
      @crossingLabelArrow = arrow
      $arrow = arrow
      
      #
      # border = UIView.alloc.initWithFrame(CGRectMake 0, 43.5, UIScreen.mainScreen.bounds.size.width, 0.5)
      # border.backgroundColor = UIColor.grayShade(0.8)
      # border.autoresizingMask = UIViewAutoresizingFlexibleWidth
      # l.addSubview border
    end

    @messageLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Will be closed in an hour"
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
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
    @metrics = { 'padding' => 20, 'labelHeight' => 50, 'labelWidth' => 280, 'RowH' => RowH, 'SmallRowH' => SmallRowH, 'TopM' => TopM }

    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossing(RowH)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[message(RowH)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossingStatus(SmallRowH)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[trainStatus(SmallRowH)]", options:0, metrics:@metrics, views:@viewMap
    
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:|-TopM-[crossing][message][trainStatus][crossingStatus]-70-[footnote]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[crossing]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[message]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[trainStatus]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|[crossingStatus]|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[footnote]-|", options:0, metrics:@metrics, views:@viewMap

    # addConstraint NSLayoutConstraint.constraintWithItem @crossingLabel, attribute:NSLayoutAttributeHeight, relatedBy:NSLayoutRelationEqual, \
        # toItem:@messageLabel, attribute:NSLayoutAttributeHeight, multiplier:2, constant:0.0

    self.backgroundColor = UIColor.hex 0xefeff4
    self
  end

  def layoutSubviews
    @crossingLabelArrow.frame = CGRectMake Device.screenWidth - ArrowRM, (RowH-ArrowH)/2, ArrowW, ArrowH
    super
  end
  
  def touchesBegan(touches, withEvent:event)
    touch = touches.anyObject
    p touch
    if touch.view.tag == CrossingLabelTag
      puts 'yep'
    end
  end
end
