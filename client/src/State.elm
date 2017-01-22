module State exposing (init, update, subscriptions)

import Card.State exposing (addCardButton)
import Card.Types exposing (CardState(..), CardId, Card, CardType(..), CardMsg(..))
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import ModelUpdater exposing (replaceCard)
import Ports
import Requests exposing (Request)
import Task
import Types exposing (Model, Msg(..), Flags)
import Decoder exposing (decoder)
import WebSocket
import Json.Encode exposing (object, encode, Value, int)


type Command
    = Command (Cmd Msg)
    | SendRequest Request


send : Maybe String -> String -> Cmd Msg
send url =
    case url of
        Just u ->
            WebSocket.send u

        Nothing ->
            Ports.socketOut


sendRequest : Model -> Command -> ( Model, Cmd Msg )
sendRequest model req =
    case req of
        SendRequest request ->
            let
                requestNo =
                    model.lastRequestNo + 1

                payload =
                    ( "request_no", int requestNo ) :: request

                json =
                    object payload |> encode 0
            in
                ( { model | lastRequestNo = requestNo }
                , send model.flags.backendUrl json
                )

        Command cmd ->
            ( model, cmd )


init : Flags -> ( Model, Cmd Msg )
init flags =
    sendRequest (initialModel flags) (SendRequest Requests.refresh)



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
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        UpdateModel update ->
            ( updateModel model update, Cmd.none )

        UpdateCard card msg ->
            let
                updatedCard =
                    Card.State.update msg card
            in
                sendRequest
                    (replaceCard updatedCard model)
                    (cardUpdateAction model msg updatedCard)


cardUpdateAction : Model -> CardMsg -> Card -> Command
cardUpdateAction model msg card =
    case msg of
        StartEditing ->
            Command <| focusCardInput card.id

        StartCreateNew ->
            Command <| focusCardInput card.id

        FinishEditing ->
            saveCard card

        FinishCreateNew ->
            saveNewCard model card

        _ ->
            Command Cmd.none


saveNewCard : Model -> Card -> Command
saveNewCard model card =
    case card.cardType of
        QuestionCard ->
            Requests.addQuestion card.text |> SendRequest

        RuleCard ->
            Requests.addRule card.text |> SendRequest

        ExampleCard ruleId ->
            Requests.addExample ruleId card.text |> SendRequest

        _ ->
            Command Cmd.none


saveCard : Card -> Command
saveCard =
    Requests.updateCard >> SendRequest


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
            List.foldl identity model (Debug.log "cards: " cards)

        Err msg ->
            { model | error = Just msg }
