class CrossingListController < UITableViewController
  attr_accessor :target, :action, :accessoryType

  def viewDidLoad
    self.title = "crossings.title".l
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithImage(Device.image_named("bb-define_location"), 
        style:UIBarButtonItemStylePlain, target:self, action:'selectClosestCrossing')
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
  
  def selectClosestCrossing
    closestCrossingIndex = model.crossings.indexOfObject(model.closestCrossing)
    indexPath = NSIndexPath.indexPathForRow(closestCrossingIndex, inSection:0)
    
    # tableView.deselectRowAtIndexPath indexPath, animated:YES

    if accessoryType == UITableViewCellAccessoryCheckmark
      for cell in tableView.visibleCells
        cell.accessoryType = UITableViewCellAccessoryNone if cell.accessoryType == UITableViewCellAccessoryCheckmark
      end

      cell = tableView.cellForRowAtIndexPath indexPath
      cell.accessoryType = UITableViewCellAccessoryCheckmark
    end
    
    model.currentCrossing = model.closestCrossing
    tableView.reloadData    
  end

  ### table view

  def tableView(tableView, numberOfRowsInSection:section)
    model.crossings.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    crossing = model.crossings.objectAtIndex(indexPath.row)

    cell = tableView.dequeueReusableCellWithIdentifier(MXDefaultCellID) || begin
      UITableViewCell.alloc.initWithStyle UITableViewCellStyleSubtitle, reuseIdentifier:MXDefaultCellID
    end

    cell.textLabel.text = crossing.localizedName
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
        'crossings.closest'.li(model.closestCrossing.localizedName) :
        'crossings.closest_undefined'.l
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    30
  end
end
