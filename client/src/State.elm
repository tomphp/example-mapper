module State exposing (init, update, subscriptions)

import Card.State exposing (addCardButton)
import Card.Types exposing (CardState(..), CardId, Card, CardType(..), CardMsg(..))
import Decoder exposing (decoder)
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import ModelUpdater exposing (..)
import Ports
import Requests
import Rule.State
import Rule.Types exposing (Rule, RuleMsg(..))
import Task
import Types exposing (Model, Msg(..), Flags, Request, ModelUpdater, DelayedAction(..))
import WebSocket
import Maybe.Extra


init : Flags -> ( Model, Cmd Msg )
init flags =
    update (SendRequest Requests.refresh) (initialModel flags)



-- init : ( Model, Cmd Msg )
-- init =
--     let
--         flags =
--             { backendUrl = Just "ws://localhost:9000/workspace/81999634-e5f0-490f-9557-ba986dbd1e97" }
--     in
--         ( initialModel flags
--         , Requests.refresh
--             |> WebSocket.send (Maybe.withDefault "" flags.backendUrl)
--         )


initialModel : Flags -> Model
initialModel flags =
    let
        addQuestionButton =
            addCardButton QuestionCard

        newRuleColumn =
            { card = addCardButton RuleCard
            , examples = Dict.empty
            }
    in
        { clientId = Nothing
        , lastRequestNo = 0
        , storyCard = Nothing
        , rules = Dict.singleton newRuleColumn.card.id newRuleColumn
        , questions = Dict.singleton addQuestionButton.id addQuestionButton
        , error = Nothing
        , flags = flags
        , delayed = Dict.empty
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        SendRequest request ->
            let
                m =
                    { model | lastRequestNo = model.lastRequestNo + 1 }

                cmd =
                    Requests.toJson model request |> send model.flags.backendUrl
            in
                ( m, cmd )

        UpdateModel json ->
            ( updateModel json model, Cmd.none )

        Types.UpdateCard card msg ->
            model
                |> updateCard card.id card.cardType (Maybe.map <| Card.State.update msg)
                |> handleCardUpdate msg card

        UpdateRule rule msg ->
            model
                |> updateRule rule.card.id (Maybe.map <| Rule.State.update msg)
                |> handleRuleUpdate msg rule


handleRuleUpdate : RuleMsg -> Rule -> Model -> ( Model, Cmd Msg )
handleRuleUpdate msg rule model =
    case msg of
        Rule.Types.UpdateCard card msg ->
            model
                |> updateCard card.id card.cardType (Maybe.map <| Card.State.update msg)
                |> handleCardUpdate msg card


handleCardUpdate : CardMsg -> Card -> Model -> ( Model, Cmd Msg )
handleCardUpdate msg card model =
    let
        sendRequest =
            \req -> update (SendRequest req) model

        thing =
            newCardRequest card |> Maybe.map SendRequest |> Maybe.map update
    in
        case msg of
            StartEditing ->
                ( model, focusCardInput card.id )

            StartCreateNew ->
                ( model, focusCardInput card.id )

            FinishEditing ->
                sendRequest (Requests.updateCard card)

            FinishCreateNew ->
                model
                    |> addDelayedAction (ResetAddButton card)
                    |> Just
                    |> (\m -> Maybe.Extra.andMap m thing)
                    |> Maybe.withDefault ( model, Cmd.none )

            _ ->
                ( model, Cmd.none )


newCardRequest : Card -> Maybe Request
newCardRequest card =
    case card.cardType of
        QuestionCard ->
            Just (Requests.addQuestion card.text)

        RuleCard ->
            Just (Requests.addRule card.text)

        ExampleCard ruleId ->
            Just (Requests.addExample ruleId card.text)

        _ ->
            Nothing


focusCardInput : String -> Cmd Msg
focusCardInput id =
    Task.attempt (\_ -> Noop) (Dom.focus ("card-input-" ++ id))


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.flags.backendUrl of
        Just url ->
            WebSocket.listen url UpdateModel

        Nothing ->
            Ports.socketIn UpdateModel


updateModel : String -> Model -> Model
updateModel json model =
    case decodeString decoder json of
        Ok cards ->
            List.foldl identity model cards

        Err msg ->
            { model | error = Just msg }


send : Maybe String -> String -> Cmd Msg
send url =
    case url of
        Just u ->
            WebSocket.send u

        Nothing ->
            Ports.socketOut
