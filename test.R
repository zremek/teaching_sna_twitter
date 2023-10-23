library(rtweet)


# puszczam nie robiąc nic poza załadowaniem paczki
test_df <- search_tweets("#CzasRozliczenia", n = 10, 
                         include_rts = FALSE)
# nie działa