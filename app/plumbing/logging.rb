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
  if object.isKindOfClass NSArray
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
  #   formattedMessage = [NSString stringWithFormat:@"%@ %@\n", Time.mk_format_date([NSDate date], @"HH:mm:ss"), formattedMessage];
  #   [MXGetConsole() addObject:formattedMessage];
  # 
  #   [NSNotificationCenter.defaultCenter postNotificationName:NXDefaultCellIDLogConsoleUpdated object:$mx_logging_buffer];
  # 
  #   if ($mx_logging_buffer.count > 200)
  #     [$mx_logging_buffer removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 50)]];
  #     [NSNotificationCenter.defaultCenter postNotificationName:NXDefaultCellIDLogConsoleFlushed object:$mx_logging_buffer];
  #   end
  # #endif
end


module Log
  module_function
  
  def info(message, *args)
    puts message % args if DEBUG
  end

  def warn(message, *args)
    puts message % args
  end
end
