module Main exposing (init, main)

import Browser
import Browser.Navigation as Nav
import Commands exposing (getWords)
import Model exposing (Model, initialModel)
import Msgs exposing (Msg)
import Routing exposing (toRoute)
import Subs exposing (subscriptions)
import Update exposing (update)
import Url
import View exposing (view)



{--

[TODO] 

# V1

- Fix text refocus issues
- Get the time when the game begins, get the time when the game ends, set that
to the final time
- Calculate Gross WPM using https://www.speedtypingonline.com/typing-equations
- Implement UI for selecting input
- Deploy

# V2 
- User accounts
- Leaderboards (gross WPM for dictionary)
- Graphs / progress over time
- Track most mistakes etc. etc.

# V3
- Lessons?

--}


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            toRoute (Url.toString url)

        model =
            initialModel url key route
    in
    ( model, getWords model.source )


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = Msgs.UrlChanged
        , onUrlRequest = Msgs.LinkClicked
        }
