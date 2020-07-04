
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

get_avgs <- function(x) {
  avg <- mean(x)
  return(avg)
}

process <- function(x) {
  metrics <- c('popularity', 'acousticness', 'danceability', 'energy', 'liveness', 'valence')
  newx <- x %>%
    select(-'X',-'tempo', -'instrumentalness', -'loudness', -'speechiness', 
                -'time_signature')
  newx$popularity <- newx$popularity / 100
  newx <- gather(newx, key = metric, value = measure, metrics)
  newx <- newx %>%
    group_by(metric) %>%
    summarize(mean(measure))
  return(newx)
}

# processing --------------------------------------------------------

summer_2017 <- process(get_file("summer1.csv"))
summer_2018 <- process(get_file("summer2.csv"))
summer_2019 <- process(get_file("summer3.csv"))
summer_2020 <- process(get_file("summer4.csv"))
sad_boy_summer <- process(get_file("summerx.csv"))
avgs <- merge(summer_2017, summer_2018, by = 'metric', suffixes = c('2017', '2018')) %>%
  merge(summer_2019, by = 'metric', suffixes = '2019') %>%
  merge(summer_2020, by = 'metric', suffixes = '2020') %>%
  merge(sad_boy_summer, by = 'metric', suffixes = 'sbs')
colnames(avgs) <- c('metric', 'summer 2017', 'summer jamz 2018', "summer jamz '19", "summer jammin' 2020", 'sad boy summer(2019)')
years <- c('summer 2017', 'summer jamz 2018', "summer jamz '19", "summer jammin' 2020", 'sad boy summer(2019)')
avgs <- gather(avgs, key = playlist, value = measure, years)
avgs$playlist <- factor(avgs$playlist, levels = years)

# visualizations ----------------------------------------------------------

colors <- c('firebrick', 'aquamarine2', 'skyblue', 'green4', 'violet')
p1 <- ggplot(avgs, aes(x = playlist, y = measure, group = playlist, fill = playlist)) + 
  geom_bar(stat = 'identity') +
  scale_color_manual(values = colors) +
  facet_wrap(~ metric, scales = "free") +
  ggtitle('average metric values of songs in summer playlists through the years') +
  scale_fill_discrete(breaks = years) +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank())
p1