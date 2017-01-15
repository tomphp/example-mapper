module Card.AddButtonView exposing (view)

import Card.Types exposing (CardType(..), CardId, CardState(..))
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


view : CardType -> Html Msg
view =
    addButtonParams
        >> Maybe.map displayButton
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


displayButton : AddButton -> Html Msg
displayButton b =
    button
        [ onClick (CreateCard b.cardType)
        , class ("card " ++ b.cssClass)
        , id b.id
        ]
        [ text b.label ]
