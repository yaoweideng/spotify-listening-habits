
# import packages -------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
source("directory.r")

# function definitions ----------------------------------------------------

get_file <- function(x) {
  filepath <- paste0(directory, x)
  tracks <- read.csv(filepath, stringsAsFactors = FALSE, header = TRUE, sep = "|")
  return(tracks)
}

get_avg <- function(x) {
  cumsum = 0
  for(i in 1:length(x)) {
    cumsum <- cumsum + x[i]
    x[i] <- cumsum / i
  }
  return(x)
}

get_200_avg <- function(x) {
  x <- stats::filter(x, rep(1/200, 200), sides = 1)
  return(x)
}

# import .csv file --------------------------------------------------------

tracks_all <- get_file("song_library.csv")

# processing --------------------------------------------------------------

tracks <- tracks_all %>%
  select(-'X') %>%
  drop_na()
tracks$popularity <- tracks$popularity / 100
pop_density <- tracks %>%
  group_by(popularity) %>%
  summarize(n())
tracks$date_added <- as.POSIXct(tracks$date_added, tz = "UTC", "%Y-%m-%dT%H:%M:%S")
tracks <- tracks[order(tracks$date_added),]
tracks_met <- tracks %>%
  select(-'tempo', -'instrumentalness', -'loudness', -'speechiness', 
         -'time_signature')
tracks_200_avg <- tracks_met
tracks_met <- data.frame(tracks_met[1:6], apply(tracks_met[7:12], 2, get_avg))
tracks_200_avg <- data.frame(tracks_200_avg[1:6], apply(tracks_200_avg[7:12], 2, get_200_avg))
tracks_200_avg <- tracks_200_avg %>%
  drop_na()

# visualizations ----------------------------------------------------------

metrics <- c('popularity', 'acousticness', 'danceability', 'energy', 'liveness', 'valence')
colors <- c('firebrick', 'aquamarine2', 'skyblue', 'green4', 'gold', 'violet')
title <- 'average metric values over time of Spotify song library'
tracks_met <- tail(tracks_met, -10)
tracks_met <- gather(tracks_met, key = metric, value = measure, metrics)
tracks_200_avg <- gather(tracks_200_avg, key = metric, value = measure, metrics)
plot1 <- ggplot(tracks_met, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  ylab('metric') + 
  xlab('date') +
  ggtitle(title)
plot2 <- ggplot(tracks_met, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  facet_wrap(~ metric, scales = "free") + 
  xlab('date')
  ggtitle(title)
plot3 <- ggplot(tracks_200_avg, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  ylab('metric') + 
  xlab('date') +
  ggtitle('rolling 200-song average metric values of Spotify library over time')
plot4 <- ggplot(tracks_200_avg, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  facet_wrap(~ metric, scales = "free") + 
  xlab('date')
plot1
plot2
plot3
plot4