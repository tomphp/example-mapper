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


model =
    { lastRequestNo = 5 }


refreshTests : Test
refreshTests =
    describe "refresh"
        [ test "it returns the JSON" <|
            \() ->
                Requests.toJson model refresh
                    |> Expect.equal """{"request_no":5,"type":"fetch_update"}"""
        ]


addQuestonTests : Test
addQuestonTests =
    describe "addQuestion"
        [ test "it returns the JSON" <|
            \() ->
                toJson model (Requests.addQuestion "Is this a question?")
                    |> Expect.equal
                        """{"request_no":5,"type":"add_question","text":"Is this a question?"}"""
        ]
