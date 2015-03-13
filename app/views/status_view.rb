class StatusView < UIView
  attr_accessor :crossingLabel

  def initWithFrame(frame) super
    @crossingLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Poklonnogorskaya"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
      l.translatesAutoresizingMaskIntoConstraints = NO
      Device.roundedCornersFor(l, withRadius:8, width:1, color:UIColor.hex(0xCCCCCC))
    end

    @messageLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "Will be closed in an hour"
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
      l.textAlignment = NSTextAlignmentCenter
      l.translatesAutoresizingMaskIntoConstraints = NO
    end

    @trainStatusLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "train status"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
      l.translatesAutoresizingMaskIntoConstraints = NO
    end

    @crossingStatusLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "crossing status"
      l.textAlignment = NSTextAlignmentCenter
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
      l.translatesAutoresizingMaskIntoConstraints = NO
    end

    @footnoteLabel = UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.text = "main.footer".l
      l.color = UIColor.hex 0x4C566C
      l.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
      l.numberOfLines = 0
      l.shadowColor = UIColor.colorWithWhite 1, alpha:1
      l.shadowOffset = CGSizeMake(0, 1)
      l.translatesAutoresizingMaskIntoConstraints = NO
      l.textAlignment = NSTextAlignmentLeft
    end

    addSubview @crossingLabel
    addSubview @messageLabel
    addSubview @trainStatusLabel
    addSubview @crossingStatusLabel
    addSubview @footnoteLabel

    @viewMap = { 'crossing' => @crossingLabel, 'message' => @messageLabel, 'footnote' => @footnoteLabel, 
        'trainStatus' => @trainStatusLabel, 'crossingStatus' => @crossingStatusLabel }
    @metrics = { 'padding' => 20, 'labelHeight' => 50, 'labelWidth' => 280 }

    @crossingLabel.addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossing(50)]", options:0, metrics:@metrics, views:@viewMap
    # @messageLabel.addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[message(labelHeight)]", options:0, metrics:@metrics, views:@viewMap
    # @footnoteLabel.addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[footnote(labelHeight)]", options:0, metrics:@metrics, views:@viewMap

    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:|-50-[crossing]-[message]-25-[trainStatus]-[crossingStatus]-50-[footnote]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[crossing]-|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[message]-|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[trainStatus]-|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[crossingStatus]-|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[footnote]-|", options:0, metrics:@metrics, views:@viewMap
    # addConstraint NSLayoutConstraint.constraintWithItem @crossingLabel, attribute:NSLayoutAttributeHeight, relatedBy:NSLayoutRelationEqual, \
        # toItem:@messageLabel, attribute:NSLayoutAttributeHeight, multiplier:2, constant:0.0

    self.backgroundColor = UIColor.hex 0xEFEFF4
    self
  end

  def layoutSubviews
    super
  end
end
