class LogViewController < UIViewController
  attr_accessor :log, :logText, :table

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end

  def viewDidLoad
    self.title = "Лог";

    self.table = UITableView.alloc.initWithFrame view.bounds, style:UITableViewStylePlain
    table.delegate = self
    table.dataSource = self
    table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    view.addSubview table

    NSNotificationCenter.defaultCenter.addObserver self, selector:'consoleUpdated', name:NXDefaultCellIDLogConsoleUpdated, object:nil
    NSNotificationCenter.defaultCenter.addObserver self, selector:'consoleFlushed', name:NXDefaultCellIDLogConsoleFlushed, object:nil

    swipeRecognizer = UISwipeGestureRecognizer.alloc.initWithTarget self, action:'recognizedSwipe:'
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight
    view.addGestureRecognizer swipeRecognizer
  end



  def consoleUpdated
    startTime = CFAbsoluteTimeGetCurrent()

    isFirstRowVisible = table.indexPathsForVisibleRows.containsObject NSIndexPath.indexPathForRow(0, inSection:0)
    if isFirstRowVisible && table.numberOfRowsInSection(0) == storage.count - 1
      table.insertRowsAtIndexPaths NSArray.arrayWithObject(NSIndexPath.indexPathForRow(0, inSection:0)), withRowAnimation:UITableViewRowAnimationFade
    else
      table.reloadData
    end
  end

  def consoleFlushed
    table.reloadSections NSIndexSet.indexSetWithIndex(0), withRowAnimation:UITableViewRowAnimationMiddle
  end

  def recognizedSwipe(recognizer)
    point = recognizer.locationInView view
    navigationController.popViewControllerAnimated YES if point.y > 300
  end



  def tableView(tableView, numberOfRowsInSection:section)
    storage.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    message = storage[storage.count - 1 - indexPath.row]

    cell = tableView.dequeueReusableCellWithIdentifier NXDefaultCellID
    if !cell
      cell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:NXDefaultCellID
      cell.selectionStyle = UITableViewCellSelectionStyleGray;
      cell.textLabel.font = UIFont.systemFontOfSize 10
      cell.textLabel.numberOfLines = 0
      cell.textLabel.lineBreakMode = UILineBreakModeWordWrap
    end

    cell.textLabel.text = message

    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    message = storage[storage.count - 1 - indexPath.row]
    font = UIFont.systemFontOfSize 10
    constraintSize = CGSizeMake(tableView.bounds.size.width - 20, 10_000)
    labelSize = message.sizeWithFont font, constrainedToSize:constraintSize, lineBreakMode:NSLineBreakByWordWrapping
    labelSize.height + 6
  end
  
  def storage
    $logging_buffer
  end
end
