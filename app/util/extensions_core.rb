class Object
  def performSelectorIfDefined(selector)
    performSelector(selector) if respondsToSelector(selector)
  end
end  


class Symbol
  def color
    UIColor.send("#{to_s}Color")
  end
end


class Time
  class << self
    def minutes_since_midnight
      calendar = NSCalendar.currentCalendar

      now = NSDate.date
      nowParts = calendar.components NSHourCalendarUnit | NSMinuteCalendarUnit, fromDate:now

      hours = nowParts.hour
      minutes = nowParts.minute
      hours * 60 + minutes
      # 18*60 + 47
      # 13*60 + 47
    end
  
    def time_till_full_minute
      dateComponents = NSCalendar.currentCalendar.components NSSecondCalendarUnit, fromDate:NSDate.date
      60 - dateComponents.second
    end

    def next_full_minute_date
      NSDate.dateWithTimeIntervalSinceNow time_till_full_minute
    end  
  end
end


# must be NSString instead of String for some reason
class NSString
  # def transliterated
  #   buffer = mutableCopy
  #   CFMutableStringRef bufferRef = (__bridge CFMutableStringRef) buffer;
  #   CFStringTransform(bufferRef, NULL, kCFStringTransformToLatin, false);
  #   CFStringTransform(bufferRef, NULL, kCFStringTransformStripCombiningMarks, false);
  #   CFStringTransform(bufferRef, NULL, kCFStringTransformStripDiacritics, false);
  #   [buffer replaceOccurrencesOfString:@"ʹ" withString:@"" options:0 range:NSMakeRange(0, buffer.length)];
  #   [buffer replaceOccurrencesOfString:@"–" withString:@"-" options:0 range:NSMakeRange(0, buffer.length)];
  #   return buffer;
  # end
  
  def l
    NSLocalizedString self, nil
  end
  
  def li(*args)
    NSString.alloc.initWithFormat self.l, *args
  end  
end


# must be NSArray
class NSArray
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
end


class NSIndexPath
  def inspect
    "{#{section}, #{row}}"
  end  
end
