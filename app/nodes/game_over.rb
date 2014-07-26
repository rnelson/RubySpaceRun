class GameOver < SKNode
  def init
    super

    label = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Heavy'
    label.fontSize = 32
    label.fontColor = UIColor.whiteColor
    label.text = 'Game Over'
    addChild label

    label.alpha = 0
    label.xScale = 0.2
    label.yScale = 0.2
    fade_in = SKAction.fadeAlphaTo(1, duration: 2)
    scale_in = SKAction.scaleTo(1, duration: 2)
    fade_and_scale = SKAction.group [fade_in, scale_in]
    label.runAction fade_and_scale

    instructions = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Medium'
    instructions.fontSize = 14
    instructions.fontColor = UIColor.whiteColor
    instructions.text = 'Tap to try again.'
    instructions.position = CGPointMake 0, -45
    addChild instructions

    instructions.alpha = 0
    wait = SKAction.waitForDuration 4
    appear = SKAction.fadeAlphaTo(1, duration: 0.2)
    pop_up = SKAction.scaleTo(1.1, duration: 0.1)
    drop_down = SKAction.scaleTo(1, duration: 0.1)
    pause_and_appear = SKAction.sequence [wait, appear, pop_up, drop_down]
    instructions.runAction pause_and_appear


    self
  end
end