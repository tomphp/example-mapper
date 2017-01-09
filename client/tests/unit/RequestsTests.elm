module RequestsTests exposing (all)

import Test exposing (..)
import Expect
import Requests exposing (..)


all : Test
all =
    describe "Requests"
        [ refreshTests
        , addQuestonTests
        ]


refreshTests : Test
refreshTests =
    describe "refresh"
        [ test "it returns the JSON" <|
            \() ->
                Expect.equal
                    refresh
                    """{"type":"fetch_update"}"""
        ]


addQuestonTests : Test
addQuestonTests =
    describe "addQuestion"
        [ test "it returns the JSON" <|
            \() ->
                Expect.equal
                    (addQuestion "Is this a question?")
                    """{"type":"add_question","text":"Is this a question?"}"""
        ]
