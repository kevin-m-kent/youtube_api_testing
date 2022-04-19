library(httr2)
library(jsonlite)

# set up dev api access on google, choosing desktop for youtube data api
API_KEY <- Sys.getenv("API_Key")
client_id <- Sys.getenv("client_id")
client_secret <- Sys.getenv("client_secret")



base_url  <- "https://www.googleapis.com/youtube/v3/playlists"
auth_url = "https://accounts.google.com/o/oauth2/v2/auth"
token_url="https://oauth2.googleapis.com/token"
scope = paste0("https://www.googleapis.com/auth/youtube"," ","https://www.googleapis.com/auth/youtube.force-ssl")

client <- oauth_client(id=  client_id,
                      token_url  = token_url,
                      secret = client_secret,
                      key =  API_KEY,
                      auth = "body",   # header or body
                      name = "video_upload_api")

# api guide https://developers.google.com/youtube/v3/docs/videos/insert#go

req <- request("https://www.googleapis.com/upload/youtube/v3/videos?part=snippet&part=status")

snippet_string <- list(snippet = list("title" = unbox("kevin video final"),
                       "description" = unbox("description_test"),
                       "tags" = "kevin,kent"),
status = list("privacyStatus" = unbox("private"))) %>%
  jsonlite::toJSON()

metadata <- tempfile()
writeLines(snippet_string, metadata)

resp <- httr2::req_oauth_client_credentials(req, client) %>%
  req_body_multipart(
    list(
      metadata = curl::form_file(path = metadata, type = "application/json; charset=UTF-8"),
      media = curl::form_file("kkent intro.mp4"))
  ) %>%
  req_perform()



