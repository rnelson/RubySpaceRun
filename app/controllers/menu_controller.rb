class MenuController < UIViewController
  extend IB

  ib_outlet :difficulty_chooser, UISegmentedControl
  ib_outlet :high_score_label, UILabel
end