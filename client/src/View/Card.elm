module View.Card exposing (card)

import Html
import Html.Attributes
import Html.Events
import List
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Types exposing (CardState(..), Msg(..), Card, CardType(..))
import Json.Decode as Json


cardWidth =
    254


cardHeight =
    156


lineHeight =
    12


textOffset =
    17


card : Card -> Html.Html Msg
card card =
    Html.div
        [ Html.Events.onClick <| UpdateCardInModel { card | state = Editing }
        , Html.Attributes.class <| cardClass card.cardType card.state
        ]
        [ svg
            [ width <| toString cardWidth
            , height <| toString cardHeight
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

        ExampleCard _ ->
            " card--example"

        QuestionCard ->
            " card--question"

        NewRuleCard ->
            " card--rule"

        NewExampleCard _ ->
            " card--example"

        NewQuestionCard ->
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
    [ Html.p [ class "card__text" ] (nl2br text) ]


nl2br : String -> List (Html.Html msg)
nl2br text =
    String.split "\n" text
        |> List.map Html.text
        |> List.intersperse (Html.br [] [])


cardInput : Card -> List (Html.Html Msg)
cardInput card =
    [ Html.textarea
        [ Html.Attributes.id ("card-input-" ++ card.id)
        , Html.Attributes.class "card__input"
        , Html.Events.on "blur" (Json.map (saveAction card) inputValue)
        ]
        [ Html.text card.text ]
    ]


saveAction : Card -> String -> Msg
saveAction card text =
    case card.cardType of
        NewRuleCard ->
            SendNewRule text

        NewQuestionCard ->
            SendNewQuestion text

        NewExampleCard id ->
            SendNewExample id text

        StoryCard ->
            SaveCard { card | text = text }

        RuleCard ->
            SaveCard { card | text = text }

        ExampleCard ruleId ->
            SaveCard { card | text = text }

        QuestionCard ->
            SaveCard { card | text = text }


inputValue : Json.Decoder String
inputValue =
    Json.at [ "target", "value" ] Json.string


divisibleBy : Int -> Int -> Bool
divisibleBy divisor number =
    number % divisor == 0
