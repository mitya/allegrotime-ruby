class StatusViewController < UIViewController
  def init() super
    self.title = "main.title".l
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("main.tab".l, image:Device.image_named("ti-semaphore"), selectedImage:Device.image_named("ti-semaphore-filled"))
    self
  end  

  def loadView
    self.view = StatusView.alloc.initWithFrame(CGRectZero)
  end
end
