module Card.View exposing (view)

import Card.Types exposing (CardMsg(..))
import Card.Types exposing (CardState(..), Card, CardType(..))
import Card.View.AddButton as AddButton
import Card.View.Background as Background
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Decode as Json
import Maybe.Extra
import List


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
        attributes =
            [ class (cardClass card.id.cardType card.state)
            , id ("card-" ++ card.id.uid)
            ]
    in
        div (attributes ++ cardClickHandler card)
            (List.concat
                [ [ toolbar card ]
                , [ Background.view card ]
                , [ cardContent card ]
                , cardOverlay card
                ]
            )


cardClickHandler : Card -> List (Attribute CardMsg)
cardClickHandler card =
    case card.state of
        Saved ->
            [ onClick StartEditing ]

        _ ->
            []


toolbar : Card -> Html CardMsg
toolbar card =
    case card.state of
        Preparing ->
            div [ class "card__toolbar" ] (editToolbar card)

        Editing _ ->
            div [ class "card__toolbar" ] (editToolbar card)

        Saved ->
            div [ class "card__toolbar card__toolbar--mouseover" ] (normalToolbar card)

        _ ->
            div [ class "card__toolbar" ] []


normalToolbar : Card -> List (Html CardMsg)
normalToolbar card =
    case card.id.cardType of
        StoryCard ->
            []

        _ ->
            [ button
                [ class "card__toolbar-button card__toolbar-button--delete"
                , onWithOptions
                    "click"
                    { preventDefault = True, stopPropagation = True }
                    (Json.succeed RequestDelete)
                , title "Delete Card"
                ]
                []
            ]


editToolbar : Card -> List (Html CardMsg)
editToolbar card =
    [ button
        [ class "card__toolbar-button card__toolbar-button--save"
        , onClick (saveAction card)
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
                    onClick (CancelEditing originalText)

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


cardOverlay : Card -> List (Html CardMsg)
cardOverlay card =
    case card.state of
        DeleteRequested ->
            [ div
                [ class "card__overlay card__overlay--yes-no" ]
                [ div [ class "card__overlay__message" ]
                    [ text ("Are you sure you want to delete this " ++ (cardName card) ++ "?") ]
                , div [ class "card__overlay__buttons" ]
                    [ button
                        [ class "card__overlay__button card__overlay__button--yes"
                        , onClick ConfirmDelete
                        ]
                        []
                    , button
                        [ class "card__overlay__button card__overlay__button--no"
                        , onClick CancelDelete
                        ]
                        []
                    ]
                ]
            ]

        _ ->
            []


cardName : Card -> String
cardName card =
    case card.id.cardType of
        StoryCard ->
            "story"

        RuleCard ->
            "rule"

        ExampleCard _ ->
            "example"

        QuestionCard ->
            "question"


cardClass : CardType -> CardState -> String
cardClass cardType cardState =
    [ Just "card"
    , Just (cardTypeClass cardType)
    , cardStateClass cardState
    ]
        |> Maybe.Extra.values
        |> List.intersperse " "
        |> String.concat


cardTypeClass : CardType -> String
cardTypeClass cardType =
    case cardType of
        StoryCard ->
            "card--story"

        RuleCard ->
            "card--rule"

        ExampleCard _ ->
            "card--example"

        QuestionCard ->
            "card--question"


cardStateClass : CardState -> Maybe String
cardStateClass state =
    case state of
        Editing _ ->
            Just "card--editing"

        Preparing ->
            Just "card--editing"

        Saving ->
            Just "card--saving"

        _ ->
            Nothing


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
        [ id ("card-input-" ++ card.id.uid)
        , class "card__input"
        , on "input" (Json.map UpdateCardText targetValue)
        ]
        [ text card.text ]
    ]
