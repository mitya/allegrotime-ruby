# README #

### О программе ###

АллегроТайм знает время закрытия всех переездов для прохода поезда Аллегро.

### Ссылки

http://pass.rzd.ru/static/public/ru?STRUCTURE_ID=5186&
http://www.poezd-allegro-train.ru/raspisanie_poezd_allegro
https://rasp.yandex.ru/thread/783MV_tis?station_to=9600645&tt=train&departure=2015-04-13&station_from=9602497
https://rasp.yandex.ru/search/train/?fromName=%D0%A1%D0%B0%D0%BD%D0%BA%D1%82-%D0%9F%D0%B5%D1%82%D0%B5%D1%80%D0%B1%D1%83%D1%80%D0%B3&fromId=&toName=%D0%A5%D0%B5%D0%BB%D1%8C%D1%81%D0%B8%D0%BD%D0%BA%D0%B8&toId=c10493&when=%D0%BD%D0%B0+%D0%B2%D1%81%D0%B5+%D0%B4%D0%BD%D0%B8

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

### Commands


xcrun dwarfdump --uuid /Volumes/Vault/Sources/Active/allegrotime/build/iPhoneOS-7.0-Release/AllegroTime.app.dSYM

xcrun atos -o ~/Desktop/AllegroTime\ 2.0.2/Payload/AllegroTime.app/AllegroTime -arch arm64 -l 0x44000 2608ec 27cd7c 2296ec 260118 1719e8 25e078 2411d0 23fbdc 240d2c 004c898 00f4614 0242ad4 0242ccc 0236eec 01a8a08 02417ac 004c898 00f1374 02417ac 004c898 010d108 010db3c 

symbolicatecrash crash.txt ~/Desktop/AllegroTime\ 2.0.2/Payload/AllegroTime.app/ > crash-sym.txt
