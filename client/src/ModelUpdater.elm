module ModelUpdater
    exposing
        ( replaceCard
        , replaceExampleCard
        , replaceQuestionCard
        , replaceRuleCard
        , replaceStoryCard
        )

import Card.Types exposing (Card, CardType(..), CardState(..))
import Dict
import Rule.Types exposing (RuleId)
import Types exposing (Model)


replaceCard : Card -> Model -> Model
replaceCard card =
    case card.cardType of
        StoryCard ->
            replaceStoryCard card

        RuleCard ->
            replaceRuleCard card

        ExampleCard ruleId ->
            replaceExampleCard ruleId card

        QuestionCard ->
            replaceQuestionCard card


replaceStoryCard : Card -> Model -> Model
replaceStoryCard card model =
    { model | storyCard = Just card }


replaceQuestionCard : Card -> Model -> Model
replaceQuestionCard card model =
    { model | questions = Dict.update card.id (always <| Just card) model.questions }


replaceRuleCard : Card -> Model -> Model
replaceRuleCard card model =
    let
        updateRule =
            \update ->
                { model | rules = Dict.update card.id update model.rules }

        updateCard =
            \rule ->
                { rule | card = card }

        updateWithDefault =
            \default update ->
                Maybe.map update >> Maybe.withDefault default >> Just

        newRule =
            { card = card, examples = Dict.singleton ("new-example-" ++ card.id) (addExampleButton card.id) }
    in
        updateRule <| updateWithDefault newRule updateCard


replaceExampleCard : RuleId -> Card -> Model -> Model
replaceExampleCard ruleId card model =
    let
        updateExample =
            \rule ->
                { rule | examples = Dict.update card.id (always <| Just card) rule.examples }
    in
        { model | rules = Dict.update ruleId (Maybe.map updateExample) model.rules }


addExampleButton : RuleId -> Card
addExampleButton ruleId =
    { id = "new-example-" ++ ruleId
    , state = AddButton
    , text = ""
    , cardType = ExampleCard ruleId
    , position = 999
    }
