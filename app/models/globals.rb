GAD_IPHONE_KEY = "a14fa40c3009571"
GAD_IPAD_KEY = "a14fa6612839d98"
GAD_IPAD_WIDTH = 728
GAD_REFRESH_PERIOD = DEBUG ? 10 : 60
GAD_TESTING_MODE = DEBUG ? YES : NO

IPHONE = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone

LocationStateNotAvailable = 1
LocationStateSearching = 2
LocationStateSet = 3

NXClosestCrossingChanged = "NXClosestCrossingChangedNotification"
NXLogConsoleUpdated = "NXLogConsoleUpdated"
NXLogConsoleFlushed = "NXLogConsoleFlushed"
NXModelUpdated = "NXUpdateDataStatus"
MXDefaultCellID = "MXDefaultCellID"

$model = nil
$app = nil

def T(string)
  NSLocalizedString string, nil
end

def TF(format, *args)
  NSString.alloc.initWithFormat(T(format), *args)
end

def app
  $app
end

def model
  $model
end

def _dd(object)
  puts "**** #{object.description}"
end

def _ov(view, color = UIColor.greenColor)
  view.layer.borderColor = color.CGColor
  view.layer.borderWidth = 1.0
end