library(httr2)
library(jsonlite)

# set up dev api access on google, choosing desktop for youtube data api
API_KEY <- Sys.getenv("API_Key")
client_id <- Sys.getenv("client_id")
client_secret <- Sys.getenv("client_secret")

token_url <- "https://oauth2.googleapis.com/token"
auth_url <- "https://accounts.google.com/o/oauth2/v2/auth"
scope = "https://www.googleapis.com/auth/youtube"

client <- oauth_client(id=  client_id,
                      token_url  = token_url,
                      secret = client_secret,
                      key =  API_KEY,
                      auth = "body",   # header or body
                      name = "video_upload_api")

# api guide https://developers.google.com/youtube/v3/docs/videos/insert#go
# additional parts need to be specified as arguments in the request string

req <- request("https://www.googleapis.com/upload/youtube/v3/videos?part=snippet&part=status")

snippet_string <- list(snippet = list("title" = unbox("video kids test"),
                       "description" = unbox("description_test"),
                       "tags" = "kevin,kent"),
status = list("privacyStatus" = unbox("private"),
              "selfDeclaredMadeForKids" = unbox("false"))) %>%
  jsonlite::toJSON()

metadata <- tempfile()
writeLines(snippet_string, metadata)

resp <- httr2::req_oauth_auth_code( req,
                                    client = client,
                                    auth_url = auth_url,
                                    scope = scope, 
                                    pkce = FALSE,
                                    auth_params = list(scope=scope, response_type="code"),
                                    token_params = list(scope=scope, grant_type="authorization_code"),
                                    host_name = "localhost",
                                    host_ip = "127.0.0.1",
                                    #port = httpuv::randomPort()
                                    port = 8080, 
) %>%
  req_body_multipart(
    list(
      metadata = curl::form_file(path = metadata, type = "application/json; charset=UTF-8"),
      media = curl::form_file("Week2 DI Capstone Kevin kent.mp4"))
  ) %>%
  req_perform()

videoId <- resp %>%
  resp_body_json() %>%
  pluck("id")


# assign to playlist ------------------------------------------------------

playlist_req <- request("https://www.googleapis.com/youtube/v3/playlists?part=contentDetails&mine=true")

resp <- httr2::req_oauth_auth_code( playlist_req,
                                    client = client,
                                    auth_url = auth_url,
                                    scope = scope, 
                                    pkce = FALSE,
                                    auth_params = list(scope=scope, response_type="code"),
                                    token_params = list(scope=scope, grant_type="authorization_code"),
                                    host_name = "localhost",
                                    host_ip = "127.0.0.1",
                                    #port = httpuv::randomPort()
                                    port = 8080, 
) %>%
  # # req_body_multipart(
  #    list(
  #      metadata = curl::form_file(path = metadata, type = "application/json; charset=UTF-8"),
  #      media = curl::form_file("kkent intro.mp4"))
  #  ) %>%
  req_perform()

playlist_id <- resp %>%
  resp_body_json() %>%
  pluck("items", 1, "id")

update_req <- request(glue::glue("https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet"))

snippet_string <- list(snippet = list("playlistId" = unbox(playlist_id), "resourceId" = list(
  "kind" = unbox("youtube#video"),
  "videoId" = unbox(videoId)))
) %>%
  jsonlite::toJSON()

metadata <- tempfile()
writeLines(snippet_string, metadata)

update_resp <- httr2::req_oauth_auth_code( update_req,
                                    client = client,
                                    auth_url = auth_url,
                                    scope = scope, 
                                    pkce = FALSE,
                                    auth_params = list(scope=scope, response_type="code"),
                                    token_params = list(scope=scope, grant_type="authorization_code"),
                                    host_name = "localhost",
                                    host_ip = "127.0.0.1",
                                    #port = httpuv::randomPort()
                                    port = 8080, 
) %>%
  req_body_file(
      path = metadata, type = "application/json; charset=UTF-8"
  ) %>%
  req_perform()



