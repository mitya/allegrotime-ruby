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
    
  def cell_gradient_pattern_for_color(color)
    @@gradients_map ||= {
      :red.color    => UIColor.colorWithPatternImage(Device.image_named("cell-bg-red")),
      :yellow.color => UIColor.colorWithPatternImage(Device.image_named("cell-bg-yellow")),
      :green.color  => UIColor.colorWithPatternImage(Device.image_named("cell-bg-green")),
      :blue.color   => UIColor.colorWithPatternImage(Device.image_named("cell-bg-blue")),
      :gray.color   => UIColor.colorWithPatternImage(Device.image_named("cell-bg-gray")),
      :clear.color  => UIColor.clearColor
    }
    @@gradients_map[color]
  end
        
end
