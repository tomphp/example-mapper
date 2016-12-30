module Types
    exposing
        ( Model
        , Msg(..)
        , CardState(..)
        , AddButtonState(..)
        , Card
        , Rule
        , RuleId
        , CardId
        , CardType(..)
        , Flags
        )

import Dict exposing (Dict)


type CardType
    = StoryCard
    | RuleCard
    | ExampleCard RuleId
    | QuestionCard
    | NewRuleCard
    | NewExampleCard RuleId
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


type alias RuleId =
    CardId


type alias Card =
    { id : CardId
    , state : CardState
    , text : String
    , cardType : CardType
    }


type alias Rule =
    { card : Card
    , position : Int
    , examples : Dict CardId Card
    , addExample : AddButtonState
    }


type alias Model =
    { storyCard : Maybe Card
    , rules : Dict CardId Rule
    , questions : Dict CardId Card
    , error : Maybe String
    , flags : Flags
    , addRule : AddButtonState
    , addQuestion : AddButtonState
    }


type Msg
    = GetUpdate
    | Noop
    | UpdateModel String
    | EditCard CardType CardId
    | SaveCard CardType CardId String
    | AddQuestion
    | AddRule
    | AddExample String
    | SendNewQuestion String
    | SendNewRule String
    | SendNewExample String String
