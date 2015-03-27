DEBUG = NSBundle.mainBundle.objectForInfoDictionaryKey('DebugModeEnabled') == true
YES = true
NO = false
NULL = nil

GAD_IPHONE_AD_UNIT_ID = "ca-app-pub-2088650388410884/5631791058"
GAD_IPAD_AD_UNIT_ID = "ca-app-pub-2088650388410884/7108524256"
GAD_REFRESH_PERIOD = 60
GAD_TESTING_IPHONE_ID = '398a17d1387d6fa3ac0e24597718c091'
GAD_TESTING_IPAD_ID = 'e993311bb857d82d1b2df4a83f03101e'
FLURRY_TOKEN = 'SM6YJJ3V9TP8XPFQJWTM'
SIMULATOR = UIDevice.currentDevice.model == "iPhone Simulator"
TRACKING = true
ADVERTISEMENT = false
TABLE_VIEW_HEADER_HEIGHT = 44

NXDefaultCellIDClosestCrossingChanged = "NXDefaultCellIDClosestCrossingChangedNotification"
NXDefaultCellIDCurrentCrossingChanged = "NXDefaultCellIDCurrentCrossingChangedNotification"
NXDefaultCellIDLogConsoleUpdated = "NXDefaultCellIDLogConsoleUpdated"
NXDefaultCellIDLogConsoleFlushed = "NXDefaultCellIDLogConsoleFlushed"
NXDefaultCellID = "NXDefaultCellID"

$logging_buffer = []

##############################


def _ddl(*objects)
  string = objects.map { |obj| Boxed === obj ? obj.inspect : obj.description }.join(' ')
  puts "**** #{string}"
end

def _dd(object)
  desc = Boxed === object ? object.inspect : object.description
  puts "**** #{desc}"
end

def _vv(view, color = :green)
  view.layer.borderColor = color.color.CGColor
  view.layer.borderWidth = 1.0
end

def _log(message)
  NSLog(message)
end
