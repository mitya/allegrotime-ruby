class AboutController
  attr_accessor :webView

  def viewDidLoad
    super

    self.title = "О программе"

    self.webView = UIWebView.alloc.initWithFrame view.bounds
    webView.backgroundColor = UIColor.yellowColor
    webView.delegate = self
    view.addSubview webView
  end

  def viewWillAppear(animated)
    super

    htmlPath = NSBundle.mainBundle.pathForResource "data/about", ofType:"html"
    htmlString = NSString.stringWithContentsOfFile htmlPath, encoding:NSUTF8StringEncoding, error:NULL
    webView.loadHTMLString htmlString, baseURL:NSURL.URLWithString("/")
  end

  def webView(theWebView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    if navigationType == UIWebViewNavigationTypeLinkClicked
      UIApplication.sharedApplication.openURL request.URL
      NO
    else
      YES
    end
  end
end
