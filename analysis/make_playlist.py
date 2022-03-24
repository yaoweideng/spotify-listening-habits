#%% import statements and creating auth token
import spotipy
import spotipy.util as util
import pandas as pd

# separate .py file with credentials
import secret

username = secret.username
scope = 'playlist-modify-private'
token = util.prompt_for_user_token(username,
                           scope,
                           client_id = secret.client_id,
                           client_secret = secret.client_secret,
                           redirect_uri = secret.redirect_uri)

if token:
    sp = spotipy.Spotify(auth = token)

#%% import csv and get track ids, use song_library.py to get those beforehand
songs = pd.read_csv("song_library.csv", sep = '|')
ids = pd.read_csv("track_ids.csv")

#%% find indices 
c_pop_songs = songs.loc[songs['artist_genre1'] == 'c-pop'].index
c_pop_ids = ids.iloc[c_pop_songs].values.tolist()

#%% make the playlist
playlist = sp.user_playlist_create(username, name = 'c-pop songs', public = False, description = 'pulled from song library via python')
p_id = playlist['uri']

#%% add the songs
for i in range(len(c_pop_ids)):
    sp.user_playlist_add_tracks(username, p_id, tracks = c_pop_ids[i])