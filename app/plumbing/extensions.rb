class Symbol
  def color
    UIColor.send("#{self.to_s}Color")
  end
end


class Time
  def self.minutes_since_midnight
    calendar = NSCalendar.currentCalendar

    now = NSDate.date
    nowParts = calendar.components NSHourCalendarUnit | NSMinuteCalendarUnit, fromDate:now

    hours = nowParts.hour;
    minutes = nowParts.minute;
    hours * 60 + minutes;    
  end
  
  def self.timestamp_string
    now = NSDate.date
    dateFormatter = NSDateFormatter.alloc.init
    dateFormatter.setDateFormat "HH:mm:ss.SSS"
    dateFormatter.stringFromDate now
  end
  
  def self.format_date(date, format)
    dateFormatter = NSDateFormatter.alloc.init
    dateFormatter.setDateFormat format
    dateFormatter.stringFromDate date
  end
  
  def self.time_till_full_minute
    dateComponents = NSCalendar.currentCalendar.components NSSecondCalendarUnit, fromDate:NSDate.date
    60 - dateComponents.second
  end

  def self.next_full_minute_date
    NSDate.dateWithTimeIntervalSinceNow time_till_full_minute
  end  
end


class NSString
  def format(*args)
    NSString.stringWithFormat self, *objects
  end

  def transliterated
    # buffer = mutableCopy
    # CFMutableStringRef bufferRef = (__bridge CFMutableStringRef) buffer;
    # CFStringTransform(bufferRef, NULL, kCFStringTransformToLatin, false);
    # CFStringTransform(bufferRef, NULL, kCFStringTransformStripCombiningMarks, false);
    # CFStringTransform(bufferRef, NULL, kCFStringTransformStripDiacritics, false);
    # [buffer replaceOccurrencesOfString:@"ʹ" withString:@"" options:0 range:NSMakeRange(0, buffer.length)];
    # [buffer replaceOccurrencesOfString:@"–" withString:@"-" options:0 range:NSMakeRange(0, buffer.length)];
    # return buffer;
    self
  end
  
  def l
    NSLocalizedString self, nil
  end
  
  def li(*args)
    NSString.alloc.initWithFormat self.l, *args
  end
  
  def minutes_from_hhmm
    components = self.componentsSeparatedByString ":"
    hours = components.objectAtIndex(0).integerValue
    minutes = components.objectAtIndex(1).integerValue
    hours * 60 + minutes
  end  
end


class NSArray
  def firstObject
    return nil if count == 0
    objectAtIndex 0
  end

   def minimumObject(valueSelector)
    minValue = valueSelector.call firstObject
    minObject = firstObject

    for object in self do
      value = valueSelector.call object
      if value < minValue
        minValue = value
        minObject = object
      end
    end

    minObject;
  end

   def detectObject(predicate)
    for object in self do
      return object if predicate.call object
    end
    nil
  end
end


class UIColor
  def mkname
    @@mkcolor_names ||= { :red.color => "red", :yellow.color => "yellow", :green.color => "green", :gray.color => "gray" }
    @@mkcolor_names[self]
  end
  
  def self.rgb(red, green, blue, alpha = 1.0)
    UIColor.colorWithRed(red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
  end

  def self.rgbf(r, g, b, a = 1.0)
    UIColor.colorWithRed(r, green:g, blue:b, alpha:a)
  end

  def self.hsb(h, s, v, a = 1.0)
    UIColor.colorWithHue(h / 360.0, saturation: s / 100.0,  brightness: v / 100.0, alpha: a)
  end

  def self.grayShade(level)
    UIColor.colorWithWhite(level, alpha:1.0)
  end

  def self.hex(value)
    r = value >> 16 & 0xFF
    g = value >> 8 & 0xFF
    b = value & 0xFF
    rgb(r, g, b)
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
