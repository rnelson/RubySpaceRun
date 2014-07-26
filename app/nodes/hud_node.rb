class HUDNode < SKNode
  attr_accessor :elapsed_time
  attr_accessor :score
  
  def init
    super

    powerup = build_powerup_group
    powerup.alpha = 0

    addChild build_score_group
    addChild powerup
    addChild build_time_group

    @elapsed_time = 0.0
    @score = 0

    self
  end

  def layout_for_scene
    scene_size = scene.size
    group_size = CGSizeZero

    score_group = childNodeWithName 'scoreGroup'
    group_size = score_group.calculateAccumulatedFrame.size
    score_group.position = CGPointMake 0 -  scene_size.width / 2 + 20, scene_size.height / 2 - group_size.height

    powerup_group = childNodeWithName 'powerupGroup'
    group_size = powerup_group.calculateAccumulatedFrame.size
    powerup_group.position = CGPointMake 0, scene_size.height / 2 - group_size.height

    elapsed_group = childNodeWithName 'timeGroup'
    group_size = elapsed_group.calculateAccumulatedFrame.size
    elapsed_group.position = CGPointMake scene_size.width / 2 - 20, scene_size.height / 2 - group_size.height
  end

  def build_score_group
    score_group = SKNode.node
    score_group.name = 'scoreGroup'

    score_title = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Medium'
    score_title.fontSize = 12
    score_title.fontColor = UIColor.whiteColor
    score_title.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft
    score_title.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom
    score_title.text = 'SCORE'
    score_title.position = CGPointMake 0, 4
    score_group.addChild score_title

    score_value = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Bold'
    score_value.fontSize = 20
    score_value.fontColor = UIColor.whiteColor
    score_value.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft
    score_value.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop
    score_value.name = 'scoreValue'
    score_value.text = '0'
    score_value.position = CGPointMake 0, -4
    score_group.addChild score_value

    score_group
  end

  def build_time_group
    time_group = SKNode.node
    time_group.name = 'timeGroup'

    elapsed_title = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Medium'
    elapsed_title.fontSize = 12
    elapsed_title.fontColor = UIColor.whiteColor
    elapsed_title.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight
    elapsed_title.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom
    elapsed_title.text = 'TIME'
    elapsed_title.position = CGPointMake 0, 4
    time_group.addChild elapsed_title

    elapsed_value = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Bold'
    elapsed_value.fontSize = 20
    elapsed_value.fontColor = UIColor.whiteColor
    elapsed_value.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight
    elapsed_value.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop
    elapsed_value.name = 'elapsedTimeValue'
    elapsed_value.text = '0.0s'
    elapsed_value.position = CGPointMake 0, -4
    time_group.addChild elapsed_value

    time_group
  end

  def build_powerup_group
    powerup_group = SKNode.node
    powerup_group.name = 'powerupGroup'

    title = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Bold'
    title.fontSize = 14
    title.fontColor = UIColor.redColor
    title.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom
    title.text = 'Power-up!'
    title.position = CGPointMake 0, 4
    powerup_group.addChild title

    scale_up = SKAction.scaleTo(1.3, duration: 0.3)
    scale_down = SKAction.scaleTo(1, duration: 0.3)
    pulse = SKAction.sequence [scale_up, scale_down]
    pulse_forever = SKAction.repeatActionForever pulse
    title.runAction pulse_forever

    value = SKLabelNode.labelNodeWithFontNamed 'AvenirNext-Bold'
    value.fontSize = 20
    value.fontColor = UIColor.redColor
    value.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop
    value.name = 'powerupValue'
    value.text = '0s left'
    value.position = CGPointMake 0, -4
    powerup_group.addChild value

    powerup_group
  end

  def add_points(points)
    @score += points

    score_value = childNodeWithName 'scoreGroup/scoreValue'
    score_value.text = @score.to_i.to_s

    scale = SKAction.scaleTo(1.1, duration: 0.02)
    shrink = SKAction.scaleTo(1, duration: 0.07)
    seq = SKAction.sequence [scale, shrink]
    score_value.runAction seq
  end

  def start_game
    start_time = NSDate.timeIntervalSinceReferenceDate
    elapsed_value = childNodeWithName 'timeGroup/elapsedTimeValue'
    
    weak_self = WeakRef.new self
    update = SKAction.runBlock(lambda do
      now = NSDate.timeIntervalSinceReferenceDate
      elapsed = now - start_time
      weak_self.elapsed_time = elapsed
      elapsed_value.text = elapsed.round(0).to_s
    end)
    
    delay = SKAction.waitForDuration 0.05
    update_and_delay = SKAction.sequence [update, delay]
    timer = SKAction.repeatActionForever update_and_delay
    runAction(timer, withKey: 'elapsedGameTimer')
  end

  def end_game
    removeActionForKey 'elapsedGameTimer'

    powerup_group = childNodeWithName 'powerupGroup'
    powerup_group.removeActionForKey 'showPowerupTimer'

    fade_out = SKAction.fadeAlphaTo(0, duration: 0.3)
    powerup_group.runAction fade_out
  end

  def show_powerup_timer(time)
    powerup_group = childNodeWithName 'powerupGroup'
    powerup_value = powerup_group.childNodeWithName 'powerupValue'

    powerup_group.removeActionForKey 'showPowerupTimer'

    start = NSDate.timeIntervalSinceReferenceDate
    weak_self = WeakRef.new self
    block = SKAction.runBlock(lambda do
      elapsed = NSDate.timeIntervalSinceReferenceDate - start
      left = time - elapsed
      left = 0 if left < 0
      powerup_value.text = "#{left.round(1).to_s} left"
    end)
    block_pause = SKAction.waitForDuration 0.05
    countdown_sequence = SKAction.sequence [block, block_pause]
    countdown = SKAction.repeatActionForever countdown_sequence
    
    fade_in = SKAction.fadeAlphaTo(1, duration: 0.1)
    wait = SKAction.waitForDuration time
    fade_out = SKAction.fadeAlphaTo(0, duration: 1)
    stop_action = SKAction.runBlock(lambda do
      powerup_group.removeActionForKey 'showPowerupTimer'
    end)
    
    visuals = SKAction.sequence [fade_in, wait, fade_out, stop_action]
    powerup_group.runAction(SKAction.group [countdown, visuals], withKey: 'showPowerupTimer')
  end
end