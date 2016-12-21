module CardView exposing (card, CardType(..))

import Html
import Html.Attributes
import Html.Events
import List
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Types exposing (CardState(..), Msg(..), Card)
import Json.Decode as Json


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


card : CardType -> Card -> Html.Html Msg
card cardType card =
    Html.div [ Html.Events.onClick <| EditCard card.id ]
        [ svg
            [ width <| toString cardWidth
            , height <| toString cardHeight
            , class <| cardClass cardType card.state
            ]
            (List.append cardBackground [ cardContent card ])
        ]


cardBackground : List (Svg Msg)
cardBackground =
    let
        headLine =
            toString (2 * lineHeight)
    in
        List.append
            [ line
                [ x1 "0"
                , y1 headLine
                , x2 <| toString cardWidth
                , y2 headLine
                , class "card__headline"
                ]
                []
            ]
            lines


cardClass : CardType -> CardState -> String
cardClass cardType cardState =
    String.concat [ "card", cardTypeClass cardType, cardStateClass cardState ]


cardTypeClass : CardType -> String
cardTypeClass cardType =
    case cardType of
        StoryCard ->
            " card--story"

        RuleCard ->
            " card--rule"

        ExampleCard ->
            " card--example"

        QuestionCard ->
            " card--question"


cardStateClass : CardState -> String
cardStateClass state =
    case state of
        Editing ->
            " card--editing"

        Saving ->
            " card--saving"

        _ ->
            ""


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


cardContent : Card -> Svg Msg
cardContent card =
    foreignObject
        [ x <| toString lineHeight
        , y <| toString textOffset
        , width <| toString (cardWidth - 2 * lineHeight)
        , height <| toString (cardHeight - 2 * lineHeight)
        ]
        (case card.state of
            Editing ->
                cardInput card

            _ ->
                cardText card.text
        )


cardText : String -> List (Html.Html Msg)
cardText text =
    [ Html.p [ class "card__text" ] [ Html.text text ] ]


cardInput : Card -> List (Html.Html Msg)
cardInput card =
    [ Html.textarea
        [ Html.Attributes.id ("card-input-" ++ card.id)
        , Html.Attributes.class "card__input"
        , Html.Events.on "blur" (Json.map (SaveCard card.id) inputValue)
        ]
        [ Html.text card.text ]
    ]


inputValue : Json.Decoder String
inputValue =
    Json.at [ "target", "value" ] Json.string


divisibleBy : Int -> Int -> Bool
divisibleBy divisor number =
    number % divisor == 0
