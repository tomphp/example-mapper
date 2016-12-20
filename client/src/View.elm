module View exposing (view)

import Dict
import Types exposing (Model, Msg(..), Card, Rule, CardState(..), CardId)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import CardView exposing (card, CardType(..))


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Example Mapper" ]
        , p [] [ text <| Maybe.withDefault "" model.error ]
        , card StoryCard <| theCard model model.storyCard
        , rules model
        , questions model
        ]


rules : Model -> Html Msg
rules model =
    div [ class "rules" ] <|
        List.append
            (List.indexedMap (rule model) model.rules)
            [ button [ onClick AddRule, class "add-button" ] [ text "Add Rule" ]
            , div [ class "rule-padding" ] []
            ]


cardList : Model -> List CardId -> List Card
cardList model ids =
    ids
        |> List.map (\id -> Dict.get id model.cards)
        |> List.filterMap identity


theCard : Model -> CardId -> Card
theCard model id =
    Dict.get id model.cards
        |> Maybe.withDefault { id = "error", text = "[error]", state = Saved }


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
                , [ button [ onClick AddQuestion, class "add-button" ] [ text "Add Question" ] ]
                ]
            )


rule : Model -> Int -> Rule -> Html Msg
rule model id r =
    div [ class "rule" ]
        [ card RuleCard <| theCard model r.ruleCard
        , examples id <| cardList model r.examples
        ]


examples : Int -> List Card -> Html Msg
examples ruleId es =
    div [ class "examples" ]
        (List.append
            (List.map example es)
            [ button
                [ onClick (AddExample ruleId), class "add-button" ]
                [ text "Add Example" ]
            ]
        )


example : Card -> Html Msg
example e =
    div [] [ card ExampleCard e ]


question : Card -> Html Msg
question q =
    div [ class "colum" ] [ card QuestionCard q ]
