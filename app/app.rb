require 'compass'
require 'sinatra/base'
require 'tilt/erb'

module ExampleMapper
  class App < Sinatra::Base
    set :public_folder, 'app/assets'
    set :scss, Compass.sass_engine_options

    Compass.configuration do |config|
      config.project_path = __dir__
      config.sass_dir = 'views'
    end

    get "/styles.css" do
      scss :style
    end

    get '/' do
      erb :'index.html'
    end

    post '/' do
      redirect '/workspace'
    end

    get "/workspace" do
      erb :"workspace.html"
    end
  end
end
