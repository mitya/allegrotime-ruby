class CrossingScheduleController < UITableViewController
  attr_accessor :crossing

  def initWithStyle(tableViewStyle) super
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("crossings.tab".l, image:Device.image_named("ti-schedule"), selectedImage:Device.image_named("ti-schedule-filled"))
    navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle "main.crossing_cell".l, style:UIBarButtonItemStyleBordered, target:nil, action:nil
    self
  end

  def viewWillAppear(animated) super
    navigationItem.title = crossing.localizedName
    Device.trackScreen :crossing_schedule, crossing
  end


  def tableView(tableView, numberOfRowsInSection:section)
    crossing.closings.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeue_cell UITableViewCellStyleValue2 do |cell|
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell.textLabel.backgroundColor = UIColor.clearColor
      cell.textLabel.textColor = Colors.mainCellTextColor
      cell.textLabel.font = UIFont.systemFontOfSize 18
      cell.detailTextLabel.backgroundColor = UIColor.clearColor
      cell.detailTextLabel.textColor = UIColor.grayColor
    end

    closing = crossing.closings.objectAtIndex(indexPath.row)
    
    Widgets.styleClosingCell(cell, closing.color) if closing.closest?

    cell.textLabel.text = closing.toRussia? ? "↶ #{closing.time}" : closing.time
    cell.detailTextLabel.text = 'no x'.li(closing.trainNumber)

    cell
  end

  def tableView tableView, didSelectRowAtIndexPath:indexPath
    trainScheduleController = TrainScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    trainScheduleController.sampleClosing = crossing.closings.objectAtIndex indexPath.row
    navigationController.pushViewController trainScheduleController, animated:YES
  end


  def crossing
    Model.currentCrossing
  end

  def modelUpdated
    tableView.reloadData
  end

  def showMap
    Device.trackUI :tap_show_crossing_map, crossing
    tabBarController.selectedViewController = App.mapController.navigationController
  end
end
