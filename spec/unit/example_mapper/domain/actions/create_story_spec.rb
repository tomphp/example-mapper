require 'example_mapper/domain/actions/create_story'
require 'example_mapper/domain/story'

module ExampleMapper
  module Domain
    module Actions
      describe CreateStory do
        let(:stories) { spy(:stories) }

        subject { CreateStory.new(stories) }

        it 'stores a new story' do
          subject.run(id: 'example-story-id', text: 'Example Story')

          expect(stories)
            .to have_received(:add)
            .with(lambda do |story|
              expect(story.id).to eq 'example-story-id'
              expect(story.story_card.text).to eq 'Example Story'
            end)
        end
      end
    end
  end
end
