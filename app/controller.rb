require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/reloader'
require "yaml"
require "haml"
require 'coffee-script' #also requires therubyracer gem!


# config
# ======================================

class App < Sinatra::Base

  set :root, File.join(File.dirname(__FILE__), '..')
  set :environment => :test
  register Sinatra::AssetPack
  register Sinatra::Reloader


  # model
  # ======================================
  # A) it's not a very good model and
  # B) it's in the wrong file, what part of *this is a prototype* don't you understand?

  File.open( 'config/commands.yml' ) { |yf| $commands = YAML::load( yf ) }

  $commands.each do |cmd_set|
    cmd_set[1].each do |section|
      section[1].each do |cmd|
        #cmd[1]['css_name'] = cmd[0].gsub(' ', '_').downcase
        section[1][cmd[0]] = { :css_name => cmd[0].gsub(/[ \\\/]/, '_').downcase }
      end
    end
  end

  def css_name(name)
    return name.gsub(/[ \\\/]/, '-').downcase
  end

  # a little command info on startup
  $commands.each do |cmd_set|
    cmd_set[1].each do |section|
      puts section[0]
      puts '-----------------------'
      puts section[1]
      puts '================================================'
    end
  end


  # asset routing
  # ======================================

  assets {
    #lib assets
    serve '/lib/js',     from: 'lib/js'
    serve '/lib/css',    from: 'lib/css'
    serve '/lib/images', from: 'lib/images'
    # app assets
    serve '/js',     from: 'app/js'
    serve '/css',    from: 'app/css'
    serve '/images', from: 'app/images'
    # packaging
    serve '/lib/last-js/',  from: 'lib/last-js'
    js :all, [
      '/lib/js/jquery-1.*.js',
      '/lib/js/jquery-ui-*.js',
      '/lib/js/**.js',
      '/js/**.js',
      '/lib/last-js/**.js']
    css :all, ['/lib/css/**.css', '/css/**.css']
  }


  # view routing
  # ======================================

  set :views, Proc.new { File.join(root, "app/views") }
  get '/' do
    puts "moo2"
    haml :index, :format => :html5
  end

end
