port module Main exposing (..)

import RequestsTests
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)
import Test exposing (..)


main : TestProgram
main =
    run emit <|
        describe
            "Example Mapper"
            [ RequestsTests.all
            ]


port emit : ( String, Value ) -> Cmd msg
