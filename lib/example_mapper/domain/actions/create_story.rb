module ExampleMapper
  module Domain
    module Actions
      class CreateStory
        def initialize(stories)
          @stories = stories
        end

        def run(text:, id:)
          @stories.add(Story.new(id: id, story_card: StoryCard.new(text)))
        end
      end
    end
  end
end
