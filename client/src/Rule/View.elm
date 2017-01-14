module Rule.View exposing (view)

import AddButton.Types exposing (AddButtonState(..))
import Types exposing (Model, Msg(..))
import Card.View exposing (existingCard, newCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Card.Types exposing (Card, CardState(..), CardId, CardType(..))
import Rule.Types exposing (Rule)
import Dict exposing (Dict)
import AddButton.View as AddButton


view : Model -> Rule -> Html Msg
view model r =
    div [ class "rule" ]
        [ existingCard r.card
        , examples model r (Dict.values r.examples)
        ]


examples : Model -> Rule -> List Card -> Html Msg
examples model rule es =
    div [ class "examples" ]
        ((exampleCards es)
            ++ [ AddButton.view (buttonState model rule) (ExampleCard rule.card.id) ]
        )


exampleCards : List Card -> List (Html Msg)
exampleCards es =
    List.sortBy .position es |> List.map divCard


buttonState : Model -> Rule -> AddButtonState
buttonState model rule =
    Dict.get rule.card.id model.rules
        |> Maybe.map .addExample
        |> Maybe.withDefault Button


divCard : Card -> Html Msg
divCard card =
    div [] [ existingCard card ]
