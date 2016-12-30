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


card : CardType -> Card -> Html.Html Msg
card cardType card =
    Html.div
        [ Html.Events.onClick <| editAction cardType <| card.id
        , Html.Attributes.class <| cardClass cardType card.state
        ]
        [ svg
            [ width <| toString cardWidth
            , height <| toString cardHeight
            ]
            (List.append cardBackground [ cardContent cardType card ])
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


cardContent : CardType -> Card -> Svg Msg
cardContent cardType card =
    foreignObject
        [ x <| toString lineHeight
        , y <| toString textOffset
        , width <| toString (cardWidth - 2 * lineHeight)
        , height <| toString (cardHeight - 2 * lineHeight)
        ]
        (case card.state of
            Editing ->
                cardInput cardType card

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


cardInput : CardType -> Card -> List (Html.Html Msg)
cardInput cardType card =
    [ Html.textarea
        [ Html.Attributes.id ("card-input-" ++ card.id)
        , Html.Attributes.class "card__input"
        , Html.Events.on "blur" (Json.map (saveAction cardType card) inputValue)
        ]
        [ Html.text card.text ]
    ]


editAction : CardType -> (String -> Msg)
editAction cardType =
    case cardType of
        StoryCard ->
            EditStory

        RuleCard ->
            EditRule

        ExampleCard ruleId ->
            EditExample ruleId

        QuestionCard ->
            EditQuestion

        _ ->
            always Noop


saveAction : CardType -> Card -> (String -> Msg)
saveAction cardType card =
    case cardType of
        NewRuleCard ->
            SendNewRule

        NewQuestionCard ->
            SendNewQuestion

        NewExampleCard id ->
            SendNewExample id

        StoryCard ->
            SaveStory card.id

        RuleCard ->
            SaveRule card.id

        ExampleCard ruleId ->
            SaveExample ruleId card.id

        QuestionCard ->
            SaveQuestion card.id


inputValue : Json.Decoder String
inputValue =
    Json.at [ "target", "value" ] Json.string


divisibleBy : Int -> Int -> Bool
divisibleBy divisor number =
    number % divisor == 0
