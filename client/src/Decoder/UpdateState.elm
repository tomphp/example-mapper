module Decoder.UpdateState exposing (decoder)

import Card.Types exposing (Card, CardType(..), CardState(..), CardId)
import Types exposing (ModelUpdater, Model)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (required, decode, hardcoded, custom)
import Model
import Maybe.Extra exposing (orElse)


decoder : Decoder (List ModelUpdater)
decoder =
    field "state" state


state : Decoder (List ModelUpdater)
state =
    field "story_card" story
        |> map2 (++) (field "questions" questions)
        |> map2 (++) (field "rules" rules)


story : Decoder (List ModelUpdater)
story =
    card StoryCard
        |> map replaceCard
        |> map (\x -> [ x ])


replaceCard : Card -> ModelUpdater
replaceCard card =
    Model.updateCard card.id (replaceWithIfNewer card)


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
        |> map replaceCard
        |> list


rules : Decoder (List ModelUpdater)
rules =
    rule
        |> list
        |> map List.concat


rule : Decoder (List ModelUpdater)
rule =
    let
        ruleCard =
            field "rule_card" (card RuleCard)
    in
        map2 (::)
            (ruleCard |> map replaceCard)
            (ruleCard |> andThen examples)


examples : Card -> Decoder (List ModelUpdater)
examples ruleCard =
    card (ExampleCard ruleCard.id.uid)
        |> map replaceCard
        |> list
        |> field "examples"


card : CardType -> Decoder Card
card cardType =
    decode Card
        |> custom (cardId cardType)
        |> required "state" cardState
        |> required "text" string
        |> required "position" int
        |> required "version" int


cardId : CardType -> Decoder CardId
cardId cardType =
    decode CardId
        |> required "id" string
        |> hardcoded cardType


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
