library(academictwitteR)

# set_bearer()


tweets <-
  get_all_tweets(
    query = "#CzasRozliczenia",
    start_tweets = "2023-10-15T00:00:00Z",
    end_tweets = "2020-10-25T00:00:00Z",
    file = "czas_rozliczenia_download",
    data_path = "data/",
    n = 1000000,
  )
# something went wrong. Status code: 403

# user lookup
academictwitteR::get_user_id(usernames = "AndrzejDuda") #403
