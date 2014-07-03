module Widgets
  module_function
  
  def spinnerAfterCenteredLabel(label)
    labelSize = label.text.sizeWithFont label.font
    spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle UIActivityIndicatorViewStyleGray
    spinner.center = CGPointMake(labelSize.width + (label.frame.size.width - labelSize.width) / 2 + spinner.frame.size.width, label.center.y)
    spinner
  end
  
  def style_label_as_in_table_view_footer(label)
    label.backgroundColor = UIColor.clearColor
    label.font = UIFont.systemFontOfSize 15
    label.textColor = UIColor.colorWithRed 0.298039, green:0.337255, blue:0.423529, alpha:1
    label.shadowColor = UIColor.colorWithWhite 1, alpha:1
    label.shadowOffset = CGSizeMake(0, 1)
    label.textAlignment = UITextAlignmentCenter
    label
  end

  def set_gradients_for_cell(cell, color)
    @@cell_gradients_mapping ||= {
      :red.color     => :white.color,
      :yellow.color  => :darkGray.color,
      :green.color   => :white.color,
      :blue.color    => :black.color,
      :gray.color    => :black.color
    }

    cell.backgroundColor = Colors.cell_gradient_pattern_for_color(color)
    cell.textLabel.textColor = @@cell_gradients_mapping.objectForKey color
    cell.detailTextLabel.textColor = @@cell_gradients_mapping.objectForKey color if cell.detailTextLabel

    if color == UIColor.blueColor || color == UIColor.grayColor
      cell.detailTextLabel.textColor = UIColor.darkGrayColor
    end
  end
end
