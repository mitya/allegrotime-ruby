module Env
  module_function
  
  def plist_var_set?(variable)
    NSBundle.mainBundle.objectForInfoDictionaryKey(variable) == true
  end
  
  def ads?
    ADVERTISEMENT
  end
  
  if DEBUG
    TRACKING = plist_var_set?('ATTracking')
    TRACKING_FLURRY = TRACKING && plist_var_set?('ATTrackingFlurry')
    TRACKING_GA = TRACKING && plist_var_set?('ATTrackingGA')
    ADVERTISEMENT = plist_var_set?('ATAds')
  else
    TRACKING = true
    TRACKING_FLURRY = true
    TRACKING_GA = true
    ADVERTISEMENT = true
  end
end
