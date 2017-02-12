module Decoder.Delayed exposing (decoder)

import Dict
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (required, decode)
import Types exposing (ModelUpdater, Model, DelayedAction(..))
import Card.Types exposing (CardType(..), CardState(..), Card, CardMsg(SetAddButton))
import Model
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
        modelIfClientIdMatches clientId model
            |> Maybe.andThen (getActionForRequest requestNo)
            |> Maybe.map (applyAction model)
            |> Maybe.withDefault model


modelIfClientIdMatches : String -> Model -> Maybe Model
modelIfClientIdMatches clientId model =
    if Just clientId == model.clientId then
        Just model
    else
        Nothing


getActionForRequest : Int -> Model -> Maybe DelayedAction
getActionForRequest requestNo =
    .delayed >> Dict.get requestNo


applyAction : Model -> DelayedAction -> Model
applyAction model action =
    case action of
        ResetAddButton card ->
            resetAddButton card model


resetAddButton : Card -> Model -> Model
resetAddButton card =
    Model.updateCard card.id (Maybe.map (Card.State.update SetAddButton))
