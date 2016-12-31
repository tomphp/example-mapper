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
        , CardType(..)
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        send =
            WebSocket.send model.flags.backendUrl
    in
        case msg of
            Noop ->
                ( model, Cmd.none )

            UpdateModel update ->
                ( updateModel model update, Cmd.none )

            UpdateCardInModel card ->
                ( replaceCard model card, focusCardInput card.id )

            SaveCard card ->
                saveCard model card

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


replaceCard : Model -> Card -> Model
replaceCard model card =
    case card.cardType of
        StoryCard ->
            { model | storyCard = Just card }

        RuleCard ->
            updateRule (replaceRuleCard card) card.id model

        ExampleCard ruleId ->
            updateRule (replaceExampleCard card) ruleId model

        QuestionCard ->
            replaceQuestionCard card model

        _ ->
            model


updateRule : (Rule -> Rule) -> CardId -> Model -> Model
updateRule update ruleId model =
    { model | rules = Dict.update ruleId (Maybe.map update) model.rules }


replaceRuleCard : Card -> Rule -> Rule
replaceRuleCard card rule =
    { rule | card = card }


replaceQuestionCard : Card -> Model -> Model
replaceQuestionCard card model =
    { model | questions = Dict.update card.id (always <| Just card) model.questions }


replaceExampleCard : Card -> Rule -> Rule
replaceExampleCard card rule =
    { rule | examples = Dict.update card.id (always <| Just card) rule.examples }


saveCard : Model -> Card -> ( Model, Cmd Msg )
saveCard model theCard =
    let
        send =
            WebSocket.send model.flags.backendUrl

        card =
            { theCard | state = Saving }
    in
        ( replaceCard model card, Requests.updateCard card |> send )


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
