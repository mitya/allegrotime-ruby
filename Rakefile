# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

ENV['device_name'] ||= 'iPhone 6' # 'iPhone 5s 7.1' 'iPhone 5s'
# ENV['device_name'] = 'iPad Air'

Motion::Project::App.setup do |app|
  app.name = 'AllegroTime2'
  app.identifier = "name.sokurenko.AllegroTime2"
  app.version = "2.0"
  app.short_version = "2.0"
  app.sdk_version = '8.2'
  app.deployment_target = '7.0'
  # app.codesign_certificate = "iPhone Distribution: Iconoclast Labs LLC"
  app.provisioning_profile = '/Volumes/Vault/Sources/active/_etc/iOS_Team.mobileprovision'
  app.icons = %w(Icon-60 Icon-76 Icon-Small-40 Icon-Small)
  app.frameworks += %w(StoreKit AdSupport QuartzCore AVFoundation CoreTelephony SystemConfiguration MessageUI AudioToolbox MapKit CoreLocation CoreData EventKit EventKitUI)
  app.vendor_project 'vendor/GoogleMobileAds-7.0.0.framework', :static, :products => ['GoogleMobileAds'], :headers_dir => 'Headers', force_load: false
  app.device_family = [:iphone, :ipad]
  app.info_plist['DebugModeEnabled'] = true
  app.info_plist['UIStatusBarHidden'] = true
end


#########################

task d: :device

$images = "resources/images"
$sources = "originals/images"
$gradients = { red: %w(f00 e00), green: %w(0c0 0b0), yellow: %w(ff0 ee0), gray: %w(ccc eee) }

def retina_sh
  (1..3).each do |scale|
    suffix = scale == 1 ? '' : "@#{scale}x"
    command = yield scale, suffix
    puts command
    system command
  end
end

namespace :g do
  task :appicon do
    input = "originals/images/app_icon.png"
    sizes = { 57 => 'iPhone', 114 => 'iPhone@2x', 72 => 'iPad', 144 => 'iPad@2x' }
    sizes.each do |size, device|
      system "convert '#{input}' -resize #{size}x#{size} resources/Icon-#{device}.png"
    end
  end

  task :message_bg do
    colors = { red: %w(f00 c00), green: %w(0a0 080), yellow: %w(ff0 dd0), gray: %w(999 aaa) }
    colors = { gray: %w(999 aaa) }
    height = 70
  
    colors.each_pair do |name, color|
      gradient = "gradient:##{color.first}-##{color.last}"
      retina_sh { |x, sx| %[convert -size 1x#{height*x} #{gradient} #{$images}/cell-bg-#{height}-#{name}#{sx}.png] }
    end
  end

  task :pins do
    basename = "crossing-pin"
    colors = %w(red green yellow gray)
    colors.each do |color|
      source = "#{$sources}/#{basename}-#{color}.png"
      `convert #{source} -fuzz 15% -transparent "rgb(213, 250, 128)" #{source}`
      `convert #{source} -background transparent -gravity north -extent 200x400 #{source}`
      retina_sh { |x, sx| %[convert #{source} -resize #{30*x}x#{60*x} #{$images}/#{basename}-#{color}#{sx}.png] }
    end 
  end

  task :stripes do
    gradients = { red: %w(f00 e00), green: %w(0c0 0b0), yellow: %w(ffff00 f4f400), gray: %w(999 888) }
    gradients.each_pair do |color_name, color_string| 
      retina_sh { |x, sx| %[convert -size #{15*x}x#{44*x} xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string.last} -draw 'rectangle #{8*x},0 #{15*x},#{44*x}' #{$images}/cell-stripe-#{color_name}#{sx}.png] }
    end
  end  
  
  desc "Converts originals to resources"
  task :convert do
    `convert originals/images/i8-clock-100.png -resize 50x50 resources/images/ti-clock@2x.png`
    `convert originals/images/i8-pin-100.png   -resize 50x50 resources/images/ti-pin@2x.png`
    `convert originals/images/i8-info-100.png  -resize 50x50 resources/images/ti-info@2x.png`
  end
end

