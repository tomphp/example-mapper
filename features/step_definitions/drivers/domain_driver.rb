require 'example_mapper/domain/application'

class DomainDriver
  include ExampleMapper::Domain

  def create_story(text)
    @story_id = SecureRandom.uuid.tap do |id|
      application.create_story(id: id, text: text)
    end
  end

  def story_card
    application.fetch_story(id: @story_id).story_card
  end

  private

  def application
    @application ||= Application.new
  end
end
