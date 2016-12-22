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

    def client
        config = %r(mysql://(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^/]+)/(?<db>[^?]+)\?reconnect=true)
                 .match(ENV['CLEARDB_DATABASE_URL'])

        @client ||= Mysql2::Client.new(
          host: config['host'],
          username: config['user'],
          password: config['pass'],
          database: config['db'],
          reconnect: true
        )
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
      text = client.escape(params[:story])

      client.query("INSERT INTO cards (card_id,story_id,text,state) VALUES('#{card_id}', '#{story_id}', '#{text}', 'saved')")
      client.query("INSERT INTO stories (story_id,story_card) VALUES('#{story_id}', '#{card_id}')")

      redirect "/workspace/#{story_id}"
    end

    get "/workspace/:id" do
      @url = request.url
      @story_id = client.escape(params[:id])

      result = client.query("SELECT * FROM stories WHERE story_id='#{@story_id}'")

      if result.count == 0
        status 404
        'Not found!'
      else
        erb :"workspace.html"
      end
    end
  end
end
