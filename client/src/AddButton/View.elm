module AddButton.View exposing (view)

import AddButton.Types exposing (AddButtonState(..))
import Card.Types exposing (CardType(..), CardId, CardState(..))
import Card.View exposing (newCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (Msg(..))


type alias AddButton =
    { id : CardId
    , cssClass : String
    , label : String
    , cardType : CardType
    }


view : AddButtonState -> CardType -> Html Msg
view state =
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
