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

def _ddl(*objects)
  string = objects.map { |obj| Boxed === obj ? obj.inspect : obj.description }.join(' ')
  puts "**** #{string}"
end

def _dd(object)
  desc = Boxed === object ? object.inspect : object.description
  puts "**** #{desc}"
end

alias _p _dd

def _vv(view, color = :green)
  view.layer.borderColor = color.color.CGColor
  view.layer.borderWidth = 1.0
end
