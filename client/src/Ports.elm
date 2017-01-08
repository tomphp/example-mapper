port module Ports exposing (..)


port socketOut : String -> Cmd msg


port socketIn : (String -> msg) -> Sub msg
