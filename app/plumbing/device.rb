module Device
  module_function
  
  def image_named(filename)
    UIImage.imageNamed "images/#{filename}.png"
  end
  
  def language
    'lang'.l
  end
  
  def portrait?(orientation = UIApplication.sharedApplication.statusBarOrientation)
     orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown
  end  

  def iphone?
    $device_is_iphone != nil ? $device_is_iphone : $device_is_iphone = 
      UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
  end
end
