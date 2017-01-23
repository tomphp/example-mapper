module State exposing (init, update, subscriptions)

import Card.State exposing (addCardButton)
import Card.Types exposing (CardState(..), CardId, Card, CardType(..), CardMsg(..))
import Decoder exposing (decoder)
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import Json.Encode exposing (object, encode, Value, int)
import ModelUpdater exposing (..)
import Ports
import Requests
import Rule.State
import Rule.Types exposing (Rule, RuleMsg(..))
import Task
import Types exposing (Model, Msg(..), Flags, Request, ModelUpdater, DelayedAction(..))
import WebSocket


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
                updatedModel =
                    { model | lastRequestNo = model.lastRequestNo + 1 }

                json =
                    request
                        |> Requests.addRequestNo updatedModel.lastRequestNo
                        |> object
                        |> encode 0
            in
                ( updatedModel, send model.flags.backendUrl json )

        UpdateModel update ->
            ( updateModel model update, Cmd.none )

        Types.UpdateCard card msg ->
            card
                |> Card.State.update msg
                |> replaceCard model
                |> handleCardUpdate msg card

        UpdateRule rule msg ->
            Rule.State.update msg rule
                |> replaceRule model
                |> handleRuleUpdate msg rule


handleRuleUpdate : RuleMsg -> Rule -> Model -> ( Model, Cmd Msg )
handleRuleUpdate msg rule model =
    case msg of
        Rule.Types.UpdateCard card msg ->
            card
                |> Card.State.update msg
                |> replaceCard model
                |> handleCardUpdate msg card


handleCardUpdate : CardMsg -> Card -> Model -> ( Model, Cmd Msg )
handleCardUpdate msg card model =
    let
        sendRequest =
            \req -> update (SendRequest req) model
    in
        case msg of
            StartEditing ->
                ( model, focusCardInput card.id )

            StartCreateNew ->
                ( model, focusCardInput card.id )

            FinishEditing ->
                sendRequest <| Requests.updateCard card

            FinishCreateNew ->
                newCardRequest card
                    |> Maybe.map sendRequest
                    |> Maybe.map (delayAction <| ResetAddButton card)
                    |> Maybe.withDefault ( model, Cmd.none )

            _ ->
                ( model, Cmd.none )


delayAction : DelayedAction -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
delayAction updater result =
    mapModel (addDelayedAction updater) result


mapModel : ModelUpdater -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
mapModel updater ( model, cmd ) =
    ( updater model, cmd )


newCardRequest : Card -> Maybe Request
newCardRequest card =
    case card.cardType of
        QuestionCard ->
            Just <| Requests.addQuestion card.text

        RuleCard ->
            Just <| Requests.addRule card.text

        ExampleCard ruleId ->
            Just <| Requests.addExample ruleId card.text

        _ ->
            Nothing


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
    case decodeString decoder update of
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
