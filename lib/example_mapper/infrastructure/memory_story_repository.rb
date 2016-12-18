require 'example_mapper/domain/errors/story_not_found'

module ExampleMapper
  module Infrastructure
    class MemoryStoryRepository
      include ExampleMapper::Domain::Errors

      def initialize
        @story = {}
      end

      def add(story)
        @story[story.id] = story
      end

      def with_id(id)
        raise StoryNotFound, id unless @story.key? id

        @story.fetch(id)
      end
    end
  end
end
