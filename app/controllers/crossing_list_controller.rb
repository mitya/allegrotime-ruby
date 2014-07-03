class CrossingListController < UITableViewController
  attr_accessor :target, :action, :accessoryType

  def viewDidLoad
    self.title = "Переезды"
  end

  def viewDidAppear(animated)
    super
    currentRowIndex = NSIndexPath.indexPathForRow model.currentCrossing.index, inSection:0
    tableView.scrollToRowAtIndexPath currentRowIndex, atScrollPosition:UITableViewScrollPositionMiddle, animated:YES
  end

  ### handlers

  def modelUpdated
    tableView.reloadData
  end

  ### table view

  def tableView(tableView, numberOfRowsInSection:section)
    model.crossings.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    crossing = model.crossings.objectAtIndex(indexPath.row)

    cell = tableView.dequeueReusableCellWithIdentifier MXDefaultCellID
    unless cell
      cell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleSubtitle, reuseIdentifier:MXDefaultCellID
      # cell.backgroundColor = UIColor.whiteColor
      # cell.detailTextLabel.backgroundColor = UIColor.clearColor
    end


    cell.textLabel.text = crossing.name
    cell.detailTextLabel.text = crossing.subtitle
    cell.imageView.image = Device.image_named("cell-stripe-#{crossing.color.mkname}")

    if accessoryType == UITableViewCellAccessoryCheckmark
      cell.accessoryType = crossing == model.currentCrossing ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    else
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    end

    Widgets.set_gradients_for_cell(cell, UIColor.grayColor) if crossing.closest?
    Widgets.set_gradients_for_cell(cell, UIColor.blueColor) if crossing.current?

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath indexPath, animated:YES

    if accessoryType == UITableViewCellAccessoryCheckmark
      for cell in tableView.visibleCells
        cell.accessoryType = UITableViewCellAccessoryNone if cell.accessoryType == UITableViewCellAccessoryCheckmark
      end

      cell = tableView.cellForRowAtIndexPath indexPath
      cell.accessoryType = UITableViewCellAccessoryCheckmark
    end

    if target && action
      crossing = model.crossings.objectAtIndex indexPath.row
      target.performSelector action, withObject:crossing
    end
  end

  def tableView(tableView, viewForHeaderInSection:section)
    label = Widgets.style_label_as_in_table_view_footer(UILabel.new)
    label.text = model.closestCrossing ?
        NSString.stringWithFormat("Ближайший — %@", model.closestCrossing.name) :
        "Ближайший переезд не определен"
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    30
  end
end
