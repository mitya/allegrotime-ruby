def TrainScheduleController
  attr_accessor sampleClosing

  def viewDidLoad
    super
    self.title = NSString.stringWithFormat "Поезд №%i", sampleClosing.trainNumber
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    MXAutorotationPolicy(interfaceOrientation)
  end

  ### table view

  def tableView(tableView, numberOfRowsInSection:section)
    model.crossings.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier MXDefaultCellID
    if !cell
      cell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleValue2, reuseIdentifier:MXDefaultCellID
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.textLabel.font = UIFont.boldSystemFontOfSize 18
      cell.detailTextLabel.font = UIFont.boldSystemFontOfSize 12
    end

    trainIndex = sampleClosing.crossing.closings.indexOfObject sampleClosing
    crossing = model.crossings.objectAtIndex indexPath.row
    closing = crossing.closings.objectAtIndex trainIndex

    cell.textLabel.text = closing.time
    cell.detailTextLabel.text = closing.crossing.name

    cell
  end

  def tableView(tableView, viewForHeaderInSection:section)
    label = MXConfigureLabelLikeInTableViewFooter UILabel.new
    label.text = sampleClosing.toRussia ? "Из Хельсинки в Санкт-Петербург" : "Из Санкт-Петербурга в Хельсинки"
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    30
  end
end
