module Types
    exposing
        ( Model
        , Msg(..)
        , CardState(..)
        , AddButtonState(..)
        , Card
        , Rule
        , CardId
        , Flags
        )

import Dict exposing (Dict)


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
    { backendUrl : String }


type alias CardId =
    String


type alias Card =
    { id : CardId
    , state : CardState
    , text : String
    }


type alias Rule =
    { ruleCard : CardId
    , examples : List CardId
    , addExample : AddButtonState
    }


type alias Model =
    { cards : Dict CardId Card
    , storyCard : CardId
    , rules : Dict CardId Rule
    , questions : List CardId
    , error : Maybe String
    , flags : Flags
    , addRule : AddButtonState
    , addQuestion : AddButtonState
    }


type Msg
    = GetUpdate
    | Noop
    | UpdateModel String
    | EditCard String
    | SaveCard CardId String
    | AddQuestion
    | AddRule
    | AddExample String
    | SendNewQuestion String
    | SendNewRule String
    | SendNewExample String String
