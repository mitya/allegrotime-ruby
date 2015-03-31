# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

DEVICE_IPHONE_5 = 'iPhone 5'
DEVICE_IPHONE_5_7 = 'iPhone 5s 7.1'
DEVICE_IPHONE_6 = 'iPhone 6'
DEVICE_IPAD = 'iPad Air'

ENV['device_name'] ||= DEVICE_IPHONE_5

Motion::Project::App.setup do |app|
  app.name = 'AllegroTime'  
  app.identifier = "name.sokurenko.AllegroTime"
  app.sdk_version = '8.2'
  app.deployment_target = '7.0'  
  app.icons = %w(Icon-60 Icon-76 Icon-Small-40 Icon-Small)
  app.frameworks += %w(StoreKit AdSupport QuartzCore AVFoundation CoreTelephony SystemConfiguration MessageUI AudioToolbox MapKit CoreLocation CoreData EventKit EventKitUI)
  app.libs += %w(/usr/lib/libsqlite3.dylib /usr/lib/libz.dylib)
  app.vendor_project 'vendor/GoogleMobileAds-7.0.0.framework', :static, :products => ['GoogleMobileAds'], :headers_dir => 'Headers', force_load: false
  app.vendor_project 'vendor/GoogleAnalyticsServicesiOS-3.10', :static, :products => ['libGoogleAnalyticsServices.a'], :headers_dir => 'GoogleAnalytics/Library', force_load: false
  app.vendor_project 'vendor/Flurry', :static, :products => ['libFlurry_6.2.0.a'], :headers_dir => 'Flurry.h', force_load: false
  app.device_family = [:iphone, :ipad]
  app.info_plist['UIStatusBarHidden'] = true
  
  app.development do
    app.version = "2.0.100"
    app.short_version = "2.0.101"
    app.codesign_certificate = "iPhone Developer: Dmitry Sokurenko (9HS3696XGX)"
    app.provisioning_profile = "/Volumes/Vault/Sources/active/_etc/iOS_Team.mobileprovision"    
    app.info_plist['DebugModeEnabled'] = true
    app.info_plist['ATAds'] = true
    app.info_plist['ATTracking'] = true
    app.info_plist['ATTrackingFlurry'] = true
    app.info_plist['ATTrackingGA'] = true
  end
  
  app.release do
    app.version = "2.0.0"
    app.short_version = "2.0.0"
    # app.version = "2.0.900"
    # app.short_version = "2.0.901"
    app.codesign_certificate = "iPhone Distribution: Dmitry Sokurenko (SQLB2GAZ2T)"
    app.provisioning_profile = "/Volumes/Vault/Sources/active/_etc/AppStore_Profile_for_AllegroTime.mobileprovision"
  end  
end

load 'lib/tasks.rake'

task d: :device
