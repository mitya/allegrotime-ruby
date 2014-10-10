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

  def styleClosingCell(cell, color)
    p color.mkname
    cell.backgroundColor = Colors.closingCellBackgroundFor(color)
    cell.textLabel.textColor = Colors.barTextColorFor(color)
    cell.detailTextLabel.textColor = Colors.secondaryTextColorFor(color) if cell.detailTextLabel
  end
  
  def selectedCellBackgroundView
    UIView.alloc.init.tap { |v| v.backgroundColor = Colors.closingCellBackgroundFor(:blue.color) }
  end
  
  def styleCellSelectionColors(cell)
    # cell.selectedBackgroundView = selectedCellBackgroundView
    # cell.textLabel.highlightedTextColor = :black.color
    # cell.detailTextLabel.highlightedTextColor = :black.color
  end
end
