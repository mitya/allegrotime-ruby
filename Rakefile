# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'AllegroTime2'
  app.identifier = "name.sokurenko.AllegroTime2"
  app.version = "2.0"
  app.provisioning_profile = '/Users/Dima/Library/MobileDevice/Provisioning Profiles/D8251B9B-9F6C-40F3-A0AB-344DCF5C5D94.mobileprovision'
  app.icons = %w(Icon-iPhone.png Icon-iPad.png Icon-iPhone@2x.png Icon-iPad@2x.png)
  app.frameworks += %w(StoreKit AdSupport AVFoundation CoreTelephony SystemConfiguration MessageUI AudioToolbox MapKit CoreLocation CoreData)
  app.vendor_project 'vendor/GoogleMobileAdsSdkiOS-6.9.3', :static, force_load: false
end
