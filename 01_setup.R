# setup

library(rtweet)
library(tidyverse)
library(httpuv)
library(tidytext)

# source: https://resulumit.com/teaching/twtr_workshop.html#1 
# https://github.com/resulumit/twtr_workshop/tree/materials 

# academic research access
# https://developer.twitter.com/en/products/twitter-api/academic-research 

# rtweet_app(bearer_token = Bearer_Token)
# auth_setup_default()
auth_has_default()

## Prezydent https://twitter.com/AndrzejDuda 
## i Premier RP https://twitter.com/MorawieckiM 

pad <- "@AndrzejDuda"
mm <- "@MorawieckiM"

duda_morawiecki <- rtweet::get_timeline(
  user = c("@AndrzejDuda", "@MorawieckiM"), parse = TRUE, 
  )

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

