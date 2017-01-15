module Rule.View exposing (view)

import Types exposing (Model, Msg(..))
import Card.View
import Html exposing (..)
import Html.Attributes exposing (..)
import Card.Types exposing (Card, CardState(..), CardId, CardType(..))
import Rule.Types exposing (Rule)
import Dict exposing (Dict)


view : Model -> Rule -> Html Msg
view model r =
    div [ id ("rule-" ++ r.card.id), class "rule" ]
        [ Card.View.view r.card
        , examples model r (Dict.values r.examples)
        ]


examples : Model -> Rule -> List Card -> Html Msg
examples model rule es =
    div [ class "examples" ] (exampleCards es)


exampleCards : List Card -> List (Html Msg)
exampleCards es =
    List.sortBy .position es |> List.map divCard


divCard : Card -> Html Msg
divCard card =
    div [ class "example" ] [ Card.View.view card ]
