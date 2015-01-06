class UIColor
  def mkname
    @@mkcolor_names ||= { :red.color => "red", :yellow.color => "yellow", :green.color => "green", :gray.color => "gray" }
    @@mkcolor_names[self]
  end
  
  class << self
    def rgb(red, green, blue, alpha = 1.0)
      UIColor.colorWithRed(red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    end

    def rgbf(r, g, b, a = 1.0)
      UIColor.colorWithRed(r, green:g, blue:b, alpha:a)
    end

    def hsb(h, s, v, a = 1.0)
      UIColor.colorWithHue(h / 360.0, saturation: s / 100.0,  brightness: v / 100.0, alpha: a)
    end

    def grayShade(level)
      UIColor.colorWithWhite(level, alpha:1.0)
    end

    def hex(value)
      r = value >> 16 & 0xFF
      g = value >> 8 & 0xFF
      b = value & 0xFF
      rgb(r, g, b)
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
  end
end

class CGRect
  def x
    origin.x
  end

  def y
    origin.y
  end
  
  def width
    size.width
  end
  
  def height
    size.height
  end
  
  def change(dimensions)
    result = dup
    result.origin.x = dimensions[:x] if dimensions[:x]
    result.origin.y = dimensions[:y] if dimensions[:y]
    result.size.width = dimensions[:width] if dimensions[:width]
    result.size.height = dimensions[:height] if dimensions[:height]
    result
  end
end

class UITableView
  def dequeue_cell(style, &configurator)
    cell = UITableViewCell.alloc.initWithStyle style, reuseIdentifier:MXDefaultCellID
    configurator.call(cell) if configurator
    cell
  end  
end
