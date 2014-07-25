# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'RubySpaceRun'
  app.identifier = 'org.pretendamazing.RubySpaceRun'
  app.frameworks += ['SpriteKit']

  app.codesign_certificate = 'iPhone Developer: Ross Nelson (73SX5B5SQ5)'
  app.provisioning_profile = 'resources/RSR_Test_Profile.mobileprovision'
end
