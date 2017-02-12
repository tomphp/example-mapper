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
    , position : Int
    , version : Int
    }


type alias CardId =
    { uid : String, cardType : CardType }


type CardType
    = StoryCard
    | RuleCard
    | ExampleCard String
    | QuestionCard


type CardState
    = AddButton
    | Preparing
    | Editing String
    | Locked
    | Saving
    | Saved
    | DeleteRequested


type CardMsg
    = UpdateCardText String
    | StartEditing
    | FinishEditing
    | CancelEditing String
    | StartCreateNew
    | FinishCreateNew
    | CancelCreateNew
    | SetAddButton
    | RequestDelete
    | ConfirmDelete
    | CancelDelete
