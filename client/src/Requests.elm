module Requests
    exposing
        ( refresh
        , addQuestion
        , addRule
        , addExample
        , updateCard
        )

import Json.Encode exposing (..)
import Types exposing (Card)


refresh : String
refresh =
    encodeObject [ ( "type", string "fetch_update" ) ]


addQuestion : String -> String
addQuestion text =
    encodeObject
        [ ( "type", string "add_question" )
        , ( "text", string text )
        ]


addRule : String -> String
addRule text =
    encodeObject
        [ ( "type", string "add_rule" )
        , ( "text", string text )
        ]


addExample : String -> String -> String
addExample ruleId text =
    encodeObject
        [ ( "type", string "add_example" )
        , ( "rule_id", string ruleId )
        , ( "text", string text )
        ]


updateCard : Card -> String
updateCard card =
    encodeObject
        [ ( "type", string "update_card" )
        , ( "id", string card.id )
        , ( "text", string card.text )
        ]


encodeObject : List ( String, Value ) -> String
encodeObject =
    object >> encode 0
