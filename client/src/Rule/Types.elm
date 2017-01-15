module Rule.Types exposing (Rule, RuleId)

import Card.Types exposing (Card, CardId)
import Dict exposing (Dict)


type alias RuleId =
    CardId


type alias Rule =
    { card : Card
    , examples : Dict CardId Card
    }
