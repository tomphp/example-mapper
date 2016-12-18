require 'example_mapper/domain/actions/create_story'
require 'example_mapper/domain/actions/fetch_story'
require 'example_mapper/infrastructure/memory_story_repository'

module ExampleMapper
  module Domain
    class Application
      def create_story(id:, text:)
        Actions::CreateStory.new(stories).run(id: id, text: text)
      end

      def fetch_story(id:)
        Actions::FetchStory.new(stories).run(id: id)
      end

      private

      def stories
        @stories ||= Infrastructure::MemoryStoryRepository.new
      end
    end
  end
end
