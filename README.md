# README #

### О программе ###

АллегроТайм знает время закрытия всех переездов для прохода поезда Аллегро.

### Ссылки

http://ozd.rzd.ru/static/public/ru/ozd?STRUCTURE_ID=4735&

Открыт ли переезд?
Статус всех переездов
Расписание закрытия переезда
Расписание Аллегро
Карта переездов

Is a Crossing Open?
Crossings State
Crossing Schedule
Allegro Schedule
Crossings Map


24.01.15 Дорога на каменку - исправить на 6:59 в первом закрытии.
21.01.15 Парголово +1 минута


convert -size 1000x1000 xc:skyblue base.png
convert -size 100x100 xc:red red.png
composite -geometry 200x200+400+400 red.png base.png composite.png

convert -size 100x100 xc:skyblue -size 30x30 xc:red -geometry 60x60+10+10 -composite com2.gif
convert #{result_image} -resize 360 #{result_image}


### Docs
  
  * http://flurrydev.github.io/FlurryiOSSDK6xAPI/interface_flurry.html
  * https://developer.yahoo.com/flurry/docs/analytics/gettingstarted/events/ios/
  * https://developers.google.com/analytics/devguides/collection/ios/v3/


## Changelog

### 2.0.2 (unreleased)

  * изменено расписание Парголово и Каменки на 2 минуту (и туда и обратно)
  * исправлен баг с ротацией WebView
