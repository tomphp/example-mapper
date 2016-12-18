require 'example_mapper/domain/story'
require 'example_mapper/infrastructure/memory_story_repository'

module ExampleMapper
  module Infrastructure
    include ExampleMapper::Domain::Errors

    describe MemoryStoryRepository do
      subject { MemoryStoryRepository.new }

      describe '#with_id' do
        it 'returns the story with the id' do
          story1 = Domain::Story.new(id: 'example-id-1', story_card: nil)
          story2 = Domain::Story.new(id: 'example-id-2', story_card: nil)

          subject.add(story1)
          subject.add(story2)

          expect(subject.with_id('example-id-1')).to eq story1
        end

        it 'raises if no story is found' do
          expect { subject.with_id('some-id') }
            .to raise_error StoryNotFound, 'some-id'
        end
      end
    end
  end
end
