module Main exposing (main)

import Browser
import Browser.Navigation exposing (load)
import Random
import Task
import Time
import Timespectre.API as API
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (..)
import Timespectre.Util as Util
import Timespectre.View exposing (view)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( Model
        { sessions = []
        , timeZone = Time.utc
        , currentTime = Time.millisToPosix 0
        , editingTag = Nothing
        , mode = Sessions
        , tagStats = Nothing
        }
    , Cmd.batch [ Task.perform SetTimeZone Time.here, API.requestState ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 250 SetTime


update : Msg -> Model -> ( Model, Cmd.Cmd Msg )
update msg model =
    case model of
        Model value ->
            case msg of
                StartSession ->
                    ( model, Random.generate SessionStarted idGenerator )

                SessionStarted id ->
                    ( Model { value | sessions = addSession id value.currentTime value.sessions }, API.putSession { id = id, start = value.currentTime, end = Nothing, notes = "", tags = [] } )

                SetTimeZone timeZone ->
                    ( Model { value | timeZone = timeZone }, Cmd.none )

                SetTime time ->
                    ( Model { value | currentTime = time }, Cmd.none )

                DiscardResponse _ ->
                    ( model, Cmd.none )

                FetchedSessions (Err _) ->
                    ( FatalError "An unknown error occurred while loading state from the server. This may be due to a problem with either the server or this client. Try reloading.", Cmd.none )

                FetchedSessions (Ok sessions) ->
                    ( Model { value | sessions = sessions }, Cmd.none )

                FetchedTagStats (Err _) ->
                    ( FatalError "An unknown error occurred while loading tag statistics from the server. This may be due to a problem with either the server or this client. Try reloading.", Cmd.none )

                FetchedTagStats (Ok stats) ->
                    ( Model { value | tagStats = Just stats }, Cmd.none )

                DeleteSession session ->
                    ( Model { value | sessions = List.filter (\s -> s.id /= session.id) value.sessions }, API.deleteSession session )

                SetNotes session notes ->
                    ( Model { value | sessions = setNotes session notes value.sessions }, API.putNotes session notes )

                EndSession session ->
                    ( Model { value | sessions = endSession session value.currentTime value.sessions }, API.putEnd session value.currentTime )

                EditTag session index ->
                    ( Model { value | editingTag = Just { session = session, index = index, buffer = nthTag session index } }, Cmd.none )

                AddTag session ->
                    let
                        ( sessions, newSession, index ) =
                            addTag value.sessions session "tag"
                    in
                    update (EditTag newSession index) (Model { value | sessions = sessions })

                SetEditingTagBuffer buffer ->
                    case value.editingTag of
                        Just inner ->
                            ( Model { value | editingTag = Just { inner | buffer = buffer } }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                SubmitTag ->
                    case value.editingTag of
                        Just inner ->
                            ( Model { value | sessions = setNthTagOfSession value.sessions inner.session inner.index inner.buffer, editingTag = Nothing }, API.setTag inner.session inner.index inner.buffer )

                        Nothing ->
                            ( model, Cmd.none )

                ViewSessions ->
                    ( Model { value | mode = Sessions }, API.requestState )

                ViewTags ->
                    ( Model { value | mode = Tags }, API.requestTagStatsSince (Time.millisToPosix 0) )

                ViewTagsToday ->
                    ( Model { value | mode = Tags }, API.requestTagStatsSince (Util.lastMidnight value.currentTime value.timeZone) )

                LogOut ->
                    ( model, load "/logout" )

        FatalError _ ->
            ( model, Cmd.none )
