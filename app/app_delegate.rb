class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    # controller = MenuController.alloc.init
    storyboard = UIStoryboard.storyboardWithName "Main", bundle: nil
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = storyboard.instantiateInitialViewController
    @window.makeKeyAndVisible
    true
  end
end