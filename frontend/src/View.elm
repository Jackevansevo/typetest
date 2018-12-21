module View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onFocus, onInput, onMouseEnter, onMouseOver, preventDefaultOn)
import Json.Decode as Json
import Model exposing (Model, Status(..), Words(..))
import Msgs exposing (Msg)
import Round
import Routing exposing (Route)
import Time
import Url
import Utils exposing (padList)


zip : List a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair xs ys


onPaste : msg -> Attribute msg
onPaste message =
    preventDefaultOn "paste" (Json.map alwaysPreventDefault (Json.succeed message))


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )


testProgress : Model -> Html Msg
testProgress model =
    let
        textContainer =
            div
                [ class "nes-container is-rounded feedback noselect"
                , style "margin-bottom" "2rem"
                ]
    in
    case model.words of
        Success words ->
            let
                targetLength =
                    List.length words

                typedIndex =
                    List.length model.typed

                diff =
                    zip words (padList model.typed ' ' targetLength)

                character ( index, ( target, typed ) ) =
                    if index == typedIndex then
                        -- The current character
                        span
                            [ style "border-bottom-style" "solid"
                            , style "border-bottom-width" "2px"
                            , style "border-bottom-color" "black"
                            ]
                            [ text (String.fromChar target) ]

                    else if index < typedIndex then
                        -- Characters already typed
                        if target == typed then
                            span [ style "color" "black" ] [ text (String.fromChar target) ]

                        else if target == ' ' then
                            span
                                [ style "border-bottom-style" "solid"
                                , style "border-bottom-width" "2px"
                                , style "border-bottom-color" "#e76e55"
                                ]
                                [ text (String.fromChar target) ]

                        else
                            span [ style "color" "#e76e55" ] [ text (String.fromChar target) ]

                    else
                        -- Untyped characters
                        span [ style "color" "lightgray" ] [ text (String.fromChar target) ]
            in
            textContainer (List.map character (List.indexedMap Tuple.pair diff))

        _ ->
            textContainer
                [ div [ class "loader" ]
                    [ span [ class "loader__dot" ] [ text "." ]
                    , span [ class "loader__dot" ] [ text "." ]
                    , span [ class "loader__dot" ] [ text "." ]
                    ]
                ]


displayCharacter c freq =
    let
        key =
            if c == ' ' then
                "space"

            else
                String.fromChar c
    in
    span
        [ class "nes-btn"
        , style "font-size" "80%"
        , style "margin-right" "1rem"
        , style "display" "block"
        ]
        [ text key ]


problematicKeys result =
    if List.isEmpty result.worstKeys then
        text ""

    else
        let
            topWorst =
                List.take 5 result.worstKeys

            showKey ( character, freq ) =
                div []
                    [ displayCharacter character freq ]
        in
        div [ style "padding-top" "2em" ]
            [ p [] [ text "Problematic Keys:" ]
            , div
                [ style "display" "flex"
                , style "flex" "row"
                ]
                (List.map showKey topWorst)
            ]


score : Model -> Html Msg
score model =
    case model.status of
        Finished result ->
            div [ style "padding-top" "1rem" ]
                [ text (Round.round 2 result.wpm ++ " WPM")
                , problematicKeys result
                ]

        _ ->
            text ""


progressBar : Model -> Html msg
progressBar model =
    case model.words of
        Success words ->
            let
                targetLength =
                    List.length words

                typedIndex =
                    List.length model.typed
            in
            progress
                [ class "nes-progress is-primary"
                , style "margin" "2rem 0"
                , style "height" "1.4rem"
                , value (String.fromInt typedIndex)
                , Html.Attributes.max (String.fromInt targetLength)
                ]
                []

        _ ->
            text ""


navbar =
    div
        [ class "nes-container with-title is-dark" ]
        [ h2 [ class "title" ] [ text "Menu" ]
        , div []
            [ ul
                [ style "color" "white"
                , style "list-style" "none"
                , style "margin" "0"
                , style "padding" "0"
                ]
                [ li [ style "display" "inline" ]
                    [ a
                        [ style "text-decoration" "none"
                        , style "color" "white"
                        , style "padding-right" "2em"
                        , href "/"
                        ]
                        [ text "Home" ]
                    ]
                , li [ style "display" "inline" ]
                    [ a
                        [ style "text-decoration" "none"
                        , style "color" "white"
                        , href "/about"
                        ]
                        [ text "About" ]
                    ]
                ]
            ]
        ]


