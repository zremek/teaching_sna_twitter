library(rtweet)


# puszczam nie robiąc nic poza załadowaniem paczki
test_df <- search_tweets("#CzasRozliczenia", n = 10, 
                         include_rts = FALSE)
# nie działa


# w czwartek 26.10. zrobiłem test API z użyciem terminala, bez żadnego pakietu R.
# 
# komeda i wynik: 
#   
#   remek@mac-remka ~ %       
#   curl --request GET 'https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev' --header 'Authorization: Bearer xxx-to-skasowałem-xxx' 
# 
# 
#   {"client_id":"27943882",
#     "detail":"When authenticating requests to the Twitter API v2 endpoints, you must use keys and tokens from a Twitter developer App that is attached to a Project. You can create a project via the developer portal.",
#     "registration_url":"https://developer.twitter.com/en/docs/projects/overview",
#     "title":"Client Forbidden",
#     "required_enrollment":"Appropriate Level of API Access",
#     "reason":"client-not-enrolled",
#     "type":"https://api.twitter.com/2/problems/client-forbidden"}%      
# 


# wygląda na to, że za darmoszkę jest tylko write a nie read, czyli nie da rady już pobrać danych bez płacenia za to https://pipedream.com/community/t/error-twitter-and-pipedream/6382 

# za free powinno dać się robić wyszukiwanie użytkowników (user lookup), nie wiem czy to zadziała ani czy ma sens
# https://developer.twitter.com/en/docs/twitter-api/users/lookup/quick-start/user-lookup 
# sprawdzam to paczką academic 

