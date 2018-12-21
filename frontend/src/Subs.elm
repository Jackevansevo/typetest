module Subs exposing (subscriptions)

import Browser.Events exposing (onVisibilityChange)
import Model exposing (Model, Status(..))
import Msgs exposing (Msg)
import Time


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.status of
        InProgress _ ->
            Sub.batch [ Time.every 100 Msgs.Tick, onVisibilityChange Msgs.VisibilityChange ]

        _ ->
            onVisibilityChange Msgs.VisibilityChange
