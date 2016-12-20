module State exposing (init, update, subscriptions)

import Dict
import Json.Decode as Dec
import Json.Encode as Enc
import Types exposing (Model, Msg(..), Card, Rule, CardState(..))
import WebSocket


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { storyCard = { state = Saved, text = "Story" }
    , rules = []
    , questions = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NullMsg ->
            ( model, Cmd.none )

        GetUpdate ->
            ( model, WebSocket.send "ws://localhost:9292" fetchUpdate )

        UpdateModel update ->
            ( updateModel model update, Cmd.none )

        EditStory ->
            ( { model | storyCard = updateCardState Editing model.storyCard }
            , Cmd.none
            )

        SaveStory text ->
            ( { model | storyCard = updateCard Saving text model.storyCard }
            , WebSocket.send "ws://localhost:9292" <| updateStoryCard text
            )


fetchUpdate : String
fetchUpdate =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "fetch_update" ) ]


updateStoryCard : String -> String
updateStoryCard text =
    Enc.encode 0 <|
        Enc.object
            [ ( "type", Enc.string "update_story_card" )
            , ( "text", Enc.string text )
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:9292" UpdateModel


updateCard : CardState -> String -> Card -> Card
updateCard state text card =
    { card | state = state, text = text }


updateCardState : CardState -> Card -> Card
updateCardState cardState card =
    { card | state = cardState }


updateModel : Model -> String -> Model
updateModel model update =
    case (Dec.decodeString modelDecoder update) of
        Ok model ->
            model

        Err msg ->
            { model | storyCard = { text = msg, state = Saved } }


modelDecoder : Dec.Decoder Model
modelDecoder =
    Dec.field "state" <|
        Dec.map3 Model
            (Dec.field "story_card" card)
            (Dec.field "rules" <| Dec.list rule)
            (Dec.field "questions" <| Dec.list card)


rule : Dec.Decoder Rule
rule =
    Dec.map2 Rule
        (Dec.field "rule_card" card)
        (Dec.field "examples" <| Dec.list card)


card : Dec.Decoder Card
card =
    Dec.map2 Card
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
