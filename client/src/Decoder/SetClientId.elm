module Decoder.SetClientId exposing (decoder)

import Types exposing (ModelUpdater)
import Json.Decode exposing (..)
import ModelUpdater exposing (setClientId)


decoder : Decoder (List ModelUpdater)
decoder =
    field "client_id" string
        |> map setClientId
        |> map (\x -> [ x ])
