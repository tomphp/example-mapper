module Rule.State exposing (update)

import Rule.Types exposing (Rule, RuleMsg(..))


update : RuleMsg -> Rule -> Rule
update msg rule =
    case msg of
        UpdateCard card msg ->
            rule
