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
    | ExampleCard CardId
    | QuestionCard
    | NewRuleCard
    | NewExampleCard CardId
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
    | EditStory CardId
    | SaveStory CardId String
    | EditRule CardId
    | SaveRule CardId String
    | EditExample CardId CardId
    | SaveExample CardId CardId String
    | EditQuestion CardId
    | SaveQuestion CardId String
    | AddQuestion
    | AddRule
    | AddExample String
    | SendNewQuestion String
    | SendNewRule String
    | SendNewExample String String
