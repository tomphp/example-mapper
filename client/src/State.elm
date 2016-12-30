module State exposing (init, update, subscriptions)

import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import List
import Maybe.Extra
import Requests
import StateDecoder exposing (..)
import Types
    exposing
        ( Model
        , Msg(..)
        , Rule
        , CardState(..)
        , AddButtonState(..)
        , CardId
        , Flags
        )
import Task
import WebSocket


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Requests.refresh |> WebSocket.send flags.backendUrl )



-- init : ( Model, Cmd Msg )
-- init =
--     let
--         flags =
--             { backendUrl = "ws://localhost:9000/workspace/8f0d042c-96e9-496b-8d26-2d6c63b14663" }
--     in
--         ( initialModel flags, Requests.refresh |> WebSocket.send flags.backendUrl )


initialModel : Flags -> Model
initialModel flags =
    { cards = Dict.empty
    , storyId = Nothing
    , rules = Dict.empty
    , questions = []
    , error = Nothing
    , flags = flags
    , addRule = Button
    , addQuestion = Button
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        send =
            WebSocket.send model.flags.backendUrl
    in
        case msg of
            Noop ->
                ( model, Cmd.none )

            GetUpdate ->
                ( model, Requests.refresh |> send )

            UpdateModel update ->
                ( updateModel model update, Cmd.none )

            EditStory id ->
                ( updateCardState model id Editing, focusCardInput id )

            SaveStory id text ->
                ( updateCardState model id Saving
                , Requests.updateCard id text |> send
                )

            EditRule id ->
                ( updateCardState model id Editing, focusCardInput id )

            SaveRule id text ->
                ( updateCardState model id Saving
                , Requests.updateCard id text |> send
                )

            EditExample id ->
                ( updateCardState model id Editing, focusCardInput id )

            SaveExample id text ->
                ( updateCardState model id Saving
                , Requests.updateCard id text |> send
                )

            EditQuestion id ->
                ( updateCardState model id Editing, focusCardInput id )

            SaveQuestion id text ->
                ( updateCardState model id Saving
                , Requests.updateCard id text |> send
                )

            AddQuestion ->
                ( { model | addQuestion = Preparing }, focusCardInput "new-question" )

            AddRule ->
                ( { model | addRule = Preparing }, focusCardInput "new-rule" )

            AddExample ruleId ->
                ( updateAddExampleState model ruleId Preparing
                , focusCardInput "new-example"
                )

            SendNewQuestion text ->
                ( { model | addQuestion = Button }, Requests.addQuestion text |> send )

            SendNewRule text ->
                ( { model | addRule = Button }, Requests.addRule text |> send )

            SendNewExample ruleId text ->
                ( updateAddExampleState model ruleId Button
                , Requests.addExample ruleId text |> send
                )


updateAddExampleState : Model -> CardId -> AddButtonState -> Model
updateAddExampleState model ruleId state =
    { model | rules = Dict.update ruleId (Maybe.map (\r -> { r | addExample = state })) model.rules }


focusCardInput : String -> Cmd Msg
focusCardInput id =
    Task.attempt (always Noop) (Dom.focus <| "card-input-" ++ id)


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen model.flags.backendUrl UpdateModel


updateCardState : Model -> CardId -> CardState -> Model
updateCardState model id state =
    { model
        | cards =
            Dict.update
                id
                (Maybe.map (\card -> { card | state = state }))
                model.cards
    }


updateModel : Model -> String -> Model
updateModel model update =
    case (decodeString (modelDecoder model.flags) update) of
        Ok m ->
            { model
                | cards = m.cards
                , storyId = m.storyId
                , rules = m.rules
                , questions = m.questions
            }

        Err msg ->
            { model | error = Just msg }
