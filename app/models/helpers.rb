GAD_IPHONE_KEY = "a14fa40c3009571"
GAD_IPAD_KEY = "a14fa6612839d98"
GAD_IPAD_WIDTH = 728
GAD_REFRESH_PERIOD = DEBUG ? 10 : 60
GAD_TESTING_MODE = DEBUG ? YES : NO

IPHONE = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone

# def __method ([[NSString stringWithFormat:@"%s", _cmd] cString])
# def __cmd (sel_getName(_cmd))

LocationStateNotAvailable = 1
LocationStateSearching = 2
LocationStateSet = 3


NXClosestCrossingChanged = "NXClosestCrossingChangedNotification"
NXLogConsoleUpdated = "NXLogConsoleUpdated"
NXLogConsoleFlushed = "NXLogConsoleFlushed"
NXModelUpdated = "NXUpdateDataStatus"
MXDefaultCellID = "MXDefaultCellID"

### Logging

def MXLogArray(desc, array)
  NSLog("%s array dump:", desc);
  array.each_with_index do |obj, i|
    NSLog("  %2i: %@", i, obj);
  end
end

def MXLogString(string)
  NSLog("%s", string);
end

def MXLogSelector(selector)
  NSLog(">> %s", sel_getName(selector));
end

def MXLogRect(title, rect)
  NSLog("%s %@: {(%.0f,%.0f) %.0fx%.0f}", __func__, title, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
end

def MXLog(desc, object)
  if object.isKindOfClass NSArray.class
    MXLogArray(desc, object);
  else
    NSLog("%s = %@", desc, object);
  end
end

def MXDump(object)
  NSLog("%@", object);
end


### Console

def MXGetConsole
  $mx_logging_buffer ||= NSMutableArray.arrayWithCapacity 1000
end

def MXWriteToConsole(format, *args)
  # va_list args;
  # va_start(args, format);
  # NSString *formattedMessage = [[NSString alloc] initWithFormat:format arguments:args];
  # va_end(args);
  # 
  # NSLog(@"%@", formattedMessage);
  # 
  # #if DEBUG
  #   formattedMessage = [NSString stringWithFormat:@"%@ %@\n", MXFormatDate([NSDate date], @"HH:mm:ss"), formattedMessage];
  #   [MXGetConsole() addObject:formattedMessage];
  # 
  #   [NSNotificationCenter.defaultCenter postNotificationName:NXLogConsoleUpdated object:$mx_logging_buffer];
  # 
  #   if ($mx_logging_buffer.count > 200)
  #     [$mx_logging_buffer removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 50)]];
  #     [NSNotificationCenter.defaultCenter postNotificationName:NXLogConsoleFlushed object:$mx_logging_buffer];
  #   end
  # #endif
end


### Formatting

def T(string)
  NSLocalizedString string, nil
end

def TF(format, *args)
  NSString.alloc.initWithFormat(T(format), *args)
end

# MXPluralizeRussiaWord(х, @"час", @"часа", @"часов")
# MXPluralizeRussiaWord(х, @"минута", @"минуты", @"минут")
def MXPluralizeRussiaWord(number, word1, word2, word5)
  rem100 = number % 100;
  rem10 = number % 10;

  return word5 if (rem100 >= 11 && rem100 <= 19)
  return word5 if (rem10 == 0)
  return word1 if (rem10 == 1)
  return word2 if (rem10 >= 2 && rem10 <= 4)
  return word5 if (rem10 >= 5 && rem10 <= 9)
  return word5
end


### Time and dates

def MXFormatMinutesAsText(totalMinutes)
  hours = totalMinutes / 60;
  minutes = totalMinutes % 60;

  hoursString = Helper.stringWithFormat "%i %@", hours, MXPluralizeRussiaWord(hours, "час", "часа", "часов")
  minutesString = Helper.stringWithFormat "%i %@", minutes, MXPluralizeRussiaWord(minutes, "минуту", "минуты", "минут")

  if hours == 0
    minutesString
  elsif minutes == 0
    hoursString
  else
    NSString.stringWithFormat "%@ %@", hoursString, minutesString
  end
end

def MXFormatMinutesAsTextWithZero(totalMinutes, formatString, zeroString)
  return zeroString if totalMinutes == 0
  return NSString.stringWithFormat formatString, MXFormatMinutesAsText(totalMinutes)
end

def MXFormatDate(date, format)
  dateFormatter = NSDateFormatter.alloc.init
  dateFormatter.setDateFormat format
  dateFormatter.stringFromDate date
end

def MXTimestampString
  now = NSDate.date
  dateFormatter = NSDateFormatter.alloc.init
  dateFormatter.setDateFormat "HH:mm:ss.SSS"
  dateFormatter.stringFromDate now
end

def MXCurrentTimeInMinutes
  calendar = NSCalendar.currentCalendar

  now = NSDate.date
  nowParts = calendar.components NSHourCalendarUnit | NSMinuteCalendarUnit, fromDate:now

  hours = nowParts.hour;
  minutes = nowParts.minute;
  hours * 60 + minutes;
end

### UI

def MXCellGradientColorFor(color)
  $mapping ||= NSDictionary.dictionaryWithObjectsAndKeys(
    UIColor.colorWithPatternImage(MXImageFromFile("cell-bg-red.png")), UIColor.redColor,
    UIColor.colorWithPatternImage(MXImageFromFile("cell-bg-yellow.png")), UIColor.yellowColor,
    UIColor.colorWithPatternImage(MXImageFromFile("cell-bg-green.png")), UIColor.greenColor,
    UIColor.colorWithPatternImage(MXImageFromFile("cell-bg-blue.png")), UIColor.blueColor,
    UIColor.colorWithPatternImage(MXImageFromFile("cell-bg-gray.png")), UIColor.grayColor,
    nil)
  $mapping.objectForKey color
end

def MXAutorotationPolicy(interfaceOrientation)
  # if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
  #  return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
  YES
end

def MXNameForColor(color)
  $colorNames ||= NSDictionary.dictionaryWithObjectsAndKeys(
    "red", UIColor.redColor,
    "yellow", UIColor.yellowColor,
    "green", UIColor.greenColor,
    "gray", UIColor.grayColor,
    nil)
  $colorNames.objectForKey color
end

def MXSetGradientForCell(cell, color)
  $textColorMapping ||= NSDictionary.dictionaryWithObjectsAndKeys(
    UIColor.whiteColor, UIColor.redColor,
    UIColor.darkGrayColor, UIColor.yellowColor,
    UIColor.whiteColor, UIColor.greenColor,
    UIColor.blackColor, UIColor.blueColor,
    UIColor.blackColor, UIColor.grayColor,
    nil)

  cell.backgroundColor = MXCellGradientColorFor(color)
  cell.textLabel.textColor = $textColorMapping.objectForKey color
  cell.detailTextLabel.textColor = $textColorMapping.objectForKey color if cell.detailTextLabel

  if color == UIColor.blueColor || color == UIColor.grayColor
    cell.detailTextLabel.textColor = UIColor.darkGrayColor
  end
end

def MXConfigureLabelLikeInTableViewFooter(label)
  label.backgroundColor = UIColor.clearColor
  label.font = UIFont.systemFontOfSize 15
  label.textColor = UIColor.colorWithRed 0.298039, green:0.337255, blue:0.423529, alpha:1
  label.shadowColor = UIColor.colorWithWhite 1, alpha:1
  label.shadowOffset = CGSizeMake(0, 1)
  label.textAlignment = UITextAlignmentCenter
  label
end


def MXImageFromFile(filename)
  path = NSString.stringWithFormat "images/%@", filename
  UIImage.imageNamed path
end

def MXPadTableViewBackgroundColor
  UIColor.colorWithRed 0.816, green:0.824, blue:0.847, alpha:1.000
end

### Other

def MXIsPhone()
  UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
end


### Core extensions

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


### Helpers module

class Helper
  class << self
    def stringWithFormat(string, *args)
      string % args
    end
    
    def parseStringAsHHMM(string)
      components = string.componentsSeparatedByString ":"
      hours = components.objectAtIndex(0).integerValue
      minutes = components.objectAtIndex(1).integerValue
      hours * 60 + minutes
    end

    def compareInteger(num1, with:num2)
      num1 < num2 ? -1 : num1 > num2 ? 1 : 0
    end

    def tableViewCellWidth
      UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 680 : 300
    end

    def spinnerAfterCenteredLabel(label)
      labelSize = label.text.sizeWithFont label.font
      spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle UIActivityIndicatorViewStyleGray
      spinner.center = CGPointMake(labelSize.width + (label.frame.size.width - labelSize.width) / 2 + spinner.frame.size.width, label.center.y)
      spinner
    end

    def formatTimeInMunutesAsHHMM(minutesSinceMidnight)
      hours = minutesSinceMidnight / 60
      minutes = minutesSinceMidnight - hours * 60
      Helper.stringWithFormat "%02i:%02i", hours, minutes
    end

    def greenColor
      UIColor.colorWithRed 0, green:0.5, blue:0, alpha:1
    end

    def yellowColor
      UIColor.colorWithRed 1, green:0.6, blue:0, alpha:1
    end

    def blueTextColor
      UIColor.colorWithRed 82.0 / 255, green:102.0 / 255, blue:145.0 / 255, alpha:1
    end
  
    def roundToFive(value)
      remainder = value - value / 5 * 5
      remainderInverse = 5 - remainder
      remainder <= 2 ? value - remainder : value + remainderInverse
    end

    def timeTillFullMinute
      dateComponents = NSCalendar.currentCalendar.components NSSecondCalendarUnit, fromDate:NSDate.date
      60 - dateComponents.second
    end

    def nextFullMinuteDate
      NSDate.dateWithTimeIntervalSinceNow timeTillFullMinute
    end
  end
end

################

def app
  $app
end

def model
  $model
end
