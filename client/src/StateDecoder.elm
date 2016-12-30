module StateDecoder exposing (modelDecoder)

import Dict exposing (Dict)
import Json.Decode exposing (..)
import Types
    exposing
        ( Model
        , Card
        , CardId
        , RuleId
        , Rule
        , CardState(..)
        , AddButtonState(..)
        , Flags
        , CardType(..)
        )


modelDecoder : Flags -> Decoder Model
modelDecoder flags =
    field "state" <|
        map7 Model
            (maybe <| field "story_card" (card StoryCard))
            (field "rules" <| rules)
            (field "questions" <| map (dictKeyedBy .id) <| list (card QuestionCard))
            (succeed Nothing)
            (succeed flags)
            (succeed Button)
            (succeed Button)


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
    map4 Rule
        (field "rule_card" (card RuleCard))
        (field "position" int)
        (field "examples" <|
            map (dictKeyedBy .id) <|
                list <|
                    card <|
                        ExampleCard ruleId
        )
        (succeed Button)


exampleCard : Decoder Card
exampleCard =
    andThen card exampleCardType


exampleCardType : Decoder CardType
exampleCardType =
    map ExampleCard (at [ "rule_card", "id" ] string)


card : CardType -> Decoder Card
card cardType =
    map4 Card
        (field "id" string)
        (field "state" cardState)
        (field "text" string)
        (succeed cardType)


cardState : Decoder CardState
cardState =
    map stringToCardState string


stringToCardState : String -> CardState
stringToCardState s =
    case s of
        "editing" ->
            Editing

        "locked" ->
            Locked

        "saving" ->
            Saving

        _ ->
            Saved
