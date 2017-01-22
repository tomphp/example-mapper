module Requests
    exposing
        ( Request
        , refresh
        , addQuestion
        , addRule
        , addExample
        , updateCard
        )

import Json.Encode exposing (..)
import Card.Types exposing (Card)


type alias Request =
    List ( String, Value )


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
