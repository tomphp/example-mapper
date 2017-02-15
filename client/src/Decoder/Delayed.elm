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
        |> map (uncurry buildUpdater)


buildUpdater : String -> Int -> ModelUpdater
buildUpdater clientId requestNo model =
    if clientIdMatches clientId model then
        actionForRequest requestNo model
            |> Maybe.map (applyAction model)
            |> Maybe.withDefault model
    else
        model


clientIdMatches : String -> Model -> Bool
clientIdMatches clientId model =
    Just clientId == model.clientId


actionForRequest : Int -> Model -> Maybe DelayedAction
actionForRequest requestNo =
    .delayed >> Dict.get requestNo


applyAction : Model -> DelayedAction -> Model
applyAction model action =
    case action of
        ResetAddButton card ->
            resetAddButton card model


resetAddButton : Card -> Model -> Model
resetAddButton card =
    Model.addOrUpdateCard card.id (Maybe.map (Card.State.update SetAddButton))
