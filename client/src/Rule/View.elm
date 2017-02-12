module Rule.View exposing (view)

import Card.Types exposing (Card)
import Card.View
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Rule.Types exposing (Rule, RuleMsg(..))


view : Rule -> Html RuleMsg
view r =
    div [ id ("rule-" ++ r.card.id.uid), class "rule" ]
        [ Card.View.view r.card |> Html.map (UpdateCard r.card)
        , examples r
        ]


examples : Rule -> Html RuleMsg
examples =
    .examples
        >> Dict.values
        >> exampleCards
        >> div [ class "examples" ]


exampleCards : List Card -> List (Html RuleMsg)
exampleCards =
    List.sortBy .position >> List.map divCard


divCard : Card -> Html RuleMsg
divCard card =
    div [ class "example" ] [ htmlCard card ]


htmlCard : Card -> Html RuleMsg
htmlCard card =
    Card.View.view card |> Html.map (UpdateCard card)
