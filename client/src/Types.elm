module Types
    exposing
        ( Model
        , Msg(..)
        , CardState(..)
        , AddButtonState(..)
        , Card
        , Rule
        , RuleId
        , CardId
        , CardType(..)
        , Flags
        )

import Dict exposing (Dict)


type CardType
    = StoryCard
    | RuleCard
    | ExampleCard RuleId
    | QuestionCard


type CardState
    = Editing
    | Locked
    | Saving
    | Saved


type AddButtonState
    = Button
    | Preparing
    | Sending


type alias Flags =
    { backendUrl : Maybe String }


type alias CardId =
    String


type alias RuleId =
    CardId


type alias Card =
    { id : CardId
    , state : CardState
    , text : String
    , cardType : CardType
    , position : Int
    }


type alias Rule =
    { card : Card
    , examples : Dict CardId Card
    , addExample : AddButtonState
    }


type alias Model =
    { storyCard : Maybe Card
    , rules : Dict CardId Rule
    , questions : Dict CardId Card
    , error : Maybe String
    , flags : Flags
    , addRule : AddButtonState
    , addQuestion : AddButtonState
    }


type Msg
    = Noop
    | UpdateModel String
    | UpdateCardInModel Card
    | SaveCard Card
    | CreateCard CardType
    | SaveNewCard CardType String
