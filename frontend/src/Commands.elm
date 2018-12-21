module Commands exposing (focusID, focusResetBtn, focusTextInput, getWords, startGame, stopTimer)

import Browser.Dom as Dom
import Http
import Msgs exposing (Msg)
import Task
import Time
import Url.Builder exposing (crossOrigin, string)


getWords : String -> Cmd Msg
getWords source =
    let
        url =
            crossOrigin
                "http://localhost:5000"
                [ "words", "generate" ]
                [ string "source" source ]
    in
    Http.get
        { url = url
        , expect = Http.expectString Msgs.GotWords
        }


focusID : String -> Cmd Msg
focusID id =
    Task.attempt (\_ -> Msgs.NoOp) (Dom.focus id)


focusResetBtn : Cmd Msg
focusResetBtn =
    focusID "resetButton"


focusTextInput : Cmd Msg
focusTextInput =
    focusID "textInput"


startGame : Cmd Msg
startGame =
    Time.now
        |> Task.perform Msgs.StartGame


stopTimer : Cmd Msg
stopTimer =
    Time.now
        |> Task.perform Msgs.StopTimer
