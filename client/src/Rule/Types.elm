module Rule.Types exposing (Rule, RuleId, RuleMsg(..))

import Card.Types exposing (Card, CardId, CardMsg)
import Dict exposing (Dict)


type alias RuleId =
    CardId


type alias Rule =
    { card : Card
    , examples : Dict CardId Card
    }


type RuleMsg
    = UpdateCard Card CardMsg
