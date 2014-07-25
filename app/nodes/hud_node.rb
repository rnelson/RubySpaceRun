class HUDNode < SKNode
  attr_accessor :elapsed_time
  
  def init
    super

    addChild build_score_group
    addChild build_time_group

    @elapsed_time = 0.0
    @score = 0
  end

  def layout_for_scene
    scene_size = scene.size
    group_size = CGSizeZero

    score_group = childNodeWithName 'scoreGroup'
    group_size = score_group.calculateAccumulatedFrame.size
    score_group.position = CGPointMake 0 -  scene_size.width / 2 + 20, scene_size.height / 2 - group_size.height

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

  def add_points(points)
    @score += points

    score_value = childNodeWithName 'scoreGroup/scoreValue'
    score_value.text = @score.to_s

    scale = SKAction.scaleTo(1.1, duration: 0.02)
    shrink = SKAction.scaleTo(1, duration: 0.07)
    seq = SKAction.sequence [scale, shrink]
    score_value.runAction seq
  end

  def start_game
    start_time = NSDate.dateWithTimeIntervalSinceReferenceDate
    elapsed_value = childNodeWithName 'timeGroup/elapsedValue'
    
    weak_self = WeakRef.new self
    update = SKAction.runBlock(lambda do
      now = NSDate.dateWithTimeIntervalSinceReferenceDate
      elapsed = now - start_time
      weak_self.elapsed_time = elapsed
      elapsed_value.text = elapsed.to_s
    end)
    
    delay = SKAction.waitForDuration 0.05
    update_and_delay = SKAction.sequence [update, delay]
    timer = SKAction.repeatActionForever update_and_delay
    runAction(timer, withKey: 'elapsedGameTimer')
  end

  def end_game
    removeActionForKey 'elapsedGameTimer'
  end
end