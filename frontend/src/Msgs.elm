module Msgs exposing (Msg(..))

import Browser
import Browser.Events exposing (Visibility)
import Http
import Time
import Url


type Msg
    = NoOp
    | FocusInput
    | UpdateTyped String
    | Tick Time.Posix
    | Reset
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotWords (Result Http.Error String)
    | VisibilityChange Visibility
    | StartGame Time.Posix
    | StopTimer Time.Posix
    | ToggleViewSettings
    | UpdateSource String
