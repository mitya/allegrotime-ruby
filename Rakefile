# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'allegrotime_rm'
  app.frameworks += %w(StoreKit AdSupport AVFoundation CoreTelephony SystemConfiguration MessageUI AudioToolbox MapKit CoreLocation CoreData)
  app.vendor_project 'vendor/GoogleAdMobAdsSdkiOS-6.8.0', :static, force_load: false
end
