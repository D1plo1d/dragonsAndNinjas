# Load up the libraries
require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

# Leave all the heavy lifting to My Way (sweet glorious automations!)
MyWay.map "app", to: "/", via: self

