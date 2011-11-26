require "rubygems"
require "bundler"
require "yaml"
Bundler.require(:default, ENV['RACK_ENV'])

require './lib/my_way.rb'
require './app/app.rb'


map "/" do
	run App
end
