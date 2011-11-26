class MyWay < Sinatra::Base

  set :root, File.join(File.dirname(__FILE__), '..')

  register Sinatra::AssetPack

  #if settings.environment == :development
    #register Sinatra::Contrib
  #end

  # asset routing
  # ======================================

  assets {
    #lib assets
    serve '/lib/js',     :from => 'lib/js'
    serve '/lib/css',    :from => 'lib/css'
    serve '/lib/images', :from => 'lib/images'
    # app assets
    serve '/js',     :from => 'app/js'
    serve '/css',    :from => 'app/css'
    serve '/images', :from => 'app/images'
    # packaging
    serve '/lib/last-js/',  :from => 'lib/last-js'
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

end
