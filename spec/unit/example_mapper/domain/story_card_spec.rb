module ExampleMapper
  module Domain
    describe StoryCard do
      describe '#text' do
        it 'returns the text' do
          card = StoryCard.new('The Story')
          expect(card.text).to eq 'The Story'
        end
      end
    end
  end
end
