module Types
    exposing
        ( Model
        , Msg(..)
        , Flags
        )

import Card.Types exposing (Card, CardId, CardType)
import Dict exposing (Dict)
import Rule.Types exposing (Rule)


type alias Flags =
    { backendUrl : Maybe String }


type alias Model =
    { storyCard : Maybe Card
    , rules : Dict CardId Rule
    , questions : Dict CardId Card
    , error : Maybe String
    , flags : Flags
    }


type Msg
    = Noop
    | UpdateModel String
    | UpdateCardInModel Card
    | SaveCard Card
    | CreateCard CardType
    | SaveNewCard CardType String
