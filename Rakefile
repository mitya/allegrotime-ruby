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
  app.short_version = "2.0"
  app.sdk_version = '7.1'
  app.deployment_target = '7.0'
  app.provisioning_profile = '/Users/Dima/Library/MobileDevice/Provisioning Profiles/D8251B9B-9F6C-40F3-A0AB-344DCF5C5D94.mobileprovision'
  app.icons = %w(Icon-iPhone.png Icon-iPad.png Icon-iPhone@2x.png Icon-iPad@2x.png)
  app.frameworks += %w(StoreKit AdSupport AVFoundation CoreTelephony SystemConfiguration MessageUI AudioToolbox MapKit CoreLocation CoreData)
  app.vendor_project 'vendor/GoogleMobileAdsSdkiOS-6.10.0', :static, force_load: false

  # app.interface_orientations = [:portrait, :landscape_left, :landscape_right]
  app.device_family = ENV['IPAD'] == '1' ? [:ipad, :iphone] : [:iphone, :ipad]
end

task :appicon do
  input = "originals/images/app_icon.png"
  sizes = { 57 => 'iPhone', 114 => 'iPhone@2x', 72 => 'iPad', 144 => 'iPad@2x' }
  sizes.each do |size, device|
    system "convert #{input} -resize #{size}x#{size} resources/Icon-#{device}.png"
  end
end
