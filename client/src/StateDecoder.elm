module StateDecoder exposing (modelDecoder)

import Card.Types exposing (Card, CardState(..), CardType(..), CardId)
import Dict exposing (Dict)
import Json.Decode exposing (..)
import Rule.Types exposing (RuleId, Rule)
import Types exposing (Model, Flags)


modelDecoder : Flags -> Decoder Model
modelDecoder flags =
    field "state" <|
        map5 Model
            (maybe <| field "story_card" (card StoryCard))
            (field "rules" <| rules)
            (field "questions" <| map (dictKeyedBy .id) <| list (card QuestionCard))
            (succeed Nothing)
            (succeed flags)


rules : Decoder (Dict CardId Rule)
rules =
    map (dictKeyedBy (.card >> .id)) (list rule)


dictKeyedBy : (a -> comparable) -> List a -> Dict comparable a
dictKeyedBy f =
    List.map (\x -> ( f x, x )) >> Dict.fromList


rule : Decoder Rule
rule =
    (at [ "rule_card", "id" ] string)
        |> andThen ruleWithId


ruleWithId : RuleId -> Decoder Rule
ruleWithId ruleId =
    map2 Rule
        (field "rule_card" (card RuleCard))
        (field "examples" <|
            map (dictKeyedBy .id) <|
                list <|
                    card <|
                        ExampleCard ruleId
        )


exampleCard : Decoder Card
exampleCard =
    andThen card exampleCardType


exampleCardType : Decoder CardType
exampleCardType =
    map ExampleCard (at [ "rule_card", "id" ] string)


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
