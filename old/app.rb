require 'sinatra'
require "yaml"
require 'coffee-script' #also requires therubyracer gem!

# Settings
# =============================

$folder = File.expand_path(__FILE__).to_s

if $folder.include? 'dev' then
  set :environment => :test
else
#  set :environment => :production
end

File.open( 'commands.yml' ) { |yf| $commands = YAML::load( yf ) }

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

$commands.each do |cmd_set|
  cmd_set[1].each do |section|
    puts section[0]
    puts '-----------------------'
    puts section[1]
    puts '================================================'
  end
end

enable :sessions
#set :public, File.dirname(__FILE__)

=begin use Rack::PageSpeed do
  store :memcached #:disk => Dir.tmpdir # require 'tmpdir'

  inline_javascript :max_size => 4000
  combine_javascripts
  minify_javascripts

  inline_css
  combine_css

  inline_images :max_size => 50000
end
=end

# Loading the app's configuration

# URL Mapping
# =============================

get '/' do
  haml :index
end

$coffee_scripts = ['controller', 'view', 'model', 'app']

get '/js/:script' do
  script = params[:script][0..-4]
  puts script
  pass unless $coffee_scripts.include? script
  coffee ('js/'+script).to_sym
end

get '/js/model.js' do
  coffee :'js/model'
end
