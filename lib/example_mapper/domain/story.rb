require 'example_mapper/domain/story_card'

module ExampleMapper
  module Domain
    class Story
      def initialize(id:, story_card:)
        @id = id
        @story_card = story_card
      end

      attr_reader :id
      attr_reader :story_card
    end
  end
end
