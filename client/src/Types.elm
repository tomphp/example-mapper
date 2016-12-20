module Types exposing (Model, Msg(..), CardState(..), Card, Rule, CardId)

import Dict exposing (Dict)


type CardState
    = Editing
    | Locked
    | Saving
    | Saved


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
    }


type alias Model =
    { cards : Dict CardId Card
    , storyCard : CardId
    , rules : List Rule
    , questions : List CardId
    , error : Maybe String
    }


type Msg
    = GetUpdate
    | UpdateModel String
    | EditCard String
    | SaveCard CardId String
    | AddQuestion
    | AddRule
    | AddExample Int
