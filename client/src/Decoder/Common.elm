module Decoder.Common exposing (ModelUpdater)

import Types exposing (Model)


type alias ModelUpdater =
    Model -> Model
