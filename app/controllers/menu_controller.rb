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
end