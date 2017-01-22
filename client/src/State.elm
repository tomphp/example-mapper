module State exposing (init, update, subscriptions)

import Card.State exposing (addCardButton)
import Card.Types exposing (CardState(..), CardId, Card, CardType(..), CardMsg(..))
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import ModelUpdater exposing (replaceCard)
import Ports
import Requests
import Task
import Types exposing (Model, Msg(..), Flags)
import Decoder exposing (decoder)
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
                ( replaceCard updatedCard model
                , cardUpdateAction model msg updatedCard
                )


cardUpdateAction : Model -> CardMsg -> Card -> Cmd Msg
cardUpdateAction model msg card =
    case msg of
        StartEditing ->
            focusCardInput card.id

        StartCreateNew ->
            focusCardInput card.id

        FinishEditing ->
            saveCard model card

        FinishCreateNew ->
            saveNewCard model card

        _ ->
            Cmd.none


saveNewCard : Model -> Card -> Cmd Msg
saveNewCard model card =
    let
        wsSend =
            send model.flags.backendUrl
    in
        case card.cardType of
            QuestionCard ->
                Requests.addQuestion card.text |> wsSend

            RuleCard ->
                Requests.addRule card.text |> wsSend

            ExampleCard ruleId ->
                Requests.addExample ruleId card.text |> wsSend

            _ ->
                Cmd.none


saveCard : Model -> Card -> Cmd Msg
saveCard model card =
    Requests.updateCard card |> send model.flags.backendUrl


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
