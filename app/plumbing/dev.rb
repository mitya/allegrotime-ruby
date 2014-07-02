module Dev
  module_function
  
  def outline_view(view, color = UIColor.greenColor)
    view.layer.borderColor = color.CGColor
    view.layer.borderWidth = 1.0
  end
end
