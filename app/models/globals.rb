GAD_IPHONE_AD_UNIT_ID = "ca-app-pub-2088650388410884/5631791058"
GAD_IPAD_AD_UNIT_ID = "ca-app-pub-2088650388410884/7108524256"
GAD_IPHONE_KEY = "a14fa40c3009571"
GAD_IPAD_KEY = "a14fa6612839d98"
GAD_REFRESH_PERIOD = DEBUG ? 10 : 60
GAD_TESTING_MODE = DEBUG ? YES : NO
GAD_TESTING_IPHONE_ID = '398a17d1387d6fa3ac0e24597718c091'
GAD_TESTING_IPAD_ID = 'e993311bb857d82d1b2df4a83f03101e'

LocationStateNotAvailable = 1
LocationStateSearching = 2
LocationStateSet = 3

NXClosestCrossingChanged = "NXClosestCrossingChangedNotification"
NXLogConsoleUpdated = "NXLogConsoleUpdated"
NXLogConsoleFlushed = "NXLogConsoleFlushed"
NXModelUpdated = "NXUpdateDataStatus"
MXDefaultCellID = "MXDefaultCellID"

##############################

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