wpmCount : Model -> Html Msg
wpmCount model =
    case model.status of
        InProgress game ->
            div [ class "wpmBar noselect" ] [ text (Round.round 2 game.currentWPM ++ " WPM") ]

        Finished result ->
            div [ class "wpmBar noselect" ] [ text (Round.round 2 result.wpm ++ " WPM") ]

        _ ->
            div
                [ style "display" "flex"
                , style "justify-content" "space-between"
                , style "align-items" "flex-end"
                ]
                [ span [] [ text "Start typing!" ]
                , button
                    [ class "nes-btn is-primary", onClick Msgs.ToggleViewSettings ]
                    [ text "Settings" ]
                ]


homeView : Model -> Html Msg
homeView model =
    let
        settings =
            if model.showSettings then
                div
                    [ style "position" "absolute"
                    , style "top" "200px"
                    , style "left" "0"
                    , style "right" "0"
                    , style "margin" "auto"
                    , style "display" "flex"
                    , style "justify-content" "center"
                    ]
                    [ div
                        [ class "nes-container with-title is-centered"
                        , style "height" "500px"
                        , style "width" "400px"
                        , style "z-index" "1"
                        , style "background" "white"
                        , style "position" "relative"
                        ]
                        [ i
                            [ class "nes-icon close is-small"
                            , style "position" "absolute"
                            , style "right" "20px"
                            , style "top" "20px"
                            , onClick Msgs.ToggleViewSettings
                            ]
                            []
                        , h2 [ class "title" ]
                            [ text "Settings" ]
                        , fieldset [ style "padding-top" "2rem" ]
                            [ div [ style "text-align" "left" ]
                                [ label [ style "display" "block", style "margin-bottom" "1.2rem" ]
                                    [ input
                                        [ class "nes-radio"
                                        , name "source"
                                        , type_ "radio"
                                        , onClick (Msgs.UpdateSource "trump")
                                        ]
                                        []
                                    , span []
                                        [ text "Trump" ]
                                    ]
                                , label [ style "display" "block", style "margin-bottom" "1.2rem" ]
                                    [ input
                                        [ class "nes-radio"
                                        , name "source"
                                        , type_ "radio"
                                        , onClick (Msgs.UpdateSource "shakespeare")
                                        ]
                                        []
                                    , span []
                                        [ text "Shakespeare" ]
                                    ]
                                , label [ style "display" "block", style "margin-bottom" "1.2rem" ]
                                    [ input
                                        [ class "nes-radio"
                                        , name "source"
                                        , type_ "radio"
                                        , onClick (Msgs.UpdateSource "random")
                                        ]
                                        []
                                    , span []
                                        [ text "Random" ]
                                    ]
                                ]
                            ]
                        ]
                    ]

            else
                text ""
    in
    div
        [ onMouseEnter Msgs.FocusInput
        , onClick Msgs.FocusInput
        ]
        [ navbar
        , div
            [ id "container" ]
            [ div []
                [ settings
                , wpmCount model
                , progressBar model
                , testProgress model
                , input
                    [ id "textInput"
                    , autofocus True
                    , onInput Msgs.UpdateTyped
                    , onPaste Msgs.NoOp
                    , value (String.fromList model.typed)
                    ]
                    []
                , button
                    [ id "resetButton"
                    , onClick Msgs.Reset
                    , class "nes-btn is-success"
                    ]
                    [ text "Reset" ]
                , score model
                ]
            ]
        ]


aboutView : Model -> Html Msg
aboutView model =
    div []
        [ navbar
        , div [ style "margin" "5rem" ]
            [ div [ class "nes-container with-title", style "margin-bottom" "3rem" ]
                [ h2 [ class "title" ] [ text "Made With" ]
                , ul [ class "nes-list is-disc" ]
                    [ li [] [ text "Frontend - Elm" ]
                    , li [] [ text "Backend - Flask" ]
                    , li [] [ span [] [ text "Style - ", a [ href "https://nostalgic-css.github.io/NES.css/" ] [ text "NES.css" ] ] ]
                    ]
                ]
            , div [ class "nes-container with-title", style "width" "auto" ]
                [ h2 [ class "title" ] [ text "Links" ]
                , a [ href "https://twitter.com/ThisIsJackEvans" ]
                    [ i [ class "nes-icon twitter is-large", style "margin-right" "1rem" ] []
                    , text "@Jackevansevo"
                    ]
                , i [ class "nes-icon github is-large", style "margin-left" "2rem", style "margin-right" "1rem" ] []
                , text "View Source"
                ]
            ]
        ]


view : Model -> Browser.Document Msg
view model =
    case model.route of
        Routing.Home ->
            { title = "Typestest"
            , body = [ homeView model ]
            }

        Routing.About ->
            { title = "About Page"
            , body = [ aboutView model ]
            }

        Routing.NotFound ->
            { title = "Not Found"
            , body =
                [ text "Not Found"
                ]
            }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]
