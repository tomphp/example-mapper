module Decoder.UpdateState exposing (decoder)

import Card.Types exposing (Card, CardType(..), CardState(..))
import Types exposing (ModelUpdater, Model)
import Json.Decode exposing (..)
import ModelUpdater exposing (..)
import Maybe.Extra exposing (orElse)


decoder : Decoder (List ModelUpdater)
decoder =
    field "state" <|
        (story |> map2 (++) questions |> map2 (++) rules)


story : Decoder (List ModelUpdater)
story =
    card StoryCard
        |> map (replaceWithIfNewer >> updateStoryCard)
        |> map (\x -> [ x ])
        |> field "story_card"


replaceWithIfNewer : Card -> Maybe Card -> Maybe Card
replaceWithIfNewer newCard oldCard =
    let
        isNewerThan =
            \old new -> new.version > old.version

        mostRecent =
            \new old ->
                if new |> isNewerThan old then
                    new
                else
                    old
    in
        Maybe.map (mostRecent newCard) oldCard |> orElse (Just newCard)


questions : Decoder (List ModelUpdater)
questions =
    card QuestionCard
        |> map (\c -> updateQuestionCard c.id (replaceWithIfNewer c))
        |> list
        |> field "questions"


rules : Decoder (List ModelUpdater)
rules =
    rule
        |> list
        |> map List.concat
        |> field "rules"


rule : Decoder (List ModelUpdater)
rule =
    let
        ruleCard =
            card RuleCard |> field "rule_card"
    in
        map2 (::)
            (ruleCard |> map (\c -> updateRuleCard c.id (replaceWithIfNewer c)))
            (ruleCard |> andThen examples)


examples : Card -> Decoder (List ModelUpdater)
examples ruleCard =
    card (ExampleCard ruleCard.id)
        |> map (\c -> updateExampleCard ruleCard.id c.id (replaceWithIfNewer c))
        |> list
        |> field "examples"


card : CardType -> Decoder Card
card cardType =
    map6 Card
        (field "id" string)
        (field "state" cardState)
        (field "text" string)
        (succeed cardType)
        (field "position" int)
        (field "version" int)


cardState : Decoder CardState
cardState =
    map toCardState string


toCardState : String -> CardState
toCardState s =
    case s of
        "saving" ->
            Saving

        _ ->
            Saved
