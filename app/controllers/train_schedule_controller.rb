class TrainScheduleController < UITableViewController
  attr_accessor :sampleClosing

  def viewDidLoad
    self.title = "schedule.train_no".li(sampleClosing.trainNumber)
    
    @trainIndex = @sampleClosing.crossing.closings.indexOfObject @sampleClosing
    @crossings = @sampleClosing.toRussia?? Model.reverseCrossings : Model.crossings
  end

  def viewWillAppear(animated) super
    Device.trackScreen :train_schedule, sampleClosing
  end


  def tableView(tableView, numberOfRowsInSection:section)
    Model.crossings.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeue_cell UITableViewCellStyleValue2 do |cell|
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end

    crossing = @crossings[indexPath.row]
    closing = crossing.closings[@trainIndex]

    cell.textLabel.text = closing ? closing.time : "неизвестно"
    cell.detailTextLabel.text = crossing.localizedName

    cell
  end

  def tableView(tableView, titleForHeaderInSection:section)
    sampleClosing.toRussia? ? 'schedule.hel_spb'.l : 'schedule.spb_hel'.l
  end

  def tableView(tableView, viewForHeaderInSection:section)
    label = Widgets.labelAsInTableViewFooter
    label.text = tableView(tableView, titleForHeaderInSection:section)
    label
  end

  def tableView(tableView, heightForHeaderInSection:section)
    TABLE_VIEW_HEADER_HEIGHT
  end
end
