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


addCardButton : CardType -> Card
addCardButton cardType =
    { id = { uid = cardId cardType, cardType = cardType }
    , state = AddButton
    , text = ""
    , position = 999
    , version = 1
    }


cardId : CardType -> String
cardId cardType =
    case cardType of
        RuleCard ->
            "new-rule"

        ExampleCard ruleId ->
            "new-example-" ++ ruleId

        QuestionCard ->
            "new-question"

        StoryCard ->
            "new-story"
