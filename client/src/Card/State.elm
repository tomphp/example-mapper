module Card.State exposing (update, addCardButton)

import Card.Types exposing (Card, CardMsg(..), CardState(..), CardType(..))


update : CardMsg -> Card -> Card
update msg card =
    case msg of
        UpdateCardText text ->
            { card | text = text }

        StartCreateNew ->
            { card | state = Preparing }

        FinishCreateNew ->
            { card | state = Saving }

        CancelCreateNew ->
            { card | state = AddButton, text = "" }

        StartEditing ->
            { card | state = Editing (card.text) }

        FinishEditing ->
            { card | state = Saving }

        CancelEditing originalText ->
            { card | state = Saved, text = originalText }

        SetAddButton ->
            { card | state = AddButton, text = "" }

        RequestDelete ->
            { card | state = DeleteRequested }

        CancelDelete ->
            { card | state = Saved }

        ConfirmDelete ->
            { card | state = Saving }


addCardButton : CardType -> Card
addCardButton cardType =
    { id = { uid = addCardButtonId cardType, cardType = cardType }
    , state = AddButton
    , text = ""
    , position = 999
    , version = 1
    }


addCardButtonId : CardType -> String
addCardButtonId cardType =
    case cardType of
        RuleCard ->
            "new-rule"

        ExampleCard ruleId ->
            "new-example-" ++ ruleId

        QuestionCard ->
            "new-question"

        StoryCard ->
            "new-story"
