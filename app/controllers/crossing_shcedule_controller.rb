class CrossingScheduleController < UITableViewController
  attr_accessor :crossing

  def viewDidLoad
    super
    self.title = self.crossing.name
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    MXAutorotationPolicy(interfaceOrientation)
  end

  ### table view

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
      cell.textLabel.text = "Переезд на карте"
      cell.detailTextLabel.text = NSString.stringWithFormat "%i км", crossing.distance
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      return cell
    end

    cell = tableView.dequeueReusableCellWithIdentifier MXDefaultCellID
    unless cell
      cell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleValue2, reuseIdentifier:MXDefaultCellID
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell.textLabel.font = UIFont.boldSystemFontOfSize 18
      cell.textLabel.backgroundColor = UIColor.clearColor
      cell.detailTextLabel.font = UIFont.boldSystemFontOfSize 12
      cell.detailTextLabel.backgroundColor = UIColor.clearColor
    end

    cell.textLabel.textColor = Helper.blueTextColor
    cell.detailTextLabel.textColor = UIColor.grayColor

    closing = crossing.closings.objectAtIndex(indexPath.row)

    if closing.isClosest
      cell.backgroundColor = MXCellGradientColorFor(closing.color)
      if closing.color == UIColor.greenColor || closing.color == UIColor.redColor
        cell.textLabel.textColor = UIColor.whiteColor
        cell.detailTextLabel.textColor = UIColor.lightTextColor
      end
    end

    cell.textLabel.text = closing.toRussia ? NSString.stringWithFormat("%@ ↶", closing.time) : closing.time
    cell.detailTextLabel.text = NSString.stringWithFormat("№%i", closing.trainNumber)

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

  ### handlers

  def modelUpdated
    tableView.reloadData
  end

  def showMap
    if navigationController.viewControllers.containsObject app.mapController
      navigationController.popToViewController app.mapController, animated:YES
    else
      navigationController.pushViewController app.mapController, animated:YES
    end
    app.mapController.showCrossing self.crossing
  end
end
