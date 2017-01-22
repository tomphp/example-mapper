module Decoder.UpdateState exposing (decoder)

import Card.Types exposing (Card, CardType(..), CardState(..))
import Types exposing (ModelUpdater)
import Json.Decode exposing (..)
import ModelUpdater exposing (..)


decoder : Decoder (List ModelUpdater)
decoder =
    field "state" <|
        (story
            |> map2 (++) questions
            |> map2 (++) rules
        )


story : Decoder (List ModelUpdater)
story =
    card StoryCard
        |> map replaceStoryCard
        |> map (\x -> [ x ])
        |> field "story_card"


questions : Decoder (List ModelUpdater)
questions =
    card QuestionCard
        |> map replaceQuestionCard
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
            (ruleCard |> map replaceRuleCard)
            (ruleCard |> andThen examples)


examples : Card -> Decoder (List ModelUpdater)
examples ruleCard =
    card (ExampleCard ruleCard.id)
        |> map (replaceExampleCard ruleCard.id)
        |> list
        |> field "examples"


card : CardType -> Decoder Card
card cardType =
    map5 Card
        (field "id" string)
        (field "state" cardState)
        (field "text" string)
        (succeed cardType)
        (field "position" int)


cardState : Decoder CardState
cardState =
    map stringToCardState string


stringToCardState : String -> CardState
stringToCardState s =
    case s of
        "saving" ->
            Saving

        _ ->
            Saved
