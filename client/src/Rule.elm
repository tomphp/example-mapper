module Rule exposing (updateCard)

import Rule.Types exposing (Rule)
import Card.Types exposing (Card)


updateCard : (Maybe Card -> Maybe Card) -> Rule -> Rule
updateCard update rule =
    { rule | card = update (Just rule.card) |> Maybe.withDefault rule.card }
