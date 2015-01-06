# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

ENV['device_name'] ||= 'iPhone 6' # 'iPhone 5s 7.1' 'iPhone 5s'

Motion::Project::App.setup do |app|
  app.name = 'AllegroTime2'
  app.identifier = "name.sokurenko.AllegroTime2"
  app.version = "2.0"
  app.short_version = "2.0"
  app.sdk_version = '8.1'
  app.deployment_target = '7.0'
  # app.codesign_certificate = "iPhone Distribution: Iconoclast Labs LLC"
  app.provisioning_profile = '/Volumes/Vault/Sources/active/_profiles/iOS_Team_Provisioning_Profile_.mobileprovision'
  app.icons = %w(Icon-60 Icon-76 Icon-Small-40 Icon-Small)
  app.frameworks += %w(StoreKit AdSupport AVFoundation CoreTelephony SystemConfiguration MessageUI AudioToolbox MapKit CoreLocation CoreData EventKit EventKitUI)
  app.vendor_project 'vendor/GoogleMobileAdsSdkiOS-6.12.0', :static, force_load: false
  app.device_family = [:iphone, :ipad]
  app.info_plist['DebugModeEnabled'] = 'YES'
end


#########################


$images = "tmp"
$sources = "originals/images"
$gradients = { red: %w(f00 e00), green: %w(0c0 0b0), yellow: %w(ff0 ee0), gray: %w(ccc eee) }

namespace :g do
  task :appicon do
    input = "originals/images/app_icon.png"
    sizes = { 57 => 'iPhone', 114 => 'iPhone@2x', 72 => 'iPad', 144 => 'iPad@2x' }
    sizes.each do |size, device|
      system "convert '#{input}' -resize #{size}x#{size} resources/Icon-#{device}.png"
    end
  end

  task :cells_bgr do
    colors = { red: %w(f00 c00), green: %w(0a0 080), yellow: %w(ff0 dd0), gray: %w(eee ddd), blue: %w(daeafa e0f0ff) }
    basename = "cell-bg"
    height = 45
  
    colors.each_pair do |name, color|
      gradient = "gradient:##{color.first}-##{color.last}"
      system %[convert -size 1x#{height} #{gradient} #{$images}/#{basename}-#{name}.png]
      system %[convert -size 1x#{height*2} #{gradient} #{$images}/#{basename}-#{name}@2x.png]
    end  

    colors.each_pair do |name, color| 
      gradient = "radial-gradient:##{color.last}-##{color.first}"
      system %[convert -size 1x#{height} #{gradient} #{$images}/#{basename}r-#{name}.png]
      system %[convert -size 1x#{height*2} #{gradient} #{$images}/#{basename}r-#{name}@2x.png]
    end
  end

  task :pins do
    basename = "crossing-pin"
    colors = %w(red green yellow gray)
    colors.each do |color|
      source = "#{$sources}/#{basename}-#{color}.png"
      `convert #{source} -fuzz 15% -transparent "rgb(213, 250, 128)" #{source}`
      `convert #{source} -background transparent -gravity north -extent 200x400 #{source}`
      `convert #{source} -resize 30x60 #{$images}/#{basename}-#{color}.png`
      `convert #{source} -resize 60x120 #{$images}/#{basename}-#{color}@2x.png`
    end 
  end

  task :stripes do
    gradients = { red: %w(f00 e00), green: %w(0c0 0b0), yellow: %w(ff0 ee0), gray: %w(999 888) }
    gradients.each_pair do |color_name, color_string| 
      `convert -size 15x44 xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string.last} -draw 'rectangle 8,0 15,44' #{$images}/cell-stripe-#{color_name}.png`
      `convert -size 30x88 xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string.last} -draw 'rectangle 16,0 30,88' #{$images}/cell-stripe-#{color_name}@2x.png`
    end
  end  
end

