module Types
    exposing
        ( Model
        , ModelUpdater
        , Msg(..)
        , Flags
        , Request
        , DelayedAction(..)
        )

import Card.Types exposing (Card, CardType, CardMsg)
import Dict exposing (Dict)
import Rule.Types exposing (Rule, RuleMsg)
import Json.Encode exposing (Value)


type alias ModelUpdater =
    Model -> Model


type alias Request =
    List ( String, Value )


type alias Flags =
    { backendUrl : Maybe String }


type DelayedAction
    = ResetAddButton Card


type alias Model =
    { clientId : Maybe String
    , lastRequestNo : Int
    , storyCard : Maybe Card
    , rules : Dict String Rule
    , questions : Dict String Card
    , error : Maybe String
    , flags : Flags
    , delayed : Dict Int DelayedAction
    }


type Msg
    = Noop
    | SendRequest Request
    | UpdateModel String
    | UpdateCard Card CardMsg
    | UpdateRule Rule RuleMsg
