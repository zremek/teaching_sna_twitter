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
# auth_setup_default()
auth_has_default()



####### szukamy tweetów po hashtagu #########

# Set n = Inf to download as many results as possible.

top_model_pl_full <- rtweet::search_tweets(q = "#topmodel", 
                                           n = Inf, 
                                           type = "recent", 
                                           retryonratelimit = TRUE, 
                                           lang = "pl")

# zapisujemy .RData, obiekt z danymi może być duży i jest niepowtarzalny
# save.image("top_model_full.RData")

######### porządkujemy dane ###############

users_data_top_model_full <- users_data(top_model_pl_full)

top_model_pl_full_entities <- 
  top_model_pl_full %>% 
  select(created_at:display_text_range, entities) %>% 
  unnest_wider(entities, names_sep = "_",
               strict = FALSE,
               names_repair = "universal")

top_model_pl_full_entities_mentions <- 
  top_model_pl_full_entities %>%
  select(id_str, entities_user_mentions) %>% 
  unnest_wider(entities_user_mentions, 
               names_sep = "_",
               names_repair = "universal") %>% 
  select(-entities_user_mentions_indices)

top_model_pl_full_rts_status <- 
  top_model_pl_full %>% 
  select(id_str, retweeted_status) %>% 
  unnest_wider(retweeted_status, 
               names_sep = "_",
               names_repair = "universal") %>% 
  unnest_wider(retweeted_status_user,
               names_sep = "_",
               names_repair = "universal")

# łączymy dane w jedną ramkę
rts_top_model_pl_full <- 
  left_join(
    x = top_model_pl_full %>%
      select(created_at,
             id_str, 
             full_text), 
    y = top_model_pl_full_rts_status %>% 
      select(id_str,
             retweeted_status_user_id_str,
             retweeted_status_user_screen_name,
             retweeted_status_id_str)
  )

users_data_top_model_full <- users_data_top_model_full %>% 
  rename(user_id_str = id_str, 
         user_screen_name = screen_name)

rts_top_model_pl_full <- 
  bind_cols(
    rts_top_model_pl_full, 
    users_data_top_model_full %>% select(user_id_str, user_screen_name)
  )

rts_top_model_pl_full <- rts_top_model_pl_full %>%
  rename(status_created_at = created_at, 
         status_id_str = id_str) %>% 
  relocate(retweeted_status_user_screen_name, user_screen_name)

# robimy dane sieciowe

## ?igraph::graph_from_data_frame
# If vertices is NULL, then the first two columns of d
# are used as a symbolic edge list and additional columns
# as edge attributes. The names of the attributes are taken
# from the names of the columns.

# ustawiam retweeted_status_user_screen_name jako pierwszą kolumnę
# w Gephi jest to edge "source id"
# user_screen_name jako drugą 
# jest to edge "target id" 


igr_rts_top_model_pl_full <- 
  igraph::graph_from_data_frame(d = rts_top_model_pl_full %>% 
                                  select(-full_text) %>% 
                                  filter(!is.na(retweeted_status_user_screen_name)),
                                directed = TRUE,
                                vertices = NULL)

# write_graph(simplify(igr_rts_top_model_pl_full),
#             "rts_top_model_pl_full.gml",
#             format = "gml")
# ucinamy większość zmiennych

write_graph(igr_rts_top_model_pl_full,
            "rts_top_model_pl_full_2023_12_02.gml",
            format = "gml")

# jak wyszukać tweet?
# https://twitter.com/anyuser/status/{status_id}
# przykładowo 
# https://twitter.com/anyuser/status/1595542678397132812
# i jego RT 
# https://twitter.com/anyuser/status/1596103627445501953

# czy na pewno nie powinno być wag?
# tzn. czy pary id tworzące edges są unikalne?

rts_top_model_pl_full %>% 
  filter(!is.na(retweeted_status_user_screen_name)) %>% 
  count(retweeted_status_user_screen_name, 
        user_screen_name) %>% arrange(desc(n))

# 2 760 == unikalne pary == edges w Gephi 

# nie są, powinny być wagi! 

####### opis danych #########

load("top_model_full.RData")

summary(rts_top_model_pl_full)

rts_top_model_pl_full %>%
  filter(!is.na(retweeted_status_user_screen_name)) %>%
  mutate(created_days = lubridate::floor_date(status_created_at, 
                                              unit = "days")) %>% 
  ggplot(aes(x = created_days)) + geom_bar()

rts_top_model_pl_full %>%
  filter(!is.na(retweeted_status_user_screen_name)) %>% dim()

rts_top_model_pl_full %>% dim()
