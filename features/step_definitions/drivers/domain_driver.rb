require 'example_mapper/domain/application'

class DomainDriver
  include ExampleMapper::Domain

  private_class_method :new

  def self.create_story(text)
    story_id = SecureRandom.uuid
    application = Application.new
    application.create_story(id: story_id, text: text)

    new(application, story_id)
  end

  def self.join_story(story_id)
    new(Application.new, story_id)
  end

  attr_reader :story

  def initialize(application, story_id)
    @application = application
    @connection_id = SecureRandom.uuid
    @story = application.join(
      story_id: story_id,
      connection_id: @connection_id,
      event_handler: ->(event) { @story.apply(event) }
    )
  end

  def add_rule(text)
    @application.add_rule(connection_id: @connection_id, text: text)
  end

  def story_card
    @application.fetch_story.story_card
  end
end
