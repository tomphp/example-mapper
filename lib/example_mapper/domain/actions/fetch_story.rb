require 'example_mapper/domain/story'

module ExampleMapper
  module Domain
    module Actions
      class FetchStory
        def initialize(stories)
          @stories = stories
        end

        def run(id:)
          @stories.with_id(id)
        end
      end
    end
  end
end
