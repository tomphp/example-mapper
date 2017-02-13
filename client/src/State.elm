module State exposing (init, update, subscriptions)

import Card.State exposing (addCardButton)
import Card.Types exposing (CardState(..), Card, CardType(..), CardMsg(..), CardId)
import Decoder exposing (decoder)
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import Ports
import Model
import Requests
import Rule.State
import Rule.Types exposing (Rule, RuleMsg(..), RuleId)
import Task
import Types exposing (Model, Msg(..), Flags, Request, ModelUpdater, DelayedAction(..))
import WebSocket


init : Flags -> ( Model, Cmd Msg )
init flags =
    sendRequest (initialModel flags) Requests.refresh



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
        , rules = Dict.singleton newRuleColumn.card.id.uid newRuleColumn
        , questions = Dict.singleton addQuestionButton.id.uid addQuestionButton
        , error = Nothing
        , flags = flags
        , delayed = Dict.empty
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        UpdateModel json ->
            ( updateModel json model, Cmd.none )

        Types.UpdateCard card msg ->
            model
                |> updateCard card.id msg
                |> handleCardUpdate msg card

        UpdateRule rule msg ->
            model
                |> updateRule rule.card.id.uid msg
                |> handleRuleUpdate msg rule


handleRuleUpdate : RuleMsg -> Rule -> Model -> ( Model, Cmd Msg )
handleRuleUpdate msg rule model =
    case msg of
        Rule.Types.UpdateCard card msg ->
            model
                |> updateCard card.id msg
                |> handleCardUpdate msg card


updateCard : CardId -> CardMsg -> ModelUpdater
updateCard id msg =
    Model.updateCard id (Maybe.map (Card.State.update msg))


updateRule : RuleId -> RuleMsg -> ModelUpdater
updateRule id msg =
    Model.updateRule id (Maybe.map (Rule.State.update msg))


handleCardUpdate : CardMsg -> Card -> Model -> ( Model, Cmd Msg )
handleCardUpdate msg card model =
    case msg of
        StartEditing ->
            ( model, focusCardInput card.id.uid )

        StartCreateNew ->
            ( model, focusCardInput card.id.uid )

        FinishEditing ->
            sendRequest model (Requests.updateCard card)

        FinishCreateNew ->
            newCardRequest card
                |> Maybe.map (sendRequest model)
                |> Maybe.map (delayAction (ResetAddButton card))
                |> Maybe.withDefault ( model, Cmd.none )

        ConfirmDelete ->
            sendRequest model (Requests.deleteCard card)

        _ ->
            ( model, Cmd.none )


delayAction : DelayedAction -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
delayAction updater ( model, msg ) =
    ( Model.addDelayedAction updater model, msg )


newCardRequest : Card -> Maybe Request
newCardRequest card =
    case card.id.cardType of
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
        Ok updates ->
            Model.applyUpdates updates model

        Err msg ->
            { model | error = Just msg }


sendRequest : Model -> Request -> ( Model, Cmd Msg )
sendRequest model request =
    let
        m =
            Model.incrementLastRequestNo model

        cmd =
            Requests.toJson m request |> send m.flags.backendUrl
    in
        ( m, cmd )


send : Maybe String -> String -> Cmd Msg
send url =
    case url of
        Just u ->
            WebSocket.send u

        Nothing ->
            Ports.socketOut
