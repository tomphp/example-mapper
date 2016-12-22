module State exposing (init, update, subscriptions)

import Dict exposing (Dict)
import Dom
import Json.Decode as Dec
import Json.Encode as Enc
import Types exposing (Model, Msg(..), Card, Rule, CardState(..), CardId, Flags)
import Task
import WebSocket


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, fetchUpdate flags )


initialModel : Flags -> Model
initialModel flags =
    { cards = Dict.empty
    , storyCard = ""
    , rules = []
    , questions = []
    , error = Nothing
    , flags = flags
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        GetUpdate ->
            ( model, fetchUpdate model.flags )

        UpdateModel update ->
            ( updateModel model update, Cmd.none )

        EditCard id ->
            ( updateCardState model id Editing
            , Task.attempt (always Noop) (Dom.focus <| "card-input-" ++ id)
            )

        SaveCard id text ->
            ( updateCardState model id Saving
            , WebSocket.send model.flags.backendUrl <| sendUpdateCard model.flags id text
            )

        AddQuestion ->
            ( model, WebSocket.send model.flags.backendUrl <| sendAddQuestion model.flags )

        AddRule ->
            ( model, WebSocket.send model.flags.backendUrl <| sendAddRule model.flags )

        AddExample ruleId ->
            ( model, WebSocket.send model.flags.backendUrl <| sendAddExample model.flags ruleId )


fetchUpdate : Flags -> Cmd Msg
fetchUpdate flags =
    WebSocket.send flags.backendUrl <|
        Enc.encode 0 <|
            Enc.object
                [ ( "type", Enc.string "fetch_update" )
                , ( "story_id", Enc.string flags.storyId )
                ]


sendAddQuestion : Flags -> String
sendAddQuestion flags =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "add_question" )
            , ( "story_id", Enc.string flags.storyId )
            ]


sendAddRule : Flags -> String
sendAddRule flags =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "add_rule" )
            , ( "story_id", Enc.string flags.storyId )
            ]


sendAddExample : Flags -> String -> String
sendAddExample flags ruleId =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "add_example" )
            , ( "story_id", Enc.string flags.storyId )
            , ( "rule_id", Enc.string ruleId )
            ]


sendUpdateCard : Flags -> CardId -> String -> String
sendUpdateCard flags id text =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "update_card" )
            , ( "story_id", Enc.string flags.storyId )
            , ( "id", Enc.string id )
            , ( "text", Enc.string text )
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen model.flags.backendUrl UpdateModel


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
    case (Dec.decodeString (modelDecoder model.flags) update) of
        Ok m ->
            m

        Err msg ->
            { model | error = Just msg }


modelDecoder : Flags -> Dec.Decoder Model
modelDecoder flags =
    Dec.field "state" <|
        Dec.map6 Model
            (Dec.field "cards" <| Dec.dict card)
            (Dec.field "story_card" Dec.string)
            (Dec.field "rules" <| Dec.list rule)
            (Dec.field "questions" <| Dec.list Dec.string)
            (Dec.succeed Nothing)
            (Dec.succeed flags)


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
