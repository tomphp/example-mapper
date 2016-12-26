require File.path(__dir__, '..', '..', '..', 'app', 'app.rb')

require 'capybara/cucumber'

Capybara.app = ExampleMapper::App

class CapybaraDriver
  def create_story(user, text)
    Capybara.using_session(user) do
      visit '/'

      fill_in(story, text)
    end
  end
end
