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

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    MXAutorotationPolicy(interfaceOrientation)
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


    cell.textLabel.text = crossing.name;
    cell.detailTextLabel.text = crossing.subtitle;
    cell.imageView.image = MXImageFromFile(NSString.stringWithFormat("cell-stripe-%@.png", MXNameForColor(crossing.color)))

    if accessoryType == UITableViewCellAccessoryCheckmark
      cell.accessoryType = crossing == model.currentCrossing ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    else
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    end

    MXSetGradientForCell(cell, UIColor.grayColor) if crossing.isClosest
    MXSetGradientForCell(cell, UIColor.blueColor) if crossing.isCurrent

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
    label = MXConfigureLabelLikeInTableViewFooter(UILabel.new)
    label.text = model.closestCrossing ?
        NSString.stringWithFormat("Ближайший — %@", model.closestCrossing.name) :
        "Ближайший переезд не определен"
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    30
  end
end
