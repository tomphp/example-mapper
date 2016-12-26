require 'compass'
require 'mysql2'
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

    helpers do
      def storage
        env[:storage]
      end
    end

    get "/styles.css" do
      scss :style
    end

    get '/' do
      erb :'index.html'
    end

    post '/' do
      story_id = SecureRandom.uuid
      card_id = SecureRandom.uuid
      text = params[:story]

      storage.add_card(card_id, story_id, text, 'saved')
      storage.add_story(story_id, card_id)

      redirect "/workspace/#{story_id}"
    end

    get "/workspace/:id" do
      @url = request.url
      @story_id = params[:id]

      result = storage.fetch_story(@story_id)

      if result.count == 0
        status 404
        'Not found!'
      else
        erb :"workspace.html"
      end
    end
  end
end
