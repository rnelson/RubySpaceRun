class OpeningScene < SKScene
  attr_accessor :scene_end_callback
  attr_accessor :slanted_view
  attr_accessor :text_view

  def didMoveToView(view)
    #I can't access the C macro M_PI so I'm using this for now...
    my_pi = 3.14159265358979323846264338327950288

    star_field = StarField.node
    addChild star_field

    #create the superview that will do the perspective tilt
    @slanted_view = UIView.alloc.initWithFrame view.bounds
    @slanted_view.opaque = false
    @slanted_view.backgroundColor = UIColor.clearColor
    view.addSubview @slanted_view

    #tilt the superview
    transform = CATransform3DIdentity
    transform.m34 = -1.0 / 500.0
    transform = CATransform3DRotate(transform, 45.0 * my_pi / 180.0, 1.0, 0.0, 0.0)
    @slanted_view.layer.setTransform transform

    # use a textview to display our backstory
    @text_view = UITextView.alloc.initWithFrame CGRectInset(view.bounds, 30, 0)
    @text_view.opaque = false
    @text_view.backgroundColor = UIColor.clearColor
    @text_view.textColor = UIColor.yellowColor
    @text_view.font = UIFont.fontWithName('AvenirNext-Medium', size: 20)
    @text_view.text = "A distress call comes in from thousands of light " \
      "years away. The colony is in jeopardy and needs " \
      "your help. Enemy ships and a meteor shower " \
      "threaten the work of the galaxy's greatest " \
      "scientific minds.\n\n " \
      "Will you be able to reach " \
      "them in time to save the research?\n\n " \
      "Or has the galaxy lost it's only hope?"
    @text_view.userInteractionEnabled = false
    @text_view.center = CGPointMake(size.width / 2 + 15, size.height + (size.height / 2))
    @slanted_view.addSubview @text_view

    #add a fading mask so it vanishes out of sight
    gradient = CAGradientLayer.layer
    gradient.frame = view.bounds
    gradient.colors = [UIColor.clearColor.CGColor, UIColor.whiteColor.CGColor]
    gradient.startPoint = CGPointMake 0.5, 0.0
    gradient.endPoint = CGPointMake 0.5, 0.20
    @slanted_view.layer.setMask gradient

    UIView.animateWithDuration(20, delay: 0,
                               options: UIViewAnimationOptionCurveLinear,
                               animations: lambda do
                                   @text_view.center = CGPointMake(size.width / 2, 0 - (size.height / 2))
                               end,
                               completion: lambda do |finished|
                                 if @scene_end_callback.nil?
                                   puts 'Scene end callback not set'
                                 else
                                   @scene_end_callback.call
                                   end
                               end)
  end

  def willMoveFromView(view)
    @slanted_view.removeFromSuperview
    @slanted_view = nil
    @text_view = nil
  end
end