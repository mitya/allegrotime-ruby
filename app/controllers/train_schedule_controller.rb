class TrainScheduleController < UITableViewController
  attr_accessor :sampleClosing

  def viewDidLoad
    super
    self.title = "Поезд №#{sampleClosing.trainNumber}" 
    # self.title = Helper.stringWithFormat "Поезд №%i", sampleClosing.trainNumber
    # self.title = "schedule.train_no".li(sampleClosing.trainNumber)
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
    end

    trainIndex = sampleClosing.crossing.closings.indexOfObject sampleClosing
    crossing = model.crossings.objectAtIndex indexPath.row
    closing = crossing.closings.objectAtIndex trainIndex

    cell.textLabel.text = closing.time
    cell.detailTextLabel.text = closing.crossing.name

    cell
  end

  def tableView(tableView, viewForHeaderInSection:section)
    label = Widgets.style_label_as_in_table_view_footer UILabel.new
    label.text = sampleClosing.toRussia? ? "Из Хельсинки в Санкт-Петербург" : "Из Санкт-Петербурга в Хельсинки"
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    30
  end
end
