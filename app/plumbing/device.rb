module Device
  module_function
  
  def image_named(filename)
    UIImage.imageNamed "images/#{filename}.png"
  end
  
  def language
    'lang'.l
  end
  
end