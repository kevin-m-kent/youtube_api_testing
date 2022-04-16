library(httr2)

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
                      name = "youtube_ONE_video_ALL_comments")

req <- request("https://www.googleapis.com/upload/youtube/v3/videos")

snippet_string <- c(list("snippet.title" = "test",
                       "snippet.description" = "description_test",
                       "snippet.tags"="test_tag",
                       "snippet.category" = "test_cat"),
"status" = list("privacyStatus" = "private")
) %>%
  jsonlite::toJSON()

resp <- httr2::req_oauth_auth_code( req,
                                   client = client,
                                   auth_url = auth_url,
                                   scope = scope, 
                                   pkce = FALSE,
                                   auth_params = list(scope=scope, response_type="code"),
                                   token_params = list(scope=scope, grant_type="authorization_code"),
                                   host_name = "localhost",
                                   host_ip = "127.0.0.1",
                                   port = 8080, 
) %>%
  req_body_multipart(
    list("media" = curl::form_file("test_video.mp4"))) #,
  #"snippet" = curl::form_data(snippet_string)))
  
esp %>%
  req_perform()



