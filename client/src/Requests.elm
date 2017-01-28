module Requests
    exposing
        ( addRequestNo
        , refresh
        , addQuestion
        , addRule
        , addExample
        , updateCard
        , toJson
        )

import Json.Encode exposing (..)
import Card.Types exposing (Card)
import Types exposing (Request, Model)


toJson : Model -> Request -> String
toJson model =
    addRequestNo model.lastRequestNo
        >> Json.Encode.object
        >> Json.Encode.encode 0


addRequestNo : Int -> Request -> Request
addRequestNo requestNo request =
    ( "request_no", int requestNo ) :: request


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
    , ( "id", string card.id )
    , ( "text", string card.text )
    ]
