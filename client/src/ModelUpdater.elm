module ModelUpdater
    exposing
        ( addDelayedAction
        , updateStoryCard
        , updateQuestionCard
        , updateRuleCard
        , updateExampleCard
        , replaceRule
        , replaceCard
        , replaceExampleCard
        , replaceQuestionCard
        , replaceRuleCard
        , replaceStoryCard
        , setClientId
        )

import Card.State exposing (addCardButton)
import Card.Types exposing (Card, CardType(..), CardState(..), CardId)
import Dict
import Rule.Types exposing (RuleId, Rule)
import Types exposing (Model, ModelUpdater, DelayedAction)


addDelayedAction : DelayedAction -> Model -> Model
addDelayedAction action model =
    { model | delayed = Dict.insert model.lastRequestNo action model.delayed }


setClientId : String -> Model -> Model
setClientId id model =
    { model | clientId = Just id }


replaceRule : Model -> Rule -> Model
replaceRule model rule =
    updateRule (Just rule |> always) rule.card.id model


replaceCard : Model -> Card -> Model
replaceCard model card =
    case card.cardType of
        StoryCard ->
            replaceStoryCard card model

        RuleCard ->
            replaceRuleCard card model

        ExampleCard ruleId ->
            replaceExampleCard ruleId card model

        QuestionCard ->
            replaceQuestionCard card model


updateStoryCard : (Maybe Card -> Maybe Card) -> Model -> Model
updateStoryCard update model =
    { model | storyCard = update model.storyCard }


updateQuestionCard : CardId -> (Maybe Card -> Maybe Card) -> Model -> Model
updateQuestionCard id update model =
    { model | questions = Dict.update id update model.questions }


updateRuleCard : RuleId -> (Maybe Card -> Maybe Card) -> Model -> Model
updateRuleCard id update model =
    updateRule (Maybe.map (\r -> { r | card = Maybe.withDefault r.card (update (Just r.card)) })) id model


updateExampleCard : RuleId -> CardId -> (Maybe Card -> Maybe Card) -> Model -> Model
updateExampleCard ruleId id update model =
    updateRule (Maybe.map (\r -> { r | examples = Dict.update id update r.examples })) ruleId model


replaceStoryCard : Card -> Model -> Model
replaceStoryCard card model =
    { model | storyCard = Just card }


replaceQuestionCard : Card -> Model -> Model
replaceQuestionCard card model =
    { model | questions = Dict.update card.id (always <| Just card) model.questions }


replaceRuleCard : Card -> Model -> Model
replaceRuleCard card model =
    let
        updateCard =
            \rule ->
                { rule | card = card }

        addExampleButton =
            addCardButton (ExampleCard card.id)

        newRule =
            { card = card
            , examples = Dict.singleton addExampleButton.id addExampleButton
            }
    in
        updateRule (mapWithDefault newRule updateCard) card.id model


replaceExampleCard : RuleId -> Card -> Model -> Model
replaceExampleCard ruleId card model =
    let
        updateExample =
            \rule ->
                { rule | examples = Dict.update card.id (always <| Just card) rule.examples }
    in
        updateRule (Maybe.map updateExample) ruleId model


updateRule : (Maybe Rule -> Maybe Rule) -> RuleId -> Model -> Model
updateRule update id model =
    { model | rules = Dict.update id update model.rules }


mapWithDefault : a -> (b -> a) -> Maybe b -> Maybe a
mapWithDefault default update =
    Maybe.map update >> Maybe.withDefault default >> Just
