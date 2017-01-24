module Decoder.UpdateState exposing (decoder)

import Card.State exposing (addCardButton)
import Card.Types exposing (Card, CardType(..), CardState(..))
import Dict
import Types exposing (ModelUpdater, Model)
import Json.Decode exposing (..)
import ModelUpdater exposing (..)


decoder : Decoder (List ModelUpdater)
decoder =
    field "state" <|
        (story |> map2 (++) questions |> map2 (++) rules)


story : Decoder (List ModelUpdater)
story =
    card StoryCard
        |> map (updateIfNewer >> updateStoryCard)
        |> map (\x -> [ x ])
        |> field "story_card"


updateIfNewer : Card -> Maybe Card -> Maybe Card
updateIfNewer newCard oc =
    case oc of
        Just oldCard ->
            if newCard.version > oldCard.version then
                Just newCard
            else
                Just oldCard

        Nothing ->
            Just newCard


ensureRuleExists : Card -> Model -> Model
ensureRuleExists card model =
    let
        addExampleButton =
            addCardButton (ExampleCard card.id)

        newRule =
            { card = card
            , examples = Dict.singleton addExampleButton.id addExampleButton
            }
    in
        { model
            | rules =
                Dict.update
                    card.id
                    (Maybe.withDefault newRule >> Just)
                    model.rules
        }


questions : Decoder (List ModelUpdater)
questions =
    card QuestionCard
        |> map (\c -> updateIfNewer c |> updateQuestionCard c.id)
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
            (ruleCard |> map (\c -> ensureRuleExists c >> updateRuleCard c.id (updateIfNewer c)))
            (ruleCard |> andThen examples)


examples : Card -> Decoder (List ModelUpdater)
examples ruleCard =
    card (ExampleCard ruleCard.id)
        |> map (\c -> updateIfNewer c |> updateExampleCard ruleCard.id c.id)
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
    map stringToCardState string


stringToCardState : String -> CardState
stringToCardState s =
    case s of
        "saving" ->
            Saving

        _ ->
            Saved
