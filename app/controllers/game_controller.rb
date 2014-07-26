class GameController < UIViewController
  attr_accessor :easy_mode

  def loadView
    view = SKView.new
    view.showsFPS = true
    view.showsNodeCount = true
    view.showsDrawCount = true

    self.view = view
  end

  def prefersStatusBarHidden
    true
  end

  def viewWillLayoutSubviews
    super

    unless self.view.scene
      scene = GameScene.alloc.initWithSize(view.bounds.size)
      scene.scaleMode = SKSceneScaleModeAspectFill

      weak_self = WeakRef.new self
      scene.end_game_callback = lambda { weak_self.navigationController.popViewControllerAnimated true }

      view.presentScene scene
    end
  end
end