module StateDecoder exposing (modelDecoder)

import Dict exposing (Dict)
import Json.Decode exposing (..)
import Types
    exposing
        ( Model
        , Card
        , CardId
        , Rule
        , CardState(..)
        , AddButtonState(..)
        , Flags
        )


modelDecoder : Flags -> Decoder Model
modelDecoder flags =
    field "state" <|
        map7 Model
            (maybe <| field "story_card" card)
            (field "rules" <| rules)
            (field "questions" <| dict card)
            (succeed Nothing)
            (succeed flags)
            (succeed Button)
            (succeed Button)


rules : Decoder (Dict CardId Rule)
rules =
    map Dict.fromList rulePairs


rulePairs : Decoder (List ( CardId, Rule ))
rulePairs =
    map (List.map rulePair) (list rule)


rulePair : Rule -> ( CardId, Rule )
rulePair rule =
    ( rule.card.id, rule )


rule : Decoder Rule
rule =
    map4 Rule
        (field "rule_card" card)
        (field "position" int)
        (field "examples" <| dict card)
        (succeed Button)


card : Decoder Card
card =
    map3 Card
        (field "id" string)
        (field "state" cardState)
        (field "text" string)


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
