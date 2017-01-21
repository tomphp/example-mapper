module Card.View.AddButton exposing (view)

import Card.Types exposing (Card, CardType(..), CardId, CardState(..), CardMsg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias AddButton =
    { id : CardId
    , cssClass : String
    , label : String
    , cardType : CardType
    }


view : Card -> Html CardMsg
view =
    addButtonParams
        >> Maybe.map displayButton
        >> Maybe.withDefault (text "Error")


addButtonParams : Card -> Maybe AddButton
addButtonParams card =
    case card.cardType of
        RuleCard ->
            Just
                { id = card.id
                , cssClass = "card--rule"
                , label = "Add Rule"
                , cardType = card.cardType
                }

        ExampleCard ruleId ->
            Just
                { id = card.id
                , cssClass = "card--example"
                , label = "Add Example"
                , cardType = card.cardType
                }

        QuestionCard ->
            Just
                { id = card.id
                , cssClass = "card--question"
                , label = "Add Question"
                , cardType = card.cardType
                }

        _ ->
            Nothing


displayButton : AddButton -> Html CardMsg
displayButton b =
    button
        [ onClick StartCreateNew
        , class ("card " ++ b.cssClass)
        , id b.id
        ]
        [ text b.label ]
