import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Navigation
import String
import Task
import Time


main =
  Navigation.program
    (Navigation.makeParser identity)
    { init = init
    , update = update
    , urlUpdate = urlUpdate
    , view = view
    , subscriptions = always Sub.none
    }


-- MODEL


type alias Model =
  { config : Config
  , scopes : String
  , authCode : String
  , refreshToken : String
  , accessToken : String
  }


type alias Config =
  { authUrl : String
  , tokenUrl : String
  , clientId : String
  , clientSecret : String
  }


init : Navigation.Location -> (Model, Cmd Msg)
init data =
    let
        authCode =
          String.split "=" data.search
            |> List.drop 1
            |> List.head
            |> Maybe.withDefault ""
    in
        { config =
          { authUrl = "https://accounts.google.com/o/oauth2/v2/auth"
          , tokenUrl = "https://www.googleapis.com/oauth2/v4/token"
          , clientId = "253270339440-tp9fiqj5boaqvrs3j8g2u0mtdn4ittgp.apps.googleusercontent.com"
          , clientSecret = "123"
          }
        , scopes = "https://www.googleapis.com/auth/drive"
        , authCode = authCode
        , refreshToken = ""
        , accessToken = ""
        }
        ! []


-- UPDATE


type Msg
  = TokenReq
  | TokenRes


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)


urlUpdate : Navigation.Location -> Model -> (Model, Cmd Msg)
urlUpdate data model =
  (model, Cmd.none)


buildAuthUrl : Model -> String
buildAuthUrl model =
  Http.url
    model.config.authUrl
    [ ("response_type", "code")
    , ("client_id", model.config.clientId)
    , ("redirect_uri", "http://localhost:8000/main.elm")
    , ("scope", model.scopes)
    ]


buildTokenUrl : Model -> String
buildTokenUrl model =
  Http.url
    model.config.tokenUrl
    [ ("code", model.authCode)
    , ("client_id", model.config.clientId)
    , ("client_secret", model.config.clientSecret)
    , ("redirect_uri", "http://localhost:8000/main.elm")
    , ("grant_type", "authorization_code")
    ]


-- VIEW

(=>) = (,)

buttonStyle : Html.Attribute a
buttonStyle =
  Html.Attributes.style
  [ "background-color" => "blue"
  , "color" => "white"
  , "font-family" => "monospace"
  , "padding" => "1em"
  , "border" => "solid 2px white"
  , "outline" => "solid 2px blue"
  , "cursor" => "pointer"
  ]

view : Model -> Html Msg
view model =
  div
    [ style
      [ ("font-family", "'Work Sans', sans-serif")
      , ("text-align", "center")
      ]
    ]
    <|
    [ node "link"
      [ href "https://fonts.googleapis.com/css?family=Fira+Mono|Work+Sans:400,700"
      , rel "stylesheet"
      ]
      []
    , h1 [] [ text "OAuth Playground" ]
    , a [ href <| buildAuthUrl model ] [ text "auth" ]
    , pre [] [ text <| toString model ]
    , if
      model.authCode /= ""
    then
      div []
        [ div []
          [ text <| "auth code: " ++ model.authCode ]
        , button
          [ onClick TokenReq
          , buttonStyle
          ]
          [ text "exchange token" ]
        ]
    else
      empty
    , if
      model.refreshToken /= ""
    then
      div [] [ text <| "refresh token" ++ model.refreshToken ]
    else
      empty
    , if
      model.accessToken /= ""
    then
      div [] [ text <| "access token" ++ model.accessToken ]
    else
      empty
    ]


empty = text ""
