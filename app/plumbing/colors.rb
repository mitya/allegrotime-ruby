module Colors
  module_function
    
  def green
    UIColor.colorWithRed 0, green:0.5, blue:0, alpha:1
  end

  def yellow
    UIColor.colorWithRed 1, green:0.6, blue:0, alpha:1
  end

  def blueText
    UIColor.colorWithRed 82.0 / 255, green:102.0 / 255, blue:145.0 / 255, alpha:1
  end
    
  def tint
    UIColor.rgb(255, 59, 48)
  end
  
  def selection
    UIColor.rgb(255, 59, 48)
  end
  
  def systemYellow
    UIColor.rgb(255, 204, 0)
  end
  
  def systemGreen
    UIColor.rgb(76, 217, 100)
  end

  def systemBlue
    UIColor.rgb(0, 122, 255)
  end

  def systemRed
    UIColor.rgb(255, 59, 48)
  end

  def systemGray
    UIColor.rgb(142, 142, 147)
  end
  
  def mainCellTextColor
    UIColor.rgb(32, 32, 40)
  end
  
  def windowTintColor
    systemGray
  end
  
  def barBackColorFor(color)
    @@bar_back_color_map ||= {
      :red.color    => UIColor.rgb(216, 0, 0),
      :yellow.color => UIColor.rgb(224, 224, 0),
      :green.color  => UIColor.rgb(0, 144, 0)
    }
    @@bar_back_color_map[color]    
  end
  
  def barTextColorFor(color)
    @@bar_text_color_map ||= {
      :red.color     => :white.color,
      :yellow.color  => UIColor.rgb(48, 48, 55),
      :green.color   => :white.color,
      :blue.color    => :black.color,
      :gray.color    => :black.color,
      :clear.color   => :black.color
    }
    @@bar_text_color_map[color]
  end
  
  def barStyleFor(color)
    color == :yellow.color ? UIBarStyleDefault : UIBarStyleBlack
  end

  def secondaryTextColorFor(color)
    @@bar_text_color_map ||= {
      :red.color    => UIColor.lightTextColor,
      :yellow.color => UIColor.lightTextColor,
      :green.color  => UIColor.lightTextColor
    }
    @@bar_text_color_map[color]
  end        
  
  def closingCellBackgroundFor(color)
    @@closing_cell_backgrounds ||= {
      :red.color    => UIColor.colorWithPatternImage(Device.image_named("cell-bg-red")),
      :yellow.color => UIColor.colorWithPatternImage(Device.image_named("cell-bg-yellow")),
      :green.color  => UIColor.colorWithPatternImage(Device.image_named("cell-bg-green")),
      :blue.color   => UIColor.colorWithPatternImage(Device.image_named("cell-bg-blue")),
      :gray.color   => UIColor.colorWithPatternImage(Device.image_named("cell-bg-gray")),
      :clear.color  => UIColor.clearColor
    }
    @@closing_cell_backgrounds[color]
  end
end
