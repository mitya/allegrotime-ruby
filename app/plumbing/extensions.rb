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
