module Env
  module_function
  
  def plist_var_set?(variable)
    NSBundle.mainBundle.objectForInfoDictionaryKey(variable) == true
  end
  
  def ads?
    ADVERTISEMENT
  end
  
  TRACKING = plist_var_set?('ATTracking')
  TRACKING_FLURRY = TRACKING && plist_var_set?('ATTrackingFlurry')
  TRACKING_GA = TRACKING && plist_var_set?('ATTrackingGA')
  ADVERTISEMENT = plist_var_set?('ATAds')
end
