module Card.Types
    exposing
        ( CardType(..)
        , CardState(..)
        , CardMsg(..)
        , CardId
        , Card
        )


type alias Card =
    { id : CardId
    , state : CardState
    , text : String
    , cardType : CardType
    , position : Int
    , version : Int
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
    | Preparing
    | Editing String
    | Locked
    | Saving
    | Saved


type CardMsg
    = UpdateCardText String
    | StartEditing
    | FinishEditing
    | CancelEditing String
    | StartCreateNew
    | FinishCreateNew
    | CancelCreateNew
    | SetAddButton
