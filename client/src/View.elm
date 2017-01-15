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
            |> Maybe.map Card.view
            |> Maybe.withDefault (text "Error")
        , rules model
        , questions model
        ]


rules : Model -> Html Msg
rules model =
    div [ class "rules" ] <|
        List.map (Rule.view model) (Dict.values model.rules |> List.sortBy (.card >> .position))


questions : Model -> Html Msg
questions model =
    div [ class "questions" ]
        (List.concat
            [ [ h2 [] [ text "Questions" ] ]
            , Dict.values model.questions |> List.sortBy .position |> List.map divCard
            ]
        )


divCard : Card -> Html Msg
divCard card =
    div [] [ Card.view card ]
