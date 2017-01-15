module State exposing (init, update, subscriptions)

import Card.Types exposing (CardState(..), CardId, Card, CardType(..))
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
                ( fetchCard model cardType "new-question"
                    |> Maybe.map (\card -> { card | state = Saving })
                    |> Maybe.map (replaceCard model)
                    |> Maybe.withDefault model
                , Requests.addQuestion text |> wsSend
                )

            RuleCard ->
                ( fetchCard model cardType "new-rule"
                    |> Maybe.map (\card -> { card | state = Saving })
                    |> Maybe.map (replaceCard model)
                    |> Maybe.withDefault model
                , Requests.addRule text |> wsSend
                )

            ExampleCard ruleId ->
                ( model
                , Requests.addExample ruleId text |> wsSend
                )

            _ ->
                ( model, Cmd.none )


maybeCall : a -> (a -> b -> a) -> Maybe b -> a
maybeCall model fn card =
    case card of
        Just c ->
            fn model c

        Nothing ->
            model


createCard : Model -> CardType -> ( Model, Cmd Msg )
createCard model cardType =
    let
        id =
            case cardType of
                QuestionCard ->
                    "new-question"

                RuleCard ->
                    "new-rule"

                ExampleCard ruleId ->
                    "new-example-" ++ ruleId

                _ ->
                    "invalid-card-id"
    in
        ( replaceCard model
            { id = id
            , state = Preparing
            , text = ""
            , cardType = cardType
            , position = 9999
            }
        , focusCardInput id
        )


fetchCard : Model -> CardType -> CardId -> Maybe Card
fetchCard model cardType id =
    case cardType of
        StoryCard ->
            model.storyCard

        RuleCard ->
            Dict.get id model.rules |> Maybe.map .card

        ExampleCard ruleId ->
            Dict.get ruleId model.rules
                |> Maybe.map .examples
                |> Maybe.andThen (Dict.get id)

        QuestionCard ->
            Dict.get id model.questions


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



-- updateAddExampleState : Model -> CardId -> AddButtonState -> Model
-- updateAddExampleState model ruleId state =
--     { model | rules = Dict.update ruleId (Maybe.map (\r -> { r | addExample = state })) model.rules }


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
addExampleButton id rule =
    let
        exampleId =
            "new-example-" ++ id

        button =
            addCard (ExampleCard id) exampleId
    in
        { rule | examples = Dict.insert exampleId button rule.examples }
