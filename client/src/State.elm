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
        , Card
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
    { storyCard = Nothing
    , rules = Dict.empty
    , questions = Dict.empty
    , error = Nothing
    , flags = flags
    , addRule = Button
    , addQuestion = Button
    }


newCardState : CardState -> Card -> Card
newCardState state card =
    { card | state = state }


updateRuleCard : (Card -> Card) -> Rule -> Rule
updateRuleCard update rule =
    { rule | card = update rule.card }


updateQuestionCard : (Card -> Card) -> CardId -> Model -> Model
updateQuestionCard update id model =
    { model | questions = Dict.update id (Maybe.map update) model.questions }


updateStoryCard : (Card -> Card) -> Model -> Model
updateStoryCard update model =
    { model | storyCard = Maybe.map update model.storyCard }


updateExampleCard : (Card -> Card) -> CardId -> Rule -> Rule
updateExampleCard update id rule =
    { rule | examples = Dict.update id (Maybe.map update) rule.examples }


updateRule : (Rule -> Rule) -> CardId -> Model -> Model
updateRule update ruleId model =
    { model | rules = Dict.update ruleId (Maybe.map update) model.rules }


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
                ( updateStoryCard (newCardState Editing) model
                , focusCardInput id
                )

            SaveStory id text ->
                ( updateStoryCard (newCardState Saving) model
                , Requests.updateCard id text |> send
                )

            EditRule id ->
                ( updateRule (updateRuleCard <| newCardState Editing) id model
                , focusCardInput id
                )

            SaveRule id text ->
                ( updateRule (updateRuleCard <| newCardState Saving) id model
                , Requests.updateCard id text |> send
                )

            EditExample ruleId id ->
                ( updateRule (updateExampleCard (newCardState Editing) id) ruleId model
                , focusCardInput id
                )

            SaveExample ruleId id text ->
                ( updateRule (updateExampleCard (newCardState Saving) id) ruleId model
                , Requests.updateCard id text |> send
                )

            EditQuestion id ->
                ( updateQuestionCard (newCardState Editing) id model
                , focusCardInput id
                )

            SaveQuestion id text ->
                ( updateQuestionCard (newCardState Saving) id model
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


updateModel : Model -> String -> Model
updateModel model update =
    case (decodeString (modelDecoder model.flags) update) of
        Ok m ->
            { model
                | storyCard = m.storyCard
                , rules = m.rules
                , questions = m.questions
            }

        Err msg ->
            { model | error = Just msg }
