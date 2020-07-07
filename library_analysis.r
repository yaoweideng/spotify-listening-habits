
# import packages -------------------------------------------------------

library(dplyr)
library(tidyr)
library(reshape2)
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

get_avg_genre <- function(x, y) {
  n <- nrow(x) / 2
  for(i in 1:length(y)){
    name <- y[i]
    x[,name] <- x$genre
    for(j in 1:nrow(x)) {
      if(x[,name][j] == y[i]){
        x[,name][j] = 1
      } else {
        x[,name][j] = 0
      }
    }
    x[,name] <- stats::filter(x[,name], rep(1/n, n), sides = 1)
  }
  return(x)
}
 
# import .csv file --------------------------------------------------------

tracks_all <- get_file("song_library.csv")

# processing pt.1 --------------------------------------------------------------

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
         -'time_signature', -'artist_genre1', -'artist_genre2', -'artist_popularity')
tracks_200_avg <- tracks_met
tracks_met <- data.frame(tracks_met[1:6], apply(tracks_met[7:12], 2, get_avg))

# processing pt. 2 --------------------------------------------------------

tracks_200_avg <- data.frame(tracks_200_avg[1:6], apply(tracks_200_avg[7:12], 2, get_200_avg))
tracks_200_avg <- tracks_200_avg %>%
  drop_na()
metrics <- c('popularity', 'acousticness', 'danceability', 'energy', 'liveness', 'valence')
colors <- c('firebrick', 'aquamarine2', 'skyblue', 'green4', 'gold', 'violet')
tracks_met <- tail(tracks_met, -10)
tracks_met <- gather(tracks_met, key = metric, value = measure, metrics)
tracks_200_avg <- gather(tracks_200_avg, key = metric, value = measure, metrics)

# processing pt. 3 --------------------------------------------------------

dens <- c('valence', 'danceability')
tracks_dens <- gather(tracks, key = metric, value = measure, dens)
tracks_genre <- tracks %>%
  select('date_added', 'artist_genre1', 'artist_genre2') 
tracks_genre <- melt(tracks_genre, id.var = 'date_added', variable.name = 'genre')
tracks_genre <- tracks_genre %>%
  select(-'genre')
colnames(tracks_genre) <- c('date_added', 'genre')
tracks_genre <- tracks_genre[which(tracks_genre$genre != ""),]
most_pop_genres <- tracks_genre %>% 
  group_by(genre) %>% 
  summarize(n = n(), .groups = 'drop') %>% 
  top_n(12)
most_pop_genres2 <- most_pop_genres %>%
  top_n(8)
genre_names <- as.character(most_pop_genres2$genre)
genres_avg <- get_avg_genre(tracks_genre, genre_names) %>%
  drop_na()
genres_avg <- gather(genres_avg, key = genre, value = measure, genre_names)

# processing pt. 4 --------------------------------------------------------

tracks_has_pop <- tracks[which(tracks$popularity != 0),]
fit <- lm(data = tracks_has_pop, popularity ~ artist_popularity)

# visualizations pt. 1 ----------------------------------------------------------

plot1 <- ggplot(tracks_met, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  ylab('metric') + 
  ggtitle('average metric values over time of Spotify song library') +
  theme(axis.title.x = element_blank())

plot2 <- ggplot(tracks_met, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  facet_wrap(~ metric, scales = "free") + 
  theme(axis.title.x = element_blank())

# visualizations pt. 2 ----------------------------------------------------

plot3 <- ggplot(tracks_200_avg, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  ylab('measure') + 
  ggtitle('rolling 200-song average metric values of Spotify library over time') +
  theme(axis.title.x = element_blank())
  
plot4 <- ggplot(tracks_200_avg, aes(x = date_added, y = measure, group = metric, color = metric)) + 
  geom_line() +
  scale_color_manual(values = colors) +
  facet_wrap(~ metric, scales = "free") +
  theme(axis.title.x = element_blank())

# visualizations pt. 3 ----------------------------------------------------

plot5 <- ggplot(tracks_dens, aes(x = measure, color = metric, fill = metric)) +
  geom_histogram(aes(y = ..density..), binwidth = 0.01, position = 'identity', alpha = 0.4) +
  geom_density(alpha = 0.6) +
  scale_color_manual(values = c("black", "black")) +
  scale_fill_manual(values = c("seagreen2", "skyblue")) +
  ggtitle("comparing densities between song danceability and song valence in library")

plot6 <- ggplot(most_pop_genres, aes(x = genre, y = n, group = genre, fill = genre)) +
  geom_bar(stat = 'identity') +
  scale_fill_viridis(discrete = TRUE) +
  ggtitle('most popular genres across song library (top 12 genres)') +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank())

plot7 <- ggplot(genres_avg, aes(x = date_added, y = measure, group = genre, color = genre)) + 
  geom_line() +
  scale_color_brewer(palette = 'Set3') +
  ylab('percentage of Spotify library') + 
  ggtitle('average genre composition of Spotify library over time (top 8 genres)') +
  theme(axis.title.x = element_blank())

plot8 <- ggplot(genres_avg, aes(x = date_added, y = measure, group = genre, color = genre)) + 
  geom_line() +
  scale_color_brewer(palette = 'Set3') +
  facet_wrap(~ genre, scales = "free") + 
  ylab('percentage of Spotify library') +
  theme(axis.title.x = element_blank())

# visualizations pt. 4 ----------------------------------------------------

plot9 <- ggplot(tracks_has_pop, aes(artist_popularity, popularity)) +
  geom_point(size = 0.5) + 
  stat_smooth(method = 'lm', color = "aquamarine2", formula = y ~ x) +
  xlab("artist popularity") +
  ylab("track popularity") +
  ggtitle("linear regression line, track vs artist popularity in library")

# see plots ---------------------------------------------------------------

plot1
plot2
plot3
plot4
plot5
plot6
plot7
plot8
plot9