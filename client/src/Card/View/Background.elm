module Card.View.Background exposing (view)

import Card.Types exposing (Card, CardMsg(..))
import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


cardWidth : Int
cardWidth =
    318


cardHeight : Int
cardHeight =
    190


lineHeight : Int
lineHeight =
    15


view : Card -> Html CardMsg
view card =
    svg
        [ class "card__background"
        , width (toString cardWidth)
        , height (toString cardHeight)
        ]
        cardBackground


cardBackground : List (Svg CardMsg)
cardBackground =
    let
        headLine =
            toString (2 * lineHeight)
    in
        List.append
            [ line
                [ x1 "0"
                , y1 headLine
                , x2 (toString cardWidth)
                , y2 headLine
                , class "card__headline"
                ]
                []
            ]
            lines


lines : List (Svg CardMsg)
lines =
    let
        start =
            3 * lineHeight

        end =
            cardHeight

        lines =
            List.filter (divisibleBy lineHeight) (List.range start end)
                |> List.map toString
    in
        List.map
            (\y ->
                line
                    [ x1 "0"
                    , y1 y
                    , x2 (toString cardWidth)
                    , y2 y
                    , class "card__line"
                    ]
                    []
            )
            lines


divisibleBy : Int -> Int -> Bool
divisibleBy divisor number =
    number % divisor == 0
