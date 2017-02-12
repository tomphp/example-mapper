module Requests
    exposing
        ( refresh
        , addQuestion
        , addRule
        , addExample
        , updateCard
        , deleteCard
        , toJson
        )

import Json.Encode exposing (..)
import Card.Types exposing (Card, CardType(..))
import Types exposing (Request, Model)


toJson : { a | lastRequestNo : Int } -> Request -> String
toJson model =
    addRequestNo model.lastRequestNo
        >> Json.Encode.object
        >> Json.Encode.encode 0


refresh : Request
refresh =
    [ ( "type", string "fetch_update" ) ]


addQuestion : String -> Request
addQuestion text =
    [ ( "type", string "add_question" )
    , ( "text", string text )
    ]


addRule : String -> Request
addRule text =
    [ ( "type", string "add_rule" )
    , ( "text", string text )
    ]


addExample : String -> String -> Request
addExample ruleId text =
    [ ( "type", string "add_example" )
    , ( "rule_id", string ruleId )
    , ( "text", string text )
    ]


updateCard : Card -> Request
updateCard card =
    [ ( "type", string "update_card" )
    , ( "id", string card.id.uid )
    , ( "text", string card.text )
    ]


deleteCard : Card -> Request
deleteCard card =
    let
        messageType =
            case card.id.cardType of
                RuleCard ->
                    "delete_rule"

                ExampleCard _ ->
                    "delete_example"

                QuestionCard ->
                    "delete_question"

                StoryCard ->
                    "noop"
    in
        [ ( "type", string messageType )
        , ( "id", string card.id.uid )
        ]


addRequestNo : Int -> Request -> Request
addRequestNo requestNo request =
    ( "request_no", int requestNo ) :: request
