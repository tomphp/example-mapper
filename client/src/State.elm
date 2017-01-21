module State exposing (init, update, subscriptions)

import Card.Types exposing (CardState(..), CardId, Card, CardType(..), CardMsg(..))
import Card.State
import Dict exposing (Dict)
import Dom
import Json.Decode exposing (decodeString)
import Ports
import Requests
import Rule.Types exposing (Rule, RuleId)
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
--             { backendUrl = Just "ws://localhost:9000/workspace/414c091e-5360-4ec0-a52e-79d99a0430da" }
--     in
--         ( initialModel flags
--         , Requests.refresh
--             |> WebSocket.send (Maybe.withDefault "" flags.backendUrl)
--         )


initialModel : Flags -> Model
initialModel flags =
    { storyCard = Nothing
    , rules = Dict.singleton "new-rule" addRule
    , questions = Dict.singleton "new-question" <| addCard QuestionCard "new-question"
    , error = Nothing
    , flags = flags
    }


addCard : CardType -> CardId -> Card
addCard cardType cardId =
    { id = cardId
    , state = AddButton
    , text = ""
    , cardType = cardType
    , position = 9999
    }


addRule : Rule
addRule =
    { card = addCard RuleCard "new-rule"
    , examples = Dict.empty
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
                ( replaceCard model updatedCard
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
        Ok m ->
            { model
                | storyCard = m.storyCard
                , rules =
                    Dict.insert
                        "new-rule"
                        addRule
                        (Dict.map addExampleButton m.rules)
                , questions =
                    Dict.insert
                        "new-question"
                        (addCard QuestionCard "new-question")
                        m.questions
            }

        Err msg ->
            { model | error = Just msg }


addExampleButton : RuleId -> Rule -> Rule
addExampleButton ruleId rule =
    let
        exampleId =
            "new-example-" ++ ruleId

        button =
            addCard (ExampleCard ruleId) exampleId
    in
        { rule | examples = Dict.insert exampleId button rule.examples }
