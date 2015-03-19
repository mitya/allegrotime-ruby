# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

ENV['device_name'] ||= 'iPhone 5' # 'iPhone 5s 7.1' 'iPhone 5s'
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
  app.libs += %w(/usr/lib/libsqlite3.dylib /usr/lib/libz.dylib)
  app.vendor_project 'vendor/GoogleMobileAds-7.0.0.framework', :static, :products => ['GoogleMobileAds'], :headers_dir => 'Headers', force_load: false
  app.vendor_project 'vendor/GoogleAnalyticsServicesiOS-3.10', :static, :products => ['libGoogleAnalyticsServices.a'], :headers_dir => 'GoogleAnalytics/Library', force_load: false
  app.vendor_project 'vendor/Flurry', :static, :products => ['libFlurry_6.2.0.a'], :headers_dir => 'Flurry.h', force_load: false
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

def run(command)
  puts command
  sh command
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
    colors = { red: %w(f00 c00), green: %w(0a0 080), yellow: %w(ff0 dd0), gray: %w(aaa 888) }
    colors = { gray: %w(aaa 888) }
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
  
  desc "removes the statusbar from a full-screen screenshot"
  task :chop_statusbar do
    statusbar_height = 40
    %w(en-1 en-2 en-3 en-4 en-5 ru-1 ru-2 ru-3 ru-4 ru-5).each do |file|
      ss = Magick::Image.read("originals/screenshots/v2b/ipad/#{file}.png").first
      ss.crop! 0, statusbar_height, ss.columns, ss.rows, true
      unless ENV['nofill']
        ss.background_color = "#FFFFFF"
        ss = ss.extent ss.columns, ss.rows + statusbar_height, 0, -statusbar_height
      end
      ss.write ss.filename
    end
  end  
  
  desc "Composes an app screenshot over the device image"
  task :compose_mockup do
    device_image = "/Volumes/Vault/Sources/Active/_assets/mockup-iphone-5s.png"
    results_dir = "tmp"
    screenshots_dir = "/Volumes/Vault/Sources/Active/allegrotime/originals/screenshots/v2b-sources/5"    
    screenshots = %w(1 2 3 4 5)
    screenshots.each do |name|
      screenshot = "#{screenshots_dir}/ru-#{name}.png"
      result_image = "#{results_dir}/mockup-5-#{name}.png"
      run "convert #{device_image} #{screenshot} -geometry 641x1140+69+255 -composite -resize 350 #{result_image}"
    end
  end
end
