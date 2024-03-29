module Decoder.UpdateState exposing (decoder)

import Card.Types exposing (Card, CardType(..), CardState(..), CardId)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (required, decode, hardcoded, custom)
import Maybe.Extra exposing (orElse)
import Model
import Types exposing (ModelUpdater, Model)


type alias Versioned a =
    { a | version : Int }


decoder : Decoder (List ModelUpdater)
decoder =
    field "state" state


state : Decoder (List ModelUpdater)
state =
    allCards |> andThen (updates >> succeed)


allCards : Decoder (List Card)
allCards =
    field "story_card" story
        |> map2 (++) (field "questions" questions)
        |> map2 (++) (field "rules" rules)


updates : List Card -> List ModelUpdater
updates cards =
    List.map replaceCard cards ++ [ cleanUpAction cards ]


cleanUpAction : List Card -> ModelUpdater
cleanUpAction =
    List.map .id >> Model.cleanUp


story : Decoder (List Card)
story =
    card StoryCard |> map (\x -> [ x ])


questions : Decoder (List Card)
questions =
    card QuestionCard |> list


rules : Decoder (List Card)
rules =
    list rule |> map List.concat


rule : Decoder (List Card)
rule =
    field "rule_card" (card RuleCard)
        |> andThen (\card -> map2 (::) (succeed card) (examples card))


examples : Card -> Decoder (List Card)
examples ruleCard =
    field "examples" (list (card (ExampleCard ruleCard.id.uid)))


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


replaceCard : Card -> ModelUpdater
replaceCard card =
    Model.addOrUpdateCard card.id (replaceWithIfNewer card)


replaceWithIfNewer : Card -> Maybe Card -> Maybe Card
replaceWithIfNewer newCard oldCard =
    Maybe.map (mostRecent newCard) oldCard |> orElse (Just newCard)


mostRecent : Card -> Card -> Card
mostRecent new old =
    if new |> isNewerThan old then
        new
    else
        old


isNewerThan : Versioned a -> Versioned a -> Bool
isNewerThan old new =
    new.version > old.version
