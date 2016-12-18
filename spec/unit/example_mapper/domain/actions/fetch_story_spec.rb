require 'example_mapper/domain/actions/fetch_story'
require 'example_mapper/domain/story'

module ExampleMapper
  module Domain
    module Actions
      describe FetchStory do
        let(:stories) { spy(:stories) }

        subject { FetchStory.new(stories) }

        it 'fetches the story by id from the repository' do
          subject.run(id: 'abc123')

          expect(stories).to have_received(:with_id).with('abc123')
        end

        it 'returns the loaded story' do
          allow(stories).to receive(:with_id).and_return('loaded-story')

          expect(subject.run(id: '123abc')).to eq 'loaded-story'
        end
      end
    end
  end
end
