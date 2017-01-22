module Decoder exposing (decoder)

import Decoder.Common exposing (..)
import Decoder.SetClientId as SetClientId
import Decoder.UpdateState as UpdateState
import Json.Decode exposing (..)


decoder : Decoder (List ModelUpdater)
decoder =
    field "type" string
        |> andThen messageDecoder


messageDecoder : String -> Decoder (List ModelUpdater)
messageDecoder msgType =
    case msgType of
        "set_client_id" ->
            SetClientId.decoder

        "update_state" ->
            UpdateState.decoder

        _ ->
            succeed []
