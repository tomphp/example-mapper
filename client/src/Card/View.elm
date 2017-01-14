module Card.View exposing (existingCard, newCard)

import Card.Types exposing (CardState(..), Card, CardType(..))
import Html
import Html.Attributes
import Html.Events
import Json.Decode as Json
import List
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Types exposing (Msg(..))


cardWidth : Int
cardWidth =
    254


cardHeight : Int
cardHeight =
    156


lineHeight : Int
lineHeight =
    12


textOffset : Int
textOffset =
    17


newCard : Card -> Html.Html Msg
newCard card =
    Html.div
        [ Html.Events.onClick <| UpdateCardInModel { card | state = Editing }
        , Html.Attributes.class <| cardClass card.cardType card.state
        , Html.Attributes.id card.id
        ]
        [ svg
            [ width <| toString cardWidth
            , height <| toString cardHeight
            ]
          <|
            cardBackground
                ++ [ cardContent (SaveNewCard card.cardType) card ]
        ]


existingCard : Card -> Html.Html Msg
existingCard card =
    let
        saveAction =
            \text -> SaveCard { card | text = text }
    in
        Html.div
            [ Html.Events.onClick <| UpdateCardInModel { card | state = Editing }
            , Html.Attributes.class <| cardClass card.cardType card.state
            , Html.Attributes.id <| "card-" ++ card.id
            ]
            [ svg
                [ width <| toString cardWidth
                , height <| toString cardHeight
                ]
              <|
                cardBackground
                    ++ [ cardContent saveAction card ]
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

        ExampleCard _ ->
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


cardContent : (String -> Msg) -> Card -> Svg Msg
cardContent save card =
    foreignObject
        [ x <| toString lineHeight
        , y <| toString textOffset
        , width <| toString (cardWidth - 2 * lineHeight)
        , height <| toString (cardHeight - 2 * lineHeight)
        ]
        (case card.state of
            Editing ->
                cardInput save card

            _ ->
                cardText card.text
        )


cardText : String -> List (Html.Html Msg)
cardText text =
    [ Html.p [ class "card__text" ] (nl2br text) ]


nl2br : String -> List (Html.Html msg)
nl2br text =
    String.split "\n" text
        |> List.map Html.text
        |> List.intersperse (Html.br [] [])


cardInput : (String -> Msg) -> Card -> List (Html.Html Msg)
cardInput save card =
    [ Html.textarea
        [ Html.Attributes.id ("card-input-" ++ card.id)
        , Html.Attributes.class "card__input"
        , Html.Events.on "blur" (Json.map save inputValue)
        ]
        [ Html.text card.text ]
    ]


inputValue : Json.Decoder String
inputValue =
    Json.at [ "target", "value" ] Json.string


divisibleBy : Int -> Int -> Bool
divisibleBy divisor number =
    number % divisor == 0
