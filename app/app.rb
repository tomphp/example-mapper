require 'sinatra/base'
require 'tilt/erb'

module ExampleMapper
  class App < Sinatra::Base
    set :public_folder, 'client'

    get "/" do
      erb :"index.html"
    end
  end
end
