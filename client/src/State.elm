module State exposing (init, update, subscriptions)

import AddButton.Types exposing (AddButtonState(..))
import Card.Types exposing (CardState(..), CardId, Card, CardType(..))
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import Ports
import Requests
import Rule.Types exposing (Rule)
import StateDecoder exposing (..)
import Task
import Types exposing (Model, Msg(..), Flags)
import WebSocket


send : Maybe String -> String -> Cmd Msg
send url =
    case url of
        Just u ->
            WebSocket.send u

        Nothing ->
            Ports.socketOut


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Requests.refresh |> send flags.backendUrl )



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
    case msg of
        Noop ->
            ( model, Cmd.none )

        UpdateModel update ->
            ( updateModel model update, Cmd.none )

        UpdateCardInModel card ->
            ( replaceCard model card, focusCardInput card.id )

        SaveCard card ->
            saveCard model card

        CreateCard cardType ->
            createCard model cardType

        SaveNewCard cardType text ->
            saveNewCard model cardType text


saveNewCard : Model -> CardType -> String -> ( Model, Cmd Msg )
saveNewCard model cardType text =
    let
        wsSend =
            send model.flags.backendUrl
    in
        case cardType of
            QuestionCard ->
                ( { model | addQuestion = Button }, Requests.addQuestion text |> wsSend )

            RuleCard ->
                ( { model | addRule = Button }, Requests.addRule text |> wsSend )

            ExampleCard ruleId ->
                ( updateAddExampleState model ruleId Button
                , Requests.addExample ruleId text |> wsSend
                )

            _ ->
                ( model, Cmd.none )


createCard : Model -> CardType -> ( Model, Cmd Msg )
createCard model cardType =
    case cardType of
        QuestionCard ->
            ( { model | addQuestion = Preparing }, focusCardInput "new-question" )

        RuleCard ->
            ( { model | addRule = Preparing }, focusCardInput "new-rule" )

        ExampleCard ruleId ->
            ( updateAddExampleState model ruleId Preparing
            , focusCardInput "new-example"
            )

        _ ->
            ( model, Cmd.none )


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
        card =
            { theCard | state = Saving }
    in
        ( replaceCard model card, Requests.updateCard card |> send model.flags.backendUrl )


updateAddExampleState : Model -> CardId -> AddButtonState -> Model
updateAddExampleState model ruleId state =
    { model | rules = Dict.update ruleId (Maybe.map (\r -> { r | addExample = state })) model.rules }


focusCardInput : String -> Cmd Msg
focusCardInput id =
    Task.attempt (always Noop) (Dom.focus <| "card-input-" ++ id)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.flags.backendUrl of
        Just url ->
            WebSocket.listen url UpdateModel

        Nothing ->
            Ports.socketIn UpdateModel


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
