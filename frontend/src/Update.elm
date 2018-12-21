module Update exposing (update)

import Browser
import Browser.Navigation as Nav
import Commands exposing (focusID, focusResetBtn, focusTextInput, getWords, startGame, stopTimer)
import Model exposing (Model, Status(..), TestResult, Words(..), initialModel)
import Msgs exposing (Msg)
import Routing exposing (toRoute)
import Time
import Url
import Utils exposing (countMisstyped)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.UpdateSource source ->
            ( { model | source = source }, getWords source )

        Msgs.ToggleViewSettings ->
            ( { model | showSettings = not model.showSettings }, Cmd.none )

        Msgs.VisibilityChange visibility ->
            ( model, Cmd.none )

        Msgs.GotWords result ->
            case result of
                Ok fullText ->
                    ( { model | words = Success (String.toList fullText) }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        Msgs.LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        Msgs.UrlChanged url ->
            ( { model | url = url, route = toRoute (Url.toString url) }
            , Cmd.none
            )

        Msgs.StartGame time ->
            case model.words of
                Success words ->
                    let
                        game =
                            { words = words, startTime = time, currentWPM = 0 }
                    in
                    ( { model | status = InProgress game }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Msgs.StopTimer endTime ->
            case model.status of
                InProgress game ->
                    let
                        wordCount =
                            List.length (String.split " " (String.fromList game.words))

                        missTyped =
                            countMisstyped model.typed game.words

                        totalTime =
                            Time.posixToMillis endTime - Time.posixToMillis game.startTime

                        inMinutes =
                            toFloat totalTime / 60000

                        wpm =
                            toFloat wordCount / inMinutes

                        result =
                            { wpm = wpm
                            , worstKeys = missTyped
                            , accuracy = 0.1
                            , totalTime = totalTime
                            }

                        newModel =
                            { model | status = Finished result }
                    in
                    ( newModel, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Msgs.UpdateTyped input ->
            let
                typedCharacters =
                    String.toList input
            in
            case model.status of
                Finished _ ->
                    ( model, Cmd.none )

                NotStarted ->
                    ( { model | typed = typedCharacters }, startGame )

                InProgress game ->
                    if List.length game.words == List.length typedCharacters then
                        ( { model | typed = typedCharacters }, stopTimer )

                    else
                        ( { model | typed = typedCharacters }, Cmd.none )

        Msgs.Tick time ->
            case model.status of
                InProgress game ->
                    let
                        wordCount =
                            List.length (String.split " " (String.fromList model.typed))

                        elapsedTime =
                            Time.posixToMillis time - Time.posixToMillis game.startTime

                        inMinutes =
                            toFloat elapsedTime / 60000

                        wpm =
                            toFloat wordCount / inMinutes
                    in
                    ( { model | status = InProgress { game | currentWPM = wpm } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Msgs.FocusInput ->
            ( model, focusTextInput )

        Msgs.Reset ->
            let
                newModel =
                    initialModel model.url model.key model.route
            in
            -- Prevents the screen from flashing with loading placeholder for slow requests
            ( { newModel | words = model.words, source = model.source }, Cmd.batch [ focusTextInput, getWords model.source ] )

        _ ->
            ( model, Cmd.none )
