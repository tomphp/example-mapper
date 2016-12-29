module View exposing (view)

import Dict
import Types exposing (Model, Msg(..), Card, Rule, CardState(..), CardId, AddButtonState(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import CardView exposing (card, CardType(..))


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ p [] [ text <| Maybe.withDefault "" model.error ]
        , card StoryCard <| theCard model model.storyCard
        , rules model
        , questions model
        ]


addButton : CardType -> AddButtonState -> Msg -> String -> String -> String -> Html Msg
addButton cardType state action id cssClass label =
    case state of
        Preparing ->
            card
                cardType
                { id = id
                , state = Editing
                , text = ""
                }

        _ ->
            button [ onClick action, class ("card " ++ cssClass) ] [ text label ]


rules : Model -> Html Msg
rules model =
    div [ class "rules" ] <|
        List.append
            (List.map (rule model) (Dict.values model.rules))
            [ div [] [ addButton NewRuleCard model.addRule AddRule "new-rule" "card--rule" "Add Rule" ]
            , div [] [ div [ class "rule-padding" ] [] ]
            ]


cardList : Model -> List CardId -> List Card
cardList model ids =
    ids
        |> List.map (\id -> Dict.get id model.cards)
        |> List.filterMap identity


theCard : Model -> CardId -> Card
theCard model id =
    Dict.get id model.cards
        |> Maybe.withDefault { id = "error", text = "Loading...", state = Saving }


questions : Model -> Html Msg
questions model =
    let
        cards =
            cardList model model.questions
    in
        div [ class "questions" ]
            (List.concat
                [ [ h2 [] [ text "Questions" ] ]
                , (List.map question cards)
                , [ addButton NewQuestionCard model.addQuestion AddQuestion "new-question" "card--question" "Add Question" ]
                ]
            )


rule : Model -> Rule -> Html Msg
rule model r =
    div [ class "rule" ]
        [ card RuleCard <| theCard model r.ruleCard
        , examples r <| cardList model r.examples
        ]


examples : Rule -> List Card -> Html Msg
examples rule es =
    div [ class "examples" ]
        (List.append
            (List.map example es)
            [ addButton
                (NewExampleCard rule.ruleCard)
                rule.addExample
                (AddExample rule.ruleCard)
                "new-example"
                "card--example"
                "Add Example"
            ]
        )


example : Card -> Html Msg
example e =
    div [] [ card ExampleCard e ]


question : Card -> Html Msg
question q =
    div [ class "colum" ] [ card QuestionCard q ]
