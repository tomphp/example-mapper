module Card.State exposing (update)

import Card.Types exposing (Card, CardMsg(..), CardState(..))


update : CardMsg -> Card -> Card
update msg card =
    case msg of
        UpdateCardText text ->
            { card | text = text }

        StartEditing ->
            { card | state = Editing (card.text) }

        StartCreateNew ->
            { card | state = Preparing (card.text) }

        FinishEditing ->
            { card | state = Saving }

        FinishCreateNew ->
            { card | state = Saving }

        _ ->
            card
