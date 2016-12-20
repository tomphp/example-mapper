module State exposing (init, update, subscriptions)

import Dict exposing (Dict)
import Json.Decode as Dec
import Json.Encode as Enc
import Types exposing (Model, Msg(..), Card, Rule, CardState(..), CardId)
import WebSocket


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchUpdate )


initialModel : Model
initialModel =
    { cards = Dict.empty
    , storyCard = ""
    , rules = []
    , questions = []
    , error = Nothing
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetUpdate ->
            ( model, fetchUpdate )

        UpdateModel update ->
            ( updateModel model update, Cmd.none )

        EditCard id ->
            ( updateCardState model id Editing, Cmd.none )

        SaveCard id text ->
            ( updateCardState model id Saving
            , WebSocket.send "ws://localhost:9292" <| sendUpdateCard id text
            )

        AddQuestion ->
            ( model, WebSocket.send "ws://localhost:9292" sendAddQuestion )

        AddRule ->
            ( model, WebSocket.send "ws://localhost:9292" sendAddRule )

        AddExample ruleId ->
            ( model, WebSocket.send "ws://localhost:9292" <| sendAddExample ruleId )


fetchUpdate : Cmd Msg
fetchUpdate =
    WebSocket.send "ws://localhost:9292" <|
        Enc.encode 0 <|
            Enc.object
                [ ( "type", Enc.string "fetch_update" ) ]


sendAddQuestion : String
sendAddQuestion =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "add_question" ) ]


sendAddRule : String
sendAddRule =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "add_rule" ) ]


sendAddExample : Int -> String
sendAddExample ruleId =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "add_example" )
            , ( "rule_id", Enc.int ruleId )
            ]


sendUpdateCard : CardId -> String -> String
sendUpdateCard id text =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "update_card" )
            , ( "id", Enc.string id )
            , ( "text", Enc.string text )
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:9292" UpdateModel


updateCard : CardState -> String -> Card -> Card
updateCard state text card =
    { card | state = state, text = text }


updateCardState : Model -> CardId -> CardState -> Model
updateCardState model id state =
    { model
        | cards = Dict.update id (Maybe.map (\card -> { card | state = state })) model.cards
    }


updateModel : Model -> String -> Model
updateModel model update =
    case (Dec.decodeString modelDecoder update) of
        Ok model ->
            model

        Err msg ->
            { model | error = Just msg }


modelDecoder : Dec.Decoder Model
modelDecoder =
    Dec.field "state" <|
        Dec.map5 Model
            (Dec.field "cards" <| Dec.dict card)
            (Dec.field "story_card" Dec.string)
            (Dec.field "rules" <| Dec.list rule)
            (Dec.field "questions" <| Dec.list Dec.string)
            (Dec.succeed Nothing)


rule : Dec.Decoder Rule
rule =
    Dec.map2 Rule
        (Dec.field "rule_card" Dec.string)
        (Dec.field "examples" <| Dec.list Dec.string)


card : Dec.Decoder Card
card =
    Dec.map3 Card
        (Dec.field "id" Dec.string)
        (Dec.field "state" cardState)
        (Dec.field "text" Dec.string)


cardState : Dec.Decoder CardState
cardState =
    Dec.map stringToCardState Dec.string


stringToCardState : String -> CardState
stringToCardState s =
    case s of
        "editing" ->
            Editing

        "locked" ->
            Locked

        "saving" ->
            Saving

        _ ->
            Saved
