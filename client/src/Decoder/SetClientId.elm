module Decoder.SetClientId exposing (decoder)

import ModelUpdater exposing (..)
import Json.Decode exposing (..)
import Decoder.Common exposing (..)


decoder : Decoder (List ModelUpdater)
decoder =
    field "client_id" string
        |> map setClientId
        |> map (\x -> [ x ])
