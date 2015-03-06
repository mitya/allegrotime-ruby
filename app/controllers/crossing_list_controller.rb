class CrossingListController < UITableViewController
  attr_accessor :target, :action, :accessoryType

  def init
    super
    self.title = "crossings.title".l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Schedule", image:Device.image_named("ti-clock"), tag:1)
    self
  end

  def viewDidLoad
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
  
  def activateScreen
    tableView.reloadData
  end
  
  def deactivateScreen
    tableView.visibleCells.each do |cell|
      cell.imageView.image = Device.image_named("cell-stripe-gray")
    end
  end



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
    cell.imageView.image = Widgets.stripeForCrossing(crossing)

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

    crossing = Model.crossings.objectAtIndex indexPath.row
    if target && action      
      target.performSelector action, withObject:crossing
    else
      showScheduleForCrossing(crossing)
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
  
  
  
  def showScheduleForCrossing(crossing)
    scheduleController = CrossingScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    scheduleController.crossing = crossing;
    navigationController.pushViewController scheduleController, animated:YES
  end
end
