class MenuController < UIViewController
  extend IB

  outlet :difficulty_chooser, UISegmentedControl
  outlet :high_score_label, UILabel

  def prepareForSegue(segue, sender: sender)
    if segue.identifier == 'PlayGame'
      game_controller = segue.destinationViewController
      game_controller.easy_mode = self.difficulty_chooser.selectedSegmentIndex == 0
    else
      puts "Unknown segue identifier #{segue.identifier}"
    end
  end


  def viewDidAppear(animated)
    super animated

    @demo_view = SKView.alloc.initWithFrame view.bounds
    scene = SKScene.alloc.initWithSize view.bounds.size

    scene.backgroundColor = UIColor.blackColor
    scene.scaleMode = SKSceneScaleModeAspectFill

    star_field = StarField.node
    scene.addChild star_field

    @demo_view.presentScene scene
    view.insertSubview(@demo_view, atIndex: 0)
  end


  def viewDidDisappear(animated)
    super animated

    @demo_view.removeFromSuperview
    @demo_view = nil
  end
end