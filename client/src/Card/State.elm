module Card.State exposing (update)

import Card.Types exposing (Card, CardMsg(..), CardState(..))


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
