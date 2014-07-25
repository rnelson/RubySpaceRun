class Extensions < SKEmitterNode

  def self.node_with_file(file_name)
    extension = File.extname file_name
    base_name = File.basename(file_name, extension)
    path = NSBundle.mainBundle.pathForResource(base_name, ofType: extension)
    thrust = NSKeyedUnarchiver.unarchiveObjectWithFile path
    thrust
  end
end