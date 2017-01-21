module Card.View exposing (view)

import Card.Types exposing (CardState(..), Card, CardType(..))
import Card.View.AddButton as AddButton
import Card.View.Background as Background
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import List
import Card.Types exposing (CardMsg(..))


view : Card -> Html CardMsg
view card =
    case card.state of
        AddButton ->
            AddButton.view card

        _ ->
            drawCard card


drawCard : Card -> Html CardMsg
drawCard card =
    let
        clickHandler =
            case card.state of
                Saved ->
                    [ onClick StartEditing ]

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


toolbar : Card -> List (Html CardMsg)
toolbar card =
    case card.state of
        Preparing ->
            [ editToolbar card ]

        Editing _ ->
            [ editToolbar card ]

        _ ->
            []


editToolbar : Card -> Html CardMsg
editToolbar card =
    div [ class "card__toolbar" ]
        [ button
            [ class "card__toolbar-button card__toolbar-button--save"
            , onClick <| saveAction card
            , title "Save card"
            ]
            []
        , cancelButton card
        ]


cancelButton : Card -> Html CardMsg
cancelButton card =
    let
        cssClasses =
            class "card__toolbar-button card__toolbar-button--cancel"

        label =
            title "Cancel"

        actions =
            [ case card.state of
                Preparing ->
                    onClick CancelCreateNew

                Editing originalText ->
                    onClick <| CancelEditing originalText

                _ ->
                    Html.Attributes.disabled True
            ]
    in
        button (cssClasses :: label :: actions) []


saveAction : Card -> CardMsg
saveAction card =
    case card.state of
        Preparing ->
            FinishCreateNew

        _ ->
            FinishEditing


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

        Preparing ->
            " card--editing"

        Saving ->
            " card--saving"

        _ ->
            ""


cardContent : Card -> Html CardMsg
cardContent card =
    div
        [ class "card__content" ]
        (case card.state of
            Editing _ ->
                cardInput card

            Preparing ->
                cardInput card

            _ ->
                cardText card.text
        )


cardText : String -> List (Html CardMsg)
cardText text =
    [ p [ class "card__text" ] (nl2br text) ]


nl2br : String -> List (Html msg)
nl2br text =
    String.split "\n" text
        |> List.map Html.text
        |> List.intersperse (br [] [])


cardInput : Card -> List (Html CardMsg)
cardInput card =
    [ textarea
        [ id ("card-input-" ++ card.id)
        , class "card__input"
        , on "input" (Json.map UpdateCardText inputValue)
        ]
        [ text card.text ]
    ]


inputValue : Json.Decoder String
inputValue =
    Json.at [ "target", "value" ] Json.string
