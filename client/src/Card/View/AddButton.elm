module Card.View.AddButton exposing (view)

import Card.Types exposing (Card, CardType(..), CardState(..), CardMsg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias AddButton =
    { id : String
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
    case card.id.cardType of
        RuleCard ->
            Just
                { id = card.id.uid
                , cssClass = "card--rule"
                , label = "Add Rule"
                , cardType = card.id.cardType
                }

        ExampleCard _ ->
            Just
                { id = card.id.uid
                , cssClass = "card--example"
                , label = "Add Example"
                , cardType = card.id.cardType
                }

        QuestionCard ->
            Just
                { id = card.id.uid
                , cssClass = "card--question"
                , label = "Add Question"
                , cardType = card.id.cardType
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
