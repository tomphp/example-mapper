module View exposing (view)

import Dict exposing (Dict)
import Types
    exposing
        ( Model
        , Msg(..)
        , Card
        , Rule
        , CardState(..)
        , CardId
        , AddButtonState(..)
        , CardType(..)
        )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import View.AddButton exposing (addButton)
import View.Card exposing (existingCard, newCard)


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ p [] [ text <| Maybe.withDefault "" model.error ]
        , model.storyCard
            |> Maybe.map existingCard
            |> Maybe.withDefault (text "Error")
        , rules model
        , questions model
        ]


rules : Model -> Html Msg
rules model =
    div [ class "rules" ] <|
        List.append
            (List.map (rule model) (Dict.values model.rules |> List.sortBy .position))
            [ div [] [ addButton model.addRule RuleCard ]
            , div [] [ div [ class "rule-padding" ] [] ]
            ]


questions : Model -> Html Msg
questions model =
    div [ class "questions" ]
        (List.concat
            [ [ h2 [] [ text "Questions" ] ]
            , Dict.values model.questions |> List.map divCard
            , [ addButton model.addQuestion QuestionCard ]
            ]
        )


rule : Model -> Rule -> Html Msg
rule model r =
    div [ class "rule" ]
        [ existingCard r.card
        , examples model r (Dict.values r.examples)
        ]


examples : Model -> Rule -> List Card -> Html Msg
examples model rule es =
    div [ class "examples" ]
        (List.append
            (List.map divCard es)
            [ addButton
                (Dict.get rule.card.id model.rules
                    |> Maybe.map .addExample
                    |> Maybe.withDefault Button
                )
                (ExampleCard rule.card.id)
            ]
        )


divCard : Card -> Html Msg
divCard card =
    div [] [ existingCard card ]
