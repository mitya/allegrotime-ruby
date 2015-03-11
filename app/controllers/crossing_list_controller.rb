class CrossingListController < UITableViewController
  attr_accessor :target, :action, :accessoryType

  def initWithStyle(tableViewStyle)
    super
    self.title = "crossings.title".l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("crossings.tab".l, image:Device.image_named("ti-schedule"), selectedImage:Device.image_named("ti-schedule-filled"))
    self
  end

  def viewDidLoad
    if Model.closestCrossing
      navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithImage(Device.image_named("bb-define_location"), 
          style:UIBarButtonItemStylePlain, target:self, action:'selectClosestCrossing')
    end
  end

  def viewWillAppear(animated)
    super
    
    if !@initialScrollDone
      scrollToCrossing Model.currentCrossing, animated:NO
      @initialScrollDone = true
    end
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
  
  def screenActivated
    tableView.reloadData
  end
  
  def screenDeactivated
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
      showScheduleForCrossing(crossing, animated:YES)
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    Model.closestCrossing ? 'crossings.closest'.li(Model.closestCrossing.localizedName) : 'crossings.closest_undefined'.l
  end
  
  def tableView(tableView, viewForHeaderInSection:section)
    label = Widgets.labelAsInTableViewFooter
    label.text = tableView(tableView, titleForHeaderInSection:section)
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    TABLE_VIEW_HEADER_HEIGHT
  end

  
  
  def scrollToCrossing(crossing, animated:animated)
    crossingIndex = NSIndexPath.indexPathForRow crossing.index, inSection:0
    puts "scrolling #{crossing.inspect} #{crossingIndex.inspect}"
    tableView.scrollToRowAtIndexPath crossingIndex, atScrollPosition:UITableViewScrollPositionMiddle, animated:animated
  end
  
  def showScheduleForCrossing(crossing, animated:animated)
    puts "show #{crossing.inspect}"
    scheduleController = CrossingScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    scheduleController.crossing = crossing
    navigationController.pushViewController scheduleController, animated:animated
  end
  
  def selectCrossing(crossing, animated:animated)
    crossingIndex = NSIndexPath.indexPathForRow crossing.index, inSection:0
    puts "selecting #{crossing.inspect} #{crossingIndex.inspect}"
    tableView.selectRowAtIndexPath crossingIndex, animated:animated, scrollPosition:UITableViewScrollPositionMiddle
  end
end
