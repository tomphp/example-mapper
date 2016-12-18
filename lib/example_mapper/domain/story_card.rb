module ExampleMapper
  module Domain
    class StoryCard
      def initialize(text)
        @text = text
      end

      attr_reader :text
    end
  end
end
