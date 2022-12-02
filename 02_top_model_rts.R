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

load("top_model_100.RData")

# tych id szukam w retweeted status user$id_str 
top_model_pl_100_entities_mentions$entities_user_mentions_id_str

top_model_pl_100_rts_status <- 
  top_model_pl_100 %>% 
  select(id_str, retweeted_status) %>% 
  unnest_wider(retweeted_status, 
               names_sep = "_",
               names_repair = "universal") %>% 
  unnest_wider(retweeted_status_user,
               names_sep = "_",
               names_repair = "universal")

table(top_model_pl_100_entities_mentions$entities_user_mentions_id_str == top_model_pl_100_rts_status$retweeted_status_user_id_str, useNA = "always")

cbind(top_model_pl_100_entities_mentions$entities_user_mentions_id_str, 
      top_model_pl_100_rts_status$retweeted_status_user_id_str)[27, ]

###########################
# wniosek: może nie zgadzać się entities_user_mentions_id_str
# z retweeted_status_user_id_str. 
# entities_user_mentions_id_str oznacza id użytkownika wspomnianego.
# Kiedy mamy RT, zawsze będzie wspomniany użytkownik oryginału.
# Kiedy nie mamy RT, ktoś może, ale nie musi być wspomniany
# retweeted_status_user_id_str oznacza id uż. oryginalnego tweetu,
# wtedy gdy mamy RT


# łączymy dane w jedną ramkę
rts_top_model_pl_100 <- 
  left_join(
    x = top_model_pl_100 %>%
      select(created_at,
             id_str, 
             full_text), 
    y = top_model_pl_100_rts_status %>% 
      select(id_str,
             retweeted_status_user_id_str,
             retweeted_status_user_screen_name,
             retweeted_status_id_str)
  )

users_data_top_model_100 <- users_data_top_model_100 %>% 
  rename(user_id_str = id_str, 
         user_screen_name = screen_name)

rts_top_model_pl_100 <- 
  bind_cols(
    rts_top_model_pl_100, 
    users_data_top_model_100 %>% select(user_id_str, user_screen_name)
  )

rts_top_model_pl_100 <- rts_top_model_pl_100 %>%
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
# w Gephi jest to edge "source"
# user_screen_name jako drugą 
# jest to edge "target" 


igr_rts_top_model_pl_100 <- 
  igraph::graph_from_data_frame(d = rts_top_model_pl_100 %>% 
                                  select(-full_text) %>% 
                                  filter(!is.na(retweeted_status_user_screen_name)),
                                directed = TRUE,
                                vertices = NULL)

# write_graph(simplify(igr_rts_top_model_pl_100),
#             "rts_top_model_pl_100.gml",
#             format = "gml")
# ucinamy większość zmiennych

write_graph(igr_rts_top_model_pl_100,
            "rts_top_model_100.gml",
            format = "gml")

# jak wyszukać tweet?
# https://twitter.com/anyuser/status/{status_id}
# przykładowo 
# https://twitter.com/anyuser/status/1595542678397132812
# i jego RT 
# https://twitter.com/anyuser/status/1596103627445501953

# czy na pewno nie powinno być wag?
# tzn. czy pary id tworzące edges są unikalne?

rts_top_model_pl_100 %>% 
  filter(!is.na(retweeted_status_user_screen_name)) %>% 
  count(retweeted_status_user_screen_name, 
                               user_screen_name) %>% arrange(desc(n))


# są