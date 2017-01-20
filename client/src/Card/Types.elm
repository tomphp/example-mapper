module Card.Types exposing (CardType(..), CardState(..), CardId, Card)


type alias Card =
    { id : CardId
    , state : CardState
    , text : String
    , cardType : CardType
    , position : Int
    }


type alias CardId =
    String


type CardType
    = StoryCard
    | RuleCard
    | ExampleCard CardId
    | QuestionCard


type CardState
    = AddButton
    | Preparing String
    | Editing String
    | Locked
    | Saving
    | Saved
