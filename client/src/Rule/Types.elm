module Rule.Types exposing (Rule, RuleId)

import Card.Types exposing (Card, CardId)
import Dict exposing (Dict)
import AddButton.Types exposing (AddButtonState)


type alias RuleId =
    CardId


type alias Rule =
    { card : Card
    , examples : Dict CardId Card
    , addExample : AddButtonState
    }
