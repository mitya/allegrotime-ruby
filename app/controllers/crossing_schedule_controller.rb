class CrossingScheduleController < UITableViewController
  attr_accessor :crossing

  def viewDidLoad
    self.title = self.crossing.localizedName
  end



  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if section == 1
      1
    else
      crossing.closings.count
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    if indexPath.section == 1
      cell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleValue1, reuseIdentifier:nil
      cell.textLabel.text = 'schedule.show_crossing_map'.l
      cell.detailTextLabel.text = 'x km'.li(crossing.distance)
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      return cell
    end

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
    if indexPath.section == 1 && indexPath.row == 0
      showMap
      return
    end

    trainScheduleController = TrainScheduleController.alloc.initWithStyle UITableViewStyleGrouped
    trainScheduleController.sampleClosing = crossing.closings.objectAtIndex indexPath.row
    navigationController.pushViewController trainScheduleController, animated:YES
  end



  def modelUpdated
    tableView.reloadData
  end

  def showMap    
    App.mapController.crossingToShowOnNextAppearance = crossing
    tabBarController.selectedViewController = App.mapController.navigationController
  end
end
