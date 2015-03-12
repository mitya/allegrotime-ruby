class StatusView < UIView
  attr_accessor :crossingLabel

  def initWithFrame(frame) super
    @crossingLabel = UILabel.alloc.initWithFrame(CGRectZero)
    @crossingLabel.text = "Poklonnogorskaya"
    @crossingLabel.backgroundColor = UIColor.lightGrayColor
    @crossingLabel.textAlignment = NSTextAlignmentCenter
    @crossingLabel.translatesAutoresizingMaskIntoConstraints = NO

    @messageLabel = UILabel.alloc.initWithFrame(CGRectZero)
    @messageLabel.text = "Wiil be closed in an hour"
    @messageLabel.backgroundColor = UIColor.lightGrayColor
    @messageLabel.textAlignment = NSTextAlignmentCenter
    @messageLabel.translatesAutoresizingMaskIntoConstraints = NO

    @footnoteLabel = UILabel.alloc.initWithFrame(CGRectZero)
    @footnoteLabel.text = "main.footer".l
    @footnoteLabel.color = UIColor.darkTextColor
    @footnoteLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    @footnoteLabel.numberOfLines = 0
    # @footnoteLabel.textAlignment = NSTextAlignmentCenter
    @footnoteLabel.backgroundColor = UIColor.lightGrayColor
    @footnoteLabel.translatesAutoresizingMaskIntoConstraints = NO

    addSubview @crossingLabel
    addSubview @messageLabel
    addSubview @footnoteLabel

    @viewMap = {'crossing' => @crossingLabel, 'message' => @messageLabel, 'footnote' => @footnoteLabel}
    @metrics = {'padding' => 20, 'labelHeight' => 50, 'labelWidth' => 280}

    # @crossingLabel.addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[crossing(labelHeight)]", options:0, metrics:@metrics, views:@viewMap
    # @messageLabel.addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[message(labelHeight)]", options:0, metrics:@metrics, views:@viewMap
    # @footnoteLabel.addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:[footnote(labelHeight)]", options:0, metrics:@metrics, views:@viewMap

    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "V:|-[crossing]-[message]-50-[footnote]", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[crossing]-|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[message]-|", options:0, metrics:@metrics, views:@viewMap
    addConstraints NSLayoutConstraint.constraintsWithVisualFormat "H:|-[footnote]-|", options:0, metrics:@metrics, views:@viewMap
    # addConstraint NSLayoutConstraint.constraintWithItem @crossingLabel, attribute:NSLayoutAttributeHeight, relatedBy:NSLayoutRelationEqual, \
        # toItem:@messageLabel, attribute:NSLayoutAttributeHeight, multiplier:2, constant:0.0

    self.backgroundColor = UIColor.whiteColor
    self
  end

  def layoutSubviews
    super
  end
end
