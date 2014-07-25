class StarField < SKNode
  def init
    super

    @random = Random.new
    @weak = WeakRef.new self

    update = SKAction.runBlock(lambda do
      if @random.rand(10) < 3
        launch_star
      end
    end)
    delay = SKAction.waitForDuration 0.01
    loop = SKAction.sequence [delay, update]
    runAction SKAction.repeatActionForever loop
  end

  def launch_star
    rand_x = @random.rand(scene.size.width)
    max_y = scene.size.height
    random_start = CGPointMake rand_x, max_y

    star = SKSpriteNode.spriteNodeWithImageNamed 'shootingstar'
    star.position = random_start
    star.size = CGSizeMake 2, 10
    star.alpha = 0.1 + (@random.rand(10) / 10.0)
    addChild star

    dest_y = 0 - scene.size.height - star.size.height
    duration = 0.1 + (@random.rand(10) / 10.0)
    move = SKAction.moveByX(0, y: dest_y, duration: duration)
    remove = SKAction.removeFromParent
    star.runAction SKAction.sequence [move, remove]
  end
end