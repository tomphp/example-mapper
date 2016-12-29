module App exposing (main)

import State exposing (..)
import View exposing (..)
import Html
import Types


main : Program Types.Flags Types.Model Types.Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- main =
--     Html.program
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
