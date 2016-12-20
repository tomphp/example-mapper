module Types exposing (Model, Msg(..), CardState(..), Card, Rule)

import Dict exposing (Dict)


type CardState
    = Editing
    | Locked
    | Saving
    | Saved


type alias Card =
    { state : CardState
    , text : String
    }


type alias Rule =
    { ruleCard : Card
    , examples : List Card
    }


type alias Model =
    { storyCard : Card
    , rules : List Rule
    , questions : List Card
    }


type Msg
    = NullMsg
    | GetUpdate
    | UpdateModel String
    | EditStory
    | SaveStory String
