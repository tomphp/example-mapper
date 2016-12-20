module CardView exposing (card, CardType(..))

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Types exposing (CardState(..), Msg)
import Html
import List


type CardType
    = StoryCard
    | RuleCard
    | ExampleCard
    | QuestionCard


cardWidth =
    254


cardHeight =
    156


lineHeight =
    12


textOffset =
    17


card : CardType -> CardState -> String -> Html.Html Msg
card cardType cardState text =
    let
        headLine =
            toString (2 * lineHeight)
    in
        svg
            [ width <| toString cardWidth
            , height <| toString cardHeight
            , class <| cardClass cardType cardState
            ]
            (List.concat
                [ [ line
                        [ x1 "0"
                        , y1 headLine
                        , x2 <| toString cardWidth
                        , y2 headLine
                        , class "card__headline"
                        ]
                        []
                  ]
                , lines
                , [ cardText text ]
                ]
            )


cardClass : CardType -> CardState -> String
cardClass cardType _ =
    case cardType of
        StoryCard ->
            "card card--story"

        RuleCard ->
            "card card--rule"

        ExampleCard ->
            "card card--example"

        QuestionCard ->
            "card card--question"


lines : List (Svg Msg)
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
                    , x2 <| toString cardWidth
                    , y2 y
                    , class "card__line"
                    ]
                    []
            )
            lines


cardText : String -> Svg Msg
cardText text =
    foreignObject
        [ x <| toString lineHeight
        , y <| toString textOffset
        , width <| toString (cardWidth - 2 * lineHeight)
        , height <| toString (cardHeight - 2 * lineHeight)
        ]
        [ Html.p [ class "card__text" ] [ Html.text text ] ]


divisibleBy : Int -> Int -> Bool
divisibleBy divisor number =
    number % divisor == 0
