module App exposing (main)

import State exposing (..)
import View exposing (..)
import Html
import Types


main : Program Never Types.Model Types.Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
