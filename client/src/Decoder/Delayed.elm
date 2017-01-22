module Decoder.Delayed exposing (decoder)

import Dict
import Json.Decode exposing (..)
import Types exposing (ModelUpdater, Model, DelayedAction(..))
import Card.Types exposing (CardType(..), CardState(..), Card)


decoder : Decoder ModelUpdater
decoder =
    (map2 (,) (field "from" string) (field "client_request_no" int))
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
            resetAddButton model card


resetAddButton : Model -> Card -> Model
resetAddButton model card =
    case card.cardType of
        QuestionCard ->
            { model
                | questions =
                    Dict.update
                        "new-question"
                        (Maybe.map (\c -> { c | state = AddButton, text = "" }))
                        model.questions
            }

        _ ->
            model
