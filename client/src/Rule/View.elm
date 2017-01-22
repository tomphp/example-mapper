module Rule.View exposing (view)

import Card.Types exposing (Card, CardState(..), CardId, CardType(..))
import Card.View
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Rule.Types exposing (Rule)
import Types exposing (Model, Msg(..))


view : Model -> Rule -> Html Msg
view model r =
    div [ id ("rule-" ++ r.card.id), class "rule" ]
        [ Card.View.view r.card |> Html.map (UpdateCard r.card)
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
    div [ class "example" ] [ htmlCard card ]


htmlCard : Card -> Html Msg
htmlCard card =
    card
        |> Card.View.view
        |> Html.map (UpdateCard card)
