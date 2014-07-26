class MenuController < UIViewController
  extend IB

  outlet :difficulty_chooser, UISegmentedControl
  outlet :high_score_label, UILabel

  def viewWillAppear(animated)
    super animated

    NSUserDefaults[:high_score] = 0 if not NSUserDefaults[:high_score]
    score = NSUserDefaults[:high_score]
    score_text = "High Score: #{score.to_i.to_s}"
    @high_score_label.text = score_text
  end
end