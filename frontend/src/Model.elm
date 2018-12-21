module Model exposing (KeyComparison, Model, Status(..), TestResult, Words(..), initialModel)

import Browser.Navigation as Nav
import Routing exposing (Route)
import Time
import Url


type alias KeyComparison =
    { typed : Char, target : Char, correct : Bool }


type alias TestResult =
    { wpm : Float
    , worstKeys : List ( Char, Int )
    , accuracy : Float
    , totalTime : Int
    }


type alias Game =
    { words : List Char
    , startTime : Time.Posix
    , currentWPM : Float
    }


type Words
    = Failure
    | Loading
    | Success (List Char)


type Status
    = NotStarted
    | InProgress Game
    | Finished TestResult


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , words : Words
    , typed : List Char
    , route : Route
    , source : String
    , status : Status
    , zone : Time.Zone
    , showSettings : Bool
    }


initialModel : Url.Url -> Nav.Key -> Route -> Model
initialModel url key route =
    { key = key
    , url = url
    , words = Loading
    , typed = []
    , route = route
    , source = "shakespeare"
    , status = NotStarted
    , zone = Time.utc
    , showSettings = False
    }
