class AboutController < UIViewController
  attr_accessor :webView

  def viewDidLoad
    self.title = 'about.title'.l
    self.webView = UIWebView.alloc.initWithFrame view.bounds
    webView.backgroundColor = UIColor.whiteColor
    webView.delegate = self
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    view.addSubview webView
  end

  def viewWillAppear(animated) super
    Device.trackScreen :about
    htmlPath = NSBundle.mainBundle.pathForResource "about", ofType:"html"
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
