module View.AddButton exposing (addButton)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types
    exposing
        ( AddButtonState(..)
        , CardId
        , CardState(..)
        , CardType(..)
        , Msg(..)
        )
import View.Card exposing (newCard)


type alias AddButton =
    { id : CardId
    , cssClass : String
    , label : String
    , cardType : CardType
    }


addButton : AddButtonState -> CardType -> Html Msg
addButton state =
    addButtonParams
        >> Maybe.map (displayButton state)
        >> Maybe.withDefault (text "Error")


addButtonParams : CardType -> Maybe AddButton
addButtonParams t =
    case t of
        RuleCard ->
            Just
                { id = "new-rule"
                , cssClass = "card--rule"
                , label = "Add Rule"
                , cardType = t
                }

        ExampleCard ruleId ->
            Just
                { id = "new-example"
                , cssClass = "card--example"
                , label = "Add Example"
                , cardType = t
                }

        QuestionCard ->
            Just
                { id = "new-question"
                , cssClass = "card--question"
                , label = "Add Question"
                , cardType = t
                }

        _ ->
            Nothing


displayButton : AddButtonState -> AddButton -> Html Msg
displayButton state b =
    case state of
        Preparing ->
            newCard
                { id = b.id
                , state = Editing
                , text = ""
                , cardType = b.cardType
                , position = 999999999
                }

        _ ->
            button
                [ onClick (CreateCard b.cardType)
                , class ("card " ++ b.cssClass)
                , id b.id
                ]
                [ text b.label ]
