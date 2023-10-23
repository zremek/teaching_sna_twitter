# setup

library(rtweet)
library(tidyverse)
library(httpuv)
library(tidytext)
library(igraph)
library(tibblify)

Sys.setenv(LANGUAGE = "en")

# source: https://resulumit.com/teaching/twtr_workshop.html#1 
# https://github.com/resulumit/twtr_workshop/tree/materials 

# academic research access
# https://developer.twitter.com/en/products/twitter-api/academic-research 

# rtweet_app(bearer_token = Bearer_Token)
?rtweet_user()
auth_setup_default()
# auth_has_default()


# puszczam nie robiąc nic poza załadowaniem paczki
test_df <- search_tweets("#CzasRozliczenia", n = 10, 
              include_rts = FALSE)

# auth <- rtweet_app()
# auth_as(auth)
# auth_save(auth, "a_teaching_sna_zremek")
# auth_as("a_teaching_sna_zremek")

## Prezydent https://twitter.com/AndrzejDuda 
## i Premier RP https://twitter.com/MorawieckiM 

pad <- "@AndrzejDuda"
mm <- "@MorawieckiM"

duda_morawiecki <- rtweet::get_timeline(
  user = c("@AndrzejDuda", "@MorawieckiM"), parse = TRUE, 
  )


# Error: Twitter API failed [403]. Check error message at https://developer.twitter.com/en/support/twitter-api/error-troubleshooting 
# * You currently have access to a subset of Twitter API v2 endpoints and limited v1.1 endpoints (e.g. media post, oauth) only. If you need access to this endpoint, you may need a different access level. You can learn more here: https://developer.twitter.com/en/portal/product (453)


duda_timeline_10 <- rtweet::get_timeline(
  user = pad, 
  n = 10,
  parse = TRUE,
  include_rts = TRUE
)

duda_retweets_1 <- rtweet::get_retweeters(duda_timeline_10$id_str[1], 
                                           n = 1)


duda_followers <- rtweet::get_followers(user = pad,
                                        n = Inf,
                                        retryonratelimit = TRUE)

mat_followers <- rtweet::get_followers(user = mm,
                                        n = Inf,
                                        retryonratelimit = TRUE)
# 7 500 rows - much less than real # of followers (why?)

# friends == following by
duda_friends <- rtweet::get_friends(users = pad, 
                                    n = Inf, 
                                    retryonratelimit = TRUE)

mat_friends <- rtweet::get_friends(users = mm, 
                                   n = Inf, 
                                   retryonratelimit = TRUE)

summary(duda_morawiecki) 

# TODO - z danych get_timeline info o retweetach pad i mm

####### search tweets #########


top_model_pl_100 <- rtweet::search_tweets(q = "#topmodel", 
                                      n = 100, 
                                      type = "recent", 
                                      retryonratelimit = TRUE, 
                                      lang = "pl")
  
# top_100_net <- filter(top_model_pl_100, retweet_count > 0) %>% 
#   select(screen_name, mentions_screen_name) %>%
#   unnest(mentions_screen_name) %>% 
#   filter(!is.na(mentions_screen_name)) %>% 
#   graph_from_data_frame()
#   


# top_model_pl_100[[7]][[1]][["user_mentions"]][["screen_name"]]
# top_model_pl_100[[7]][[1]][["user_mentions"]][["id_str"]]

users_data_top_model_100 <- users_data(top_model_pl_100)

top_model_pl_100_entities <- 
  top_model_pl_100 %>% 
    select(created_at:display_text_range, entities) %>% 
    unnest_wider(entities, names_sep = "_",
                 strict = FALSE,
                 names_repair = "universal")

top_model_pl_100_entities_mentions <- 
  top_model_pl_100_entities %>%
    select(id_str, entities_user_mentions) %>% 
    unnest_wider(entities_user_mentions, 
                 names_sep = "_",
                 names_repair = "universal") %>% 
    select(-entities_user_mentions_indices)



# # TODO 
# 1. zrobić jedną ramkę
# tylko retweety
# id i czas tweetu, id i screen name tweetującego,
# id i screen name retweetowanego 
# upewnić się, że 
# # top_model_pl_100[[7]][[1]][["user_mentions"]][["id_str"]]
# i retweeted status user$id_str to to samo (do tego rt status trzeba się dobrać unnest)
# 
# 4. zapisać do gephi 
# https://www.toptal.com/r/social-network-analysis-in-r-gephi-tutorial 
# 
# 3. wszystko to samo na dużych danych

# save.image("top_model_100.RData")

# robię TODO w pliku 02_top_model_rts


# retweeted_status_user$id_str
# retweeted_status_user$screen_name
