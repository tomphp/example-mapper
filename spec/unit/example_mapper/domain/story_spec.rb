require 'example_mapper/domain/story_card'
require 'example_mapper/domain/story'

module ExampleMapper
  module Domain
    describe Story do
      let(:story_id) { 'the-story-id' }
      let(:story_card) { 'the-story-card' }

      subject { Story.new(id: story_id, story_card: story_card) }

      describe '#story_card' do
        subject { super().story_card }

        it 'returns the story card' do
          expect(subject).to eq story_card
        end
      end

      describe '#id' do
        subject { super().id }

        it 'returns the id' do
          expect(subject).to eq story_id
        end
      end
    end
  end
end
