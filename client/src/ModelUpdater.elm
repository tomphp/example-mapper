module ModelUpdater
    exposing
        ( addDelayedAction
        , incrementLastRequestNo
        , updateStoryCard
        , updateQuestionCard
        , updateRule
        , updateCard
        , setClientId
        )

import Card.State exposing (addCardButton)
import Card.Types exposing (Card, CardType(..), CardId)
import Dict
import Rule.Types exposing (RuleId, Rule)
import Types exposing (Model, ModelUpdater, DelayedAction)
import Maybe.Extra exposing (orElse)


incrementLastRequestNo : Model -> Model
incrementLastRequestNo model =
    { model | lastRequestNo = model.lastRequestNo + 1 }


addDelayedAction : DelayedAction -> Model -> Model
addDelayedAction action model =
    { model | delayed = Dict.insert model.lastRequestNo action model.delayed }


setClientId : String -> Model -> Model
setClientId id model =
    { model | clientId = Just id }


updateCard : CardId -> (Maybe Card -> Maybe Card) -> Model -> Model
updateCard id =
    case id.cardType of
        StoryCard ->
            updateStoryCard

        RuleCard ->
            updateRuleCard id.uid

        ExampleCard ruleId ->
            updateExampleCard ruleId id.uid

        QuestionCard ->
            updateQuestionCard id.uid


updateStoryCard : (Maybe Card -> Maybe Card) -> Model -> Model
updateStoryCard update model =
    { model | storyCard = update model.storyCard }


updateQuestionCard : String -> (Maybe Card -> Maybe Card) -> Model -> Model
updateQuestionCard id update model =
    { model | questions = Dict.update id update model.questions }


updateRuleCard : RuleId -> (Maybe Card -> Maybe Card) -> Model -> Model
updateRuleCard id update =
    let
        addExampleButton =
            addCardButton (ExampleCard id)

        examples =
            Dict.singleton addExampleButton.id.uid addExampleButton

        updateCardInRule =
            \u r -> { r | card = u (Just r.card) |> Maybe.withDefault r.card }

        ruleFromNothing =
            update Nothing |> Maybe.map (\c -> { card = c, examples = examples })
    in
        updateRule id
            (Maybe.map (updateCardInRule update) >> orElse ruleFromNothing)


updateExampleCard : RuleId -> String -> (Maybe Card -> Maybe Card) -> Model -> Model
updateExampleCard ruleId id update =
    updateRule ruleId (Maybe.map (\r -> { r | examples = Dict.update id update r.examples }))


updateRule : RuleId -> (Maybe Rule -> Maybe Rule) -> Model -> Model
updateRule id update model =
    { model | rules = Dict.update id update model.rules }
