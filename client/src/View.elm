module View exposing (view)

import Dict exposing (Dict)
import Types
    exposing
        ( Model
        , Msg(..)
        , Card
        , Rule
        , CardState(..)
        , CardId
        , AddButtonState(..)
        , CardType(..)
        )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import View.Card exposing (card)


type alias AddButton =
    { state : AddButtonState
    , action : Msg
    , id : CardId
    , cssClass : String
    , label : String
    , cardType : CardType
    }


addButtonParams : Model -> CardType -> Maybe AddButton
addButtonParams model t =
    case t of
        NewRuleCard ->
            Just
                { state = model.addRule
                , action = AddRule
                , id = "new-rule"
                , cssClass = "card--rule"
                , label = "Add Rule"
                , cardType = t
                }

        NewExampleCard ruleId ->
            Just
                { state = Dict.get ruleId model.rules |> Maybe.map .addExample |> Maybe.withDefault Button
                , action = AddExample ruleId
                , id = "new-example"
                , cssClass = "card--example"
                , label = "Add Example"
                , cardType = t
                }

        NewQuestionCard ->
            Just
                { state = model.addQuestion
                , action = AddQuestion
                , id = "new-question"
                , cssClass = "card--question"
                , label = "Add Question"
                , cardType = t
                }

        _ ->
            Nothing


displayButton : AddButton -> Html Msg
displayButton b =
    case b.state of
        Preparing ->
            card
                b.cardType
                { id = b.id
                , state = Editing
                , text = ""
                }

        _ ->
            button [ onClick b.action, class ("card " ++ b.cssClass) ] [ text b.label ]


addButton : Model -> CardType -> Html Msg
addButton model =
    addButtonParams model
        >> Maybe.map displayButton
        >> Maybe.withDefault (text "Error")


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ p [] [ text <| Maybe.withDefault "" model.error ]
        , model.storyCard
            |> Maybe.map (card StoryCard)
            |> Maybe.withDefault (text "Error")
        , rules model
        , questions model
        ]


rules : Model -> Html Msg
rules model =
    div [ class "rules" ] <|
        List.append
            (List.map (rule model) (Dict.values model.rules |> List.sortBy .position))
            [ div [] [ addButton model NewRuleCard ]
            , div [] [ div [ class "rule-padding" ] [] ]
            ]


theCard : Dict CardId Card -> CardId -> Maybe Card
theCard cards id =
    Dict.get id cards



-- |> Maybe.withDefault
--     { id = "error" ++ id
--     , text = "Loading..."
--     , state = Saving
--     }


questions : Model -> Html Msg
questions model =
    div [ class "questions" ]
        (List.concat
            [ [ h2 [] [ text "Questions" ] ]
            , Dict.values model.questions |> List.map question
            , [ addButton model NewQuestionCard ]
            ]
        )


rule : Model -> Rule -> Html Msg
rule model r =
    div [ class "rule" ]
        [ card RuleCard r.card
        , examples model r (Dict.values r.examples)
        ]


examples : Model -> Rule -> List Card -> Html Msg
examples model rule es =
    div [ class "examples" ]
        (List.append
            (List.map (example rule.card.id) es)
            [ addButton model (NewExampleCard rule.card.id) ]
        )


example : CardId -> Card -> Html Msg
example ruleId e =
    div [] [ card (ExampleCard ruleId) e ]


question : Card -> Html Msg
question q =
    div [ class "colum" ] [ card QuestionCard q ]
