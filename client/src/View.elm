module View exposing (view)

import Types exposing (Model, Msg(..), Card, Rule, CardState(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import CardView exposing (card, CardType(..))


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Example Mapper" ]
        , card StoryCard Saved model.storyCard.text
        , rules model.rules
        , questions model.questions
        , button [ onClick GetUpdate ] [ text "Click Me" ]
        ]


rules : List Rule -> Html Msg
rules rs =
    div [ class "rules" ] <|
        List.append
            (List.map rule rs)
            [ button [ onClick GetUpdate, class "add-button" ] [ text "Add Rule" ] ]


questions : List Card -> Html Msg
questions qs =
    div [ class "questions" ]
        (List.concat
            [ [ h2 [] [ text "Questions" ] ]
            , (List.map question qs)
            , [ button [ onClick GetUpdate, class "add-button" ] [ text "Add Question" ] ]
            ]
        )


rule : Rule -> Html Msg
rule r =
    div [ class "rule" ]
        [ card RuleCard Saved r.ruleCard.text
        , examples r.examples
        ]


examples : List Card -> Html Msg
examples es =
    div [ class "examples" ]
        (List.append
            (List.map example es)
            [ button [ onClick GetUpdate, class "add-button" ] [ text "Add Example" ] ]
        )


example : Card -> Html Msg
example e =
    div [] [ card ExampleCard Saved e.text ]


question : Card -> Html Msg
question q =
    div [ class "colum" ] [ card QuestionCard Saved q.text ]
