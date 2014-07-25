class MenuController < UIViewController
  def viewDidLoad
    super

    view.backgroundColor = UIColor.greenColor

    label = UILabel.alloc.initWithFrame CGRectZero
    label.text = 'Menu!'
    label.sizeToFit
    label.center = [view.frame.size.width / 2, view.frame.size.height / 2]
    label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
    view.addSubview label
  end
end