module Rule.Types exposing (Rule, RuleId, RuleMsg(..))

import Card.Types exposing (Card, CardMsg)
import Dict exposing (Dict)


type alias RuleId =
    String


type alias Rule =
    { card : Card
    , examples : Dict String Card
    }


type RuleMsg
    = UpdateCard Card CardMsg
