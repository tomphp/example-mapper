module Decoder exposing (decoder)

import Decoder.Delayed as Delayed
import Decoder.SetClientId as SetClientId
import Decoder.UpdateState as UpdateState
import Json.Decode exposing (..)
import Types exposing (ModelUpdater)


decoder : Decoder (List ModelUpdater)
decoder =
    map2 (::)
        Delayed.decoder
        (field "type" string |> andThen messageDecoder)


messageDecoder : String -> Decoder (List ModelUpdater)
messageDecoder msgType =
    case msgType of
        "set_client_id" ->
            SetClientId.decoder

        "update_state" ->
            UpdateState.decoder

        _ ->
            succeed []
