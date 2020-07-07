
# import packages -------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(viridis)
library(RColorBrewer)
source("directory.r")

# function definitions ----------------------------------------------------

get_file <- function(x) {
  filepath <- paste0(directory, x)
  tracks <- read.csv(filepath, stringsAsFactors = FALSE, header = TRUE, sep = "|")
  return(tracks)
}

# import file -------------------------------------------------------------

history <- get_file('streaming_history.csv')

# processing --------------------------------------------------------------

history <- history %>%
  select(-'X') %>%
  rename(time = endTime, artist = artistName, track = trackName)
top_artists <- history %>%
  group_by(artist) %>%
  summarize(n = n(), .groups = 'drop')
top_tracks <- history %>%
  group_by(track) %>%
  summarize(n = n(), .groups = 'drop')
top_artists_12 <- top_artists %>%
  top_n(12)
top_tracks_12 <- top_tracks %>%
  top_n(12)

# plots -------------------------------------------------------------------

plot_a <- ggplot(top_artists_12, aes(x = artist, y = n, group = artist, fill = artist)) +
  geom_bar(stat = 'identity') +
  scale_fill_viridis(discrete = TRUE) +
  ggtitle('most streamed artists in the last year') +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank())
plot_b <- ggplot(top_tracks_12, aes(x = track, y = n, group = track, fill = track)) +
  geom_bar(stat = 'identity') +
  scale_fill_viridis(discrete = TRUE, option = 'plasma') +
  ggtitle('most streamed tracks in the last year') +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank())

# see plots ---------------------------------------------------------------

plot_a
plot_b