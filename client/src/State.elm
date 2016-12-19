module State exposing (init, update, subscriptions)

import Dict
import Json.Decode as Json
import Types exposing (Model, Msg(..), Card, Rule, CardState(..))
import WebSocket


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { storyCard = { state = Saved, text = "Story" }
    , rules =
        [ { ruleCard = { state = Saved, text = "Some Rule" }
          , examples = []
          }
        ]
    , questions = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NullMsg ->
            ( model, Cmd.none )

        GetUpdate ->
            ( model, WebSocket.send "ws://localhost:9292" "fetch update" )

        UpdateModel update ->
            ( updateModel model update, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:9292" UpdateModel


updateModel : Model -> String -> Model
updateModel model update =
    case (Json.decodeString modelDecoder update) of
        Ok model ->
            model

        Err msg ->
            { model | storyCard = { text = msg, state = Saved } }


modelDecoder : Json.Decoder Model
modelDecoder =
    Json.field "state" <|
        Json.map3 Model
            (Json.field "story_card" card)
            (Json.field "rules" <| Json.list rule)
            (Json.field "questions" <| Json.list card)


rule : Json.Decoder Rule
rule =
    Json.map2 Rule
        (Json.field "rule_card" card)
        (Json.field "examples" <| Json.list card)


card : Json.Decoder Card
card =
    Json.map2 Card
        (Json.field "state" cardState)
        (Json.field "text" Json.string)


cardState : Json.Decoder CardState
cardState =
    Json.map stringToCardState Json.string


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
