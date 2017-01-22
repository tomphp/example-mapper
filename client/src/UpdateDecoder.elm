module UpdateDecoder exposing (modelDecoder)

import Card.Types exposing (Card, CardType(..), CardState(..))
import Json.Decode exposing (..)
import Types exposing (Model, Flags)
import ModelUpdater exposing (..)


modelDecoder : Flags -> Decoder (List (Model -> Model))
modelDecoder flags =
    field "state" <|
        (story
            |> map2 (++) questions
            |> map2 (++) rules
        )


story : Decoder (List (Model -> Model))
story =
    card StoryCard
        |> map replaceStoryCard
        |> map (\x -> [ x ])
        |> field "story_card"


questions : Decoder (List (Model -> Model))
questions =
    card QuestionCard
        |> map replaceQuestionCard
        |> list
        |> field "questions"


rules : Decoder (List (Model -> Model))
rules =
    rule
        |> list
        |> map List.concat
        |> field "rules"


rule : Decoder (List (Model -> Model))
rule =
    let
        ruleCard =
            card RuleCard |> field "rule_card"
    in
        map2 (::)
            (ruleCard |> map replaceRuleCard)
            (ruleCard |> andThen examples)


examples : Card -> Decoder (List (Model -> Model))
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
