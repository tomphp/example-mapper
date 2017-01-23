module View exposing (view)

import Card.Types exposing (Card, CardState(..), CardId, CardType(..))
import Card.View as Card
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Rule.View as Rule
import Types exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ p [] [ text <| Maybe.withDefault "" model.error ]
        , model.storyCard
            |> Maybe.map htmlCard
            |> Maybe.withDefault (text "Loading...")
        , rules model
        , questions model
        ]


rules : Model -> Html Msg
rules model =
    div [ class "rules" ] <|
        List.map
            (\rule -> Html.map (UpdateRule rule) (Rule.view rule))
            (Dict.values model.rules |> List.sortBy (.card >> .position))


questions : Model -> Html Msg
questions model =
    div [ class "questions" ]
        [ h2 [ class "questions__title" ] [ text "Questions" ]
        , div [] (questionCards model)
        ]


questionCards : Model -> List (Html Msg)
questionCards model =
    Dict.values model.questions
        |> List.sortBy .position
        |> List.map (divCard "question")


divCard : String -> Card -> Html Msg
divCard className card =
    div [ class className ] [ htmlCard card ]


htmlCard : Card -> Html Msg
htmlCard card =
    card
        |> Card.view
        |> Html.map (UpdateCard card)
