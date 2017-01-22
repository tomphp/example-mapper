module State exposing (init, update, subscriptions)

import Card.Types exposing (CardState(..), CardId, Card, CardType(..), CardMsg(..))
import Card.State
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import ModelUpdater exposing (replaceCard)
import Ports
import Requests
import Rule.Types exposing (Rule, RuleId)


--import StateDecoder exposing (..)

import UpdateDecoder exposing (..)
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
--             { backendUrl = Just "ws://localhost:9000/workspace/81999634-e5f0-490f-9557-ba986dbd1e97" }
--     in
--         ( initialModel flags
--         , Requests.refresh
--             |> WebSocket.send (Maybe.withDefault "" flags.backendUrl)
--         )


initialModel : Flags -> Model
initialModel flags =
    { storyCard = Nothing
    , rules = Dict.singleton "new-rule" addRuleButton
    , questions = Dict.singleton "new-question" <| addCardButton QuestionCard "new-question"
    , error = Nothing
    , flags = flags
    }


addRuleButton : Rule
addRuleButton =
    { card = addCardButton RuleCard "new-rule"
    , examples = Dict.empty
    }


addCardButton : CardType -> CardId -> Card
addCardButton cardType cardId =
    { id = cardId
    , state = AddButton
    , text = ""
    , cardType = cardType
    , position = 9999
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
    case decodeString (modelDecoder model.flags) update of
        Ok cards ->
            List.foldl identity model (Debug.log "cards: " cards)

        Err msg ->
            { model | error = Just msg }
