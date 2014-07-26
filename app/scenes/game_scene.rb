class GameScene < SKScene
  attr_accessor :end_game_callback
  attr_accessor :easy_mode

  def initWithSize(size)
    super

    @last_update_time = 0
    @last_shot_fire_time = 0
    @ship_speed = 130
    @ship_fire_rate = 0.5
    @easy_mode = false
    @random = Random.new
    @end_game_callback =

    @shoot_sound = SKAction.playSoundFileNamed('shoot.m4a', waitForCompletion: false)
    @ship_explode_sound = SKAction.playSoundFileNamed('obstacleExplode.m4a', waitForCompletion: false)
    @obstacle_explode_sound = SKAction.playSoundFileNamed('shipExplode.m4a', waitForCompletion: false)

    self.backgroundColor = UIColor.blackColor

    # Add the star field
    addChild StarField.node

    # Create the ship
    ship = SKSpriteNode.spriteNodeWithImageNamed 'Spaceship.png'
    ship.name = 'ship'
    ship.position = CGPointMake size.width / 2, size.height / 2
    ship.size = CGSizeMake 40, 40
    addChild ship

    thrust = Extensions.node_with_file 'thrust.sks'
    thrust.position = CGPointMake 0, -20
    ship.addChild thrust

    hud_node = HUDNode.node
    hud_node.name = 'hud'
    hud_node.zPosition = 100
    hud_node.position = CGPointMake size.width / 2, size.height / 2
    addChild hud_node

    hud_node.layout_for_scene
    hud_node.start_game

    self
  end

  def touchesBegan(touches, withEvent: event)
    @shipTouch = WeakRef.new touches.anyObject
  end

  def update(current_time)
    @last_update_time = current_time if @last_update_time == 0
    time_delta = current_time - @last_update_time

    if @shipTouch and @shipTouch.weakref_alive?
      move_ship_toward_point @shipTouch.locationInNode(self), byTimeDelta: time_delta

      if current_time - @last_shot_fire_time > @ship_fire_rate
        shoot
        @last_shot_fire_time = current_time
      end
    end

    if @random.rand(1000) <= 15
      drop_thing
    end
    
    check_collisions

    @last_update_time = current_time
  end

  def move_ship_toward_point(point, byTimeDelta: time_delta)
    ship = childNodeWithName 'ship'
    return unless ship

    distance_left = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))

    if distance_left > 4
      distance_to_travel = time_delta * @ship_speed

      angle = atan2 point.y - ship.position.y, point.x - ship.position.x
      x_offset = distance_to_travel * cos(angle)
      y_offset = distance_to_travel * sin(angle)

      ship.position = CGPointMake ship.position.x + x_offset, ship.position.y + y_offset
    end
  end

  def shoot
    ship = childNodeWithName 'ship'
    return unless ship

    photon = SKSpriteNode.spriteNodeWithImageNamed 'photon'
    photon.name = 'photon'
    photon.position = ship.position
    addChild photon

    fly = SKAction.moveByX(0, y: size.height + photon.size.height, duration: 0.5)
    remove = SKAction.removeFromParent
    photon.runAction SKAction.sequence [fly, remove]

    runAction @shoot_sound
  end
  
  def drop_thing
    dice = @random.rand(100)

    if dice < 5
      drop_powerup
    elsif dice < 20
      drop_enemy_ship
    else
      drop_asteroid
    end
  end

  def drop_powerup
    side_size = 30
    start_x = @random.rand(size.width - 60) + 30
    start_y = size.height + side_size
    end_y = 0 - side_size

    powerup = SKSpriteNode.spriteNodeWithImageNamed 'powerup'
    powerup.name = 'powerup'
    powerup.size = CGSizeMake side_size, side_size
    powerup.position = CGPointMake start_x, start_y
    addChild powerup

    move = SKAction.moveTo(CGPointMake(start_x, end_y), duration: 6)
    spin = SKAction.rotateByAngle(-1, duration: 1)
    remove = SKAction.removeFromParent

    spin_forever = SKAction.repeatActionForever spin
    travel_and_remove = SKAction.sequence [move, remove]

    powerup.runAction SKAction.group [spin_forever, travel_and_remove]
  end
  
  def drop_enemy_ship
    side_size = 30
    start_x = @random.rand(size.width - 40) + 20
    start_y = size.height + side_size
    
    enemy = SKSpriteNode.spriteNodeWithImageNamed 'enemy'
    enemy.name = 'obstacle'
    enemy.size = CGSizeMake side_size, side_size
    enemy.position = CGPointMake start_x, start_y
    addChild enemy
    
    ship_path = build_enemy_ship_movement_path
    follow_path = SKAction.followPath(ship_path, asOffset: true, orientToPath: true, duration: 7)
    remove = SKAction.removeFromParent
    
    enemy.runAction SKAction.sequence [follow_path, remove]
  end

  def drop_asteroid
    side_size = 15 + @random.rand(30)
    max_x = size.width
    quarter_x = max_x / 4

    start_x = @random.rand(max_x + (quarter_x * 2)) - quarter_x
    start_y = size.height + side_size
    end_x = @random.rand(max_x)
    end_y = 0 - side_size

    asteroid = SKSpriteNode.spriteNodeWithImageNamed 'asteroid'
    asteroid.name = 'obstacle'
    asteroid.size = CGSizeMake side_size, side_size
    asteroid.position = CGPointMake start_x, start_y
    addChild asteroid

    move = SKAction.moveTo(CGPointMake(end_x, end_y), duration: 3 + @random.rand(4))
    remove = SKAction.removeFromParent
    travel = SKAction.sequence [move, remove]

    spin = SKAction.rotateByAngle(3, duration: @random.rand(2) + 1)
    repeat_spin = SKAction.repeatActionForever spin

    actions = SKAction.group [repeat_spin, travel]
    asteroid.runAction actions
  end

  def check_collisions
    ship = childNodeWithName 'ship'
    return unless ship

    enumerateChildNodesWithName('powerup', usingBlock: lambda do |powerup, stop|
      if ship.intersectsNode powerup
        powerup.removeFromParent
        @ship_fire_rate = 0.1

        powerdown = SKAction.runBlock(lambda do
          @ship_fire_rate = 0.5
        end)

        wait = SKAction.waitForDuration 5
        wait_and_powerdown = SKAction.sequence [wait, powerdown]

        ship.removeActionForKey 'waitAndPowerdown'
        ship.runAction(wait_and_powerdown, withKey: 'waitAndPowerdown')
      end
    end)
    
    enumerateChildNodesWithName('obstacle', usingBlock: lambda do |obstacle, stop|
      if ship and ship.intersectsNode obstacle
        @ship_touch = nil
        ship.removeFromParent
        obstacle.removeFromParent

        runAction @ship_explode_sound

        end_game
      end

      enumerateChildNodesWithName('photon', usingBlock: lambda do |photon, stop|
        if photon.intersectsNode obstacle
          photon.removeFromParent
          obstacle.removeFromParent

          runAction @obstacle_explode_sound

          hud = childNodeWithName 'hud'
          score = 10 * hud.elapsed_time * (@easy_mode ? 1 : 2)
          hud.add_points score

          stop = true
        end
      end)
    end)
  end

  def end_game
    # menu stuff
    if self.end_game_callback.nil?
      puts 'Forgot to set the end_game_callback'
    else
      @end_game_callback.call
    end

    hud = childNodeWithName 'hud'
    hud.end_game
  end
  
  def build_enemy_ship_movement_path
    path = UIBezierPath.bezierPath
    
    path.moveToPoint CGPointMake 0.5, -0.5
    path.addCurveToPoint CGPointMake(-2.5, -59.5), controlPoint1: CGPointMake(0.5, -0.5), controlPoint2: CGPointMake(4.55, -29.48)
    path.addCurveToPoint CGPointMake(-27.5, -154.5), controlPoint1: CGPointMake(-9.55, -89.52), controlPoint2: CGPointMake(-43.32, -115.43)
    path.addCurveToPoint CGPointMake(30.5, -243.5), controlPoint1: CGPointMake(-11.68, -193.57), controlPoint2: CGPointMake(17.28, -186.95)
    path.addCurveToPoint CGPointMake(-52.5, -379.5), controlPoint1: CGPointMake(43.72, -300.05), controlPoint2: CGPointMake(-47.71, -335.76)
    path.addCurveToPoint CGPointMake(54.5, -449.5), controlPoint1: CGPointMake(-57.29, -423.24), controlPoint2: CGPointMake(-8.14, -482.45)
    path.addCurveToPoint CGPointMake(-5.5, -348.5), controlPoint1: CGPointMake(117.14, -416.55), controlPoint2: CGPointMake(52.25, -308.62)
    path.addCurveToPoint CGPointMake(10.5, -494.5), controlPoint1: CGPointMake(-63.25, -388.38), controlPoint2: CGPointMake(-14.48, -457.43)
    path.addCurveToPoint CGPointMake(0.5, -559.5), controlPoint1: CGPointMake(23.74, -514.16), controlPoint2: CGPointMake(6.93, -537.57)
    path.addCurveToPoint CGPointMake(-2.5, -644.5), controlPoint1: CGPointMake(-5.2, -578.93), controlPoint2: CGPointMake(-2.5, -644.5)

    path.CGPath
  end

  ## Helpers
  def sqrt(x)
    Math.sqrt x
  end

  def pow(x, y)
    (x) ** y
  end

  def atan2(x, y)
    Math.atan2 x, y
  end

  def sin(x)
    Math.sin x
  end

  def cos(x)
    Math.cos x
  end
end