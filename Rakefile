# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'Space Run'
  app.identifier = 'org.pretendamazing.RubySpaceRun'
  app.icons = ['Icon@2x.png', 'Icon.png']

  # external frameworks and projects
  app.frameworks += ['SpriteKit']
  app.vendor_project('vendor/SKEmitterNodeExtensions', :static)

  # deployment
  app.codesign_certificate = 'iPhone Developer: Ross Nelson (73SX5B5SQ5)'
  app.provisioning_profile = 'resources/RSR_Test_Profile.mobileprovision'
end
