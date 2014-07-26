class GameController < UIViewController
  attr_accessor :easy_mode

  def loadView
    view = SKView.new
    self.view = view
  end

  def prefersStatusBarHidden
    true
  end

  def viewDidLoad
    super

    view.showsFPS = true
    view.showsNodeCount = true
    view.showsDrawCount = true
    black_scene = SKScene.alloc.initWithSize view.bounds.size
    black_scene.backgroundColor = UIColor.blackColor
    view.presentScene black_scene
  end


  def viewDidAppear(animated)
    super animated

    scene = OpeningScene.sceneWithSize view.bounds.size
    scene.scaleMode = SKSceneScaleModeAspectFill
    transition = SKTransition.fadeWithDuration 1
    view.presentScene(scene, transition: transition)

    weak_self = WeakRef.new(self)
    scene.scene_end_callback = lambda do
      scene = GameScene.alloc.initWithSize(view.bounds.size)
      scene.scaleMode = SKSceneScaleModeAspectFill
      scene.easy_mode = @easy_mode
      scene.end_game_callback = lambda { weak_self.navigationController.popViewControllerAnimated true }
      transition = SKTransition.fadeWithColor(UIColor.blackColor, duration: 1)
      view.presentScene(scene, transition: transition)
    end
  end
end