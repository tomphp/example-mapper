module Decoder.SetClientId exposing (decoder)

import Types exposing (ModelUpdater)
import Json.Decode exposing (..)
import Model


decoder : Decoder (List ModelUpdater)
decoder =
    field "client_id" string
        |> map Model.setClientId
        |> map (\x -> [ x ])
