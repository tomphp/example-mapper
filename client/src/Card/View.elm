module Card.View exposing (view)

import Card.Types exposing (CardState(..), Card, CardType(..))
import Card.View.AddButton as AddButton
import Card.View.Background as Background
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import List
import Types exposing (Msg(..))


view : Card -> Html Msg
view card =
    case card.state of
        AddButton ->
            AddButton.view card

        _ ->
            drawCard card


drawCard : Card -> Html Msg
drawCard card =
    let
        clickHandler =
            case card.state of
                Saved ->
                    [ onClick <| UpdateCardInModel { card | state = Editing card.text } ]

                _ ->
                    []

        attributes =
            [ class <| cardClass card.cardType card.state
            , id <| "card-" ++ card.id
            ]
                ++ clickHandler
    in
        div attributes
            (List.concat
                [ toolbar card
                , [ Background.view card ]
                , [ cardContent card ]
                ]
            )


toolbar : Card -> List (Html Msg)
toolbar card =
    case card.state of
        Preparing _ ->
            [ editToolbar card ]

        Editing _ ->
            [ editToolbar card ]

        _ ->
            []


editToolbar : Card -> Html Msg
editToolbar card =
    div [ class "card__toolbar" ]
        [ button
            [ class "card__toolbar-button card__toolbar-button--save"
            , onClick <| saveAction card
            , title "Save card"
            ]
            []
        , button
            [ class "card__toolbar-button card__toolbar-button--cancel"
            , title "Cancel"
            ]
            []
        ]


saveAction : Card -> Msg
saveAction card =
    case card.state of
        Preparing _ ->
            SaveNewCard card.cardType card.text

        _ ->
            SaveCard card


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
        Editing _ ->
            " card--editing"

        Preparing _ ->
            " card--editing"

        Saving ->
            " card--saving"

        _ ->
            ""


cardContent : Card -> Html Msg
cardContent card =
    div
        [ class "card__content" ]
        (case card.state of
            Editing _ ->
                cardInput card

            Preparing _ ->
                cardInput card

            _ ->
                cardText card.text
        )


cardText : String -> List (Html Msg)
cardText text =
    [ p [ class "card__text" ] (nl2br text) ]


nl2br : String -> List (Html msg)
nl2br text =
    String.split "\n" text
        |> List.map Html.text
        |> List.intersperse (br [] [])


cardInput : Card -> List (Html Msg)
cardInput card =
    [ textarea
        [ id ("card-input-" ++ card.id)
        , class "card__input"
        , on "input" (Json.map (updateCardText card) inputValue)
        ]
        [ text card.text ]
    ]


inputValue : Json.Decoder String
inputValue =
    Json.at [ "target", "value" ] Json.string


updateCardText : Card -> String -> Msg
updateCardText card value =
    UpdateCardText card value
