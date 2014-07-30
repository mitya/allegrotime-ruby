class LogViewController < UIViewController
  attr_accessor :log, :logText, :table

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end

  def viewDidLoad
    self.title = "Лог";

    table = UITableView.alloc.initWithFrame view.bounds, style:UITableViewStylePlain
    table.delegate = self;
    table.dataSource = self;
    table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.addSubview table

    NSNotificationCenter.defaultCenter.addObserver self, selector:'consoleUpdated', name:NXLogConsoleUpdated, object:nil
    NSNotificationCenter.defaultCenter.addObserver self, selector:'consoleFlushed', name:NXLogConsoleFlushed, object:nil

    swipeRecognizer = UISwipeGestureRecognizer.alloc.initWithTarget self, action:'recognizedSwipe:'
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight
    view.addGestureRecognizer swipeRecognizer
  end

  ### handlers

  def consoleUpdated
    startTime = CFAbsoluteTimeGetCurrent()

    isFirstRowVisible = table.indexPathsForVisibleRows.containsObject NSIndexPath.indexPathForRow(0, inSection:0)
    if isFirstRowVisible && table.numberOfRowsInSection(0) == MXGetConsole().count - 1
      table.insertRowsAtIndexPaths NSArray.arrayWithObject(NSIndexPath.indexPathForRow(0, inSection:0)), withRowAnimation:UITableViewRowAnimationFade
    else
      table.reloadData
    end

    Log.info "%@ updated in %d", __func__, startTime - CFAbsoluteTimeGetCurrent()
  end

  def consoleFlushed
    table.reloadSections NSIndexSet.indexSetWithIndex(0), withRowAnimation:UITableViewRowAnimationMiddle
  end

  def recognizedSwipe(recognizer)
    point = recognizer.locationInView view
    navigationController.popViewControllerAnimated YES if point.y > 300
  end

  ### table view

  def tableView(tableView, numberOfRowsInSection:section)
    MXGetConsole().count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    console = MXGetConsole()
    message = console.objectAtIndex (console.count - 1 - indexPath.row)

    cell = tableView.dequeueReusableCellWithIdentifier MXDefaultCellID
    if !cell
      cell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:MXDefaultCellID
      cell.selectionStyle = UITableViewCellSelectionStyleGray;
      cell.textLabel.font = UIFont.systemFontOfSize 12
      cell.textLabel.numberOfLines = 0
      cell.textLabel.lineBreakMode = UILineBreakModeWordWrap
    end

    cell.textLabel.text = message

    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    console = MXGetConsole()
    message = console.objectAtIndex console.count - 1 - indexPath.row
    font = UIFont.systemFontOfSize 12
    onstraintSize = CGSizeMake(table.bounds.size.width - 20, MAXFLOAT)
    labelSize = message.sizeWithFont font, constrainedToSize:constraintSize, lineBreakMode:NSLineBreakByWordWrapping
    labelSize.height + 6
  end
end
