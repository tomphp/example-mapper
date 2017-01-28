module Decoder.Delayed exposing (decoder)

import Dict
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (required, decode)
import Types exposing (ModelUpdater, Model, DelayedAction(..))
import Card.Types exposing (CardType(..), CardState(..), Card, CardMsg(SetAddButton))
import ModelUpdater exposing (updateQuestionCard, updateRuleCard, updateExampleCard)
import Card.State


decoder : Decoder ModelUpdater
decoder =
    decode (,)
        |> required "from" string
        |> required "client_request_no" int
        |> map buildUpdater


buildUpdater : ( String, Int ) -> ModelUpdater
buildUpdater ( clientId, requestNo ) =
    \model ->
        let
            modelIfClientIdMatches clientId model =
                if Just clientId == model.clientId then
                    Just model
                else
                    Nothing
        in
            modelIfClientIdMatches clientId model
                |> Maybe.map .delayed
                |> Maybe.andThen (Dict.get requestNo)
                |> Maybe.map (applyAction model)
                |> Maybe.withDefault model


applyAction : Model -> DelayedAction -> Model
applyAction model action =
    case action of
        ResetAddButton card ->
            resetAddButton card model


resetAddButton : Card -> Model -> Model
resetAddButton card =
    case card.cardType of
        QuestionCard ->
            updateQuestionCard "new-question" (Maybe.map (Card.State.update SetAddButton))

        RuleCard ->
            updateRuleCard "new-rule" (Maybe.map (Card.State.update SetAddButton))

        ExampleCard ruleId ->
            updateExampleCard ruleId ("new-example-" ++ ruleId) (Maybe.map (Card.State.update SetAddButton))

        _ ->
            identity
