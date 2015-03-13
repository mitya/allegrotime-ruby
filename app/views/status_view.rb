class StatusView < UIView
  attr_accessor :crossingLabel, :messageLabel, :footnoteLabel, :trainStatusLabel, :crossingStatusLabel

  def initWithFrame(frame) super
    @crossingLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Poklonnogorskaya"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.boldSystemFontOfSize(24)
      l.color = UIColor.grayShade 0.3
      l.shadowColor = UIColor.colorWithWhite 1, alpha:1
      l.shadowOffset = CGSizeMake(1, 1)
      l.backgroundColor = UIColor.whiteColor
      l.translatesAutoresizingMaskIntoConstraints = NO

      border = UIView.alloc.initWithFrame(CGRectMake 0, 0, UIScreen.mainScreen.bounds.size.width, 0.5)
      border.backgroundColor = UIColor.grayShade(0.8)
      border.autoresizingMask = UIViewAutoresizingFlexibleWidth
      l.addSubview border
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
    @metrics = { 'padding' => 20, 'labelHeight' => 50, 'labelWidth' => 280 }

    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossing(44)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[message(44)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossingStatus(28)]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[trainStatus(28)]", options:0, metrics:@metrics, views:@viewMap
    
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:|-50-[crossing][message][trainStatus][crossingStatus]-50-[footnote]", options:0, metrics:@metrics, views:@viewMap
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
    super
  end
end
