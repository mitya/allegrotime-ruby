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
end
