module Types
    exposing
        ( Model
        , Msg(..)
        , CardState(..)
        , AddButtonState(..)
        , Card
        , Rule
        , CardId
        , CardType(..)
        , Flags
        )

import Dict exposing (Dict)


type CardType
    = StoryCard
    | RuleCard
    | ExampleCard
    | QuestionCard
    | NewRuleCard
    | NewExampleCard String
    | NewQuestionCard


type CardState
    = Editing
    | Locked
    | Saving
    | Saved


type AddButtonState
    = Button
    | Preparing
    | Sending


type alias Flags =
    { backendUrl : String }


type alias CardId =
    String


type alias Card =
    { id : CardId
    , state : CardState
    , text : String
    }


type alias Rule =
    { ruleCard : CardId
    , position : Int
    , examples : List CardId
    , addExample : AddButtonState
    }


type alias Model =
    { cards : Dict CardId Card
    , storyId : CardId
    , rules : Dict CardId Rule
    , questions : List CardId
    , error : Maybe String
    , flags : Flags
    , addRule : AddButtonState
    , addQuestion : AddButtonState
    }


type Msg
    = GetUpdate
    | Noop
    | UpdateModel String
    | EditCard String
    | SaveCard CardId String
    | AddQuestion
    | AddRule
    | AddExample String
    | SendNewQuestion String
    | SendNewRule String
    | SendNewExample String String
