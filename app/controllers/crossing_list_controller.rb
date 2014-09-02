class CrossingListController < UITableViewController
  attr_accessor :target, :action, :accessoryType

  def viewDidLoad
    self.title = "crossings.title".l

    if Model.closestCrossing
      navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithImage(Device.image_named("bb-define_location"), 
          style:UIBarButtonItemStylePlain, target:self, action:'selectClosestCrossing')
    end
  end

  def viewDidAppear(animated)
    super
    currentRowIndex = NSIndexPath.indexPathForRow Model.currentCrossing.index, inSection:0
    tableView.scrollToRowAtIndexPath currentRowIndex, atScrollPosition:UITableViewScrollPositionMiddle, animated:YES
  end
  
  ### handlers

  def modelUpdated
    tableView.reloadData
  end
  
  def selectClosestCrossing
    closestCrossingIndex = Model.crossings.indexOfObject(Model.closestCrossing)
    closestCrossingIndexPath = NSIndexPath.indexPathForRow(closestCrossingIndex, inSection:0)
    
    if accessoryType == UITableViewCellAccessoryCheckmark
      tableView.visibleCells.
        select { |cell| cell.accessoryType == UITableViewCellAccessoryCheckmark }.
        each { |cell| cell.accessoryType = UITableViewCellAccessoryNone }

      if closestCrossingCell = tableView.cellForRowAtIndexPath(closestCrossingIndexPath)
        closestCrossingCell.accessoryType = UITableViewCellAccessoryCheckmark
      end
    end
    
    Model.currentCrossing = Model.closestCrossing

    tableView.reloadData
    tableView.scrollToRowAtIndexPath closestCrossingIndexPath, atScrollPosition:UITableViewScrollPositionMiddle, animated:YES
  end

  ### table view

  def tableView(tableView, numberOfRowsInSection:section)
    Model.crossings.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    crossing = Model.crossings[indexPath.row]

    cell = tableView.dequeue_cell UITableViewCellStyleSubtitle do |cell|
      Widgets.styleCellSelectionColors(cell)
    end

    cell.textLabel.text = crossing.localizedName
    cell.detailTextLabel.text = crossing.subtitle
    cell.imageView.image = VX.stripeForCrossing(crossing)

    if accessoryType == UITableViewCellAccessoryCheckmark
      cell.accessoryType = crossing.current? ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    else
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    end

    tableView.selectRowAtIndexPath indexPath, animated:NO, scrollPosition:UITableViewScrollPositionNone if crossing.current?

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if accessoryType == UITableViewCellAccessoryCheckmark
      tableView.visibleCells.
        select { |cell| cell.accessoryType == UITableViewCellAccessoryCheckmark }.
        each { |cell| cell.accessoryType = UITableViewCellAccessoryNone }

      cell = tableView.cellForRowAtIndexPath indexPath
      cell.accessoryType = UITableViewCellAccessoryCheckmark
    end

    if target && action
      crossing = Model.crossings.objectAtIndex indexPath.row
      target.performSelector action, withObject:crossing
    end
  end

  def tableView(tableView, viewForHeaderInSection:section)
    label = Widgets.style_label_as_in_table_view_footer(UILabel.new)
    label.text = Model.closestCrossing ? 
        'crossings.closest'.li(Model.closestCrossing.localizedName) :
        'crossings.closest_undefined'.l
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    30
  end
end
