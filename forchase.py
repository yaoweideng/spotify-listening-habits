#%%
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pandas as pd
import numpy as np
import secret

client_id = secret.client_id
client_secret = secret.client_secret
username = secret.username
p_id = secret.playlist_id
credentials = SpotifyClientCredentials(client_id, client_secret)
sp = spotipy.Spotify(client_credentials_manager = credentials)
NaN = np.nan

#%% function definitions
def next_tracks(results, array, option):
    if (option == 1):
        for i, item in enumerate(results['items']):
             track = item['track']
             array.append(track['id'])
    elif (option == 2):
        for i, item in enumerate(results['items']):
             date = item['added_at']
             array.append(date)
    else: 
        for i, item in enumerate(results['items']):
             track = item['track']
             artist = track['artists'][0]
             array.append(artist['id'])
                
def get_ids(option, username, playlist_id):
    ids = []
    playlist = sp.user_playlist(username, playlist_id)
    tracks = playlist['tracks']
    next_tracks(tracks, ids, option)
    while tracks['next']:
        tracks = sp.next(tracks)
        next_tracks(tracks, ids, option)
    return ids

def get_track_info(id, date, artist):
    info = sp.track(id)
    feats = sp.audio_features(id)
    artists = sp.artist(artist)
    date_added = date

    name = info['name']
    album = info['album']['name']
    artist = info['album']['artists'][0]['name']
    release_date = info['album']['release_date']
    length = info['duration_ms']
    popularity = info['popularity']
    artist_popularity = artists['popularity']
    
    if len(artists['genres']) == 0:
        artist_genre1 = NaN
    else:
        artist_genre1 = artists['genres'][0]
    if len(artists['genres']) >= 2:
        artist_genre2 = artists['genres'][1]
    else:
        artist_genre2 = NaN
  
    if (feats[0] == None):
        feats[0] = {'acousticness' : NaN,
                    'danceability' : NaN,
                    'energy' : NaN,
                    'instrumentalness' : NaN,
                    'liveness' : NaN,
                    'loudness' : NaN, 
                    'speechiness' : NaN,
                    'tempo' : NaN,
                    'time_signature' : NaN,
                    'valence' : NaN}
 
    acousticness = feats[0]['acousticness']
    danceability = feats[0]['danceability']
    energy = feats[0]['energy']
    instrumentalness = feats[0]['instrumentalness']
    liveness = feats[0]['liveness']
    loudness = feats[0]['loudness']
    speechiness = feats[0]['speechiness']
    tempo = feats[0]['tempo']
    time_signature = feats[0]['time_signature']
    valence = feats[0]['valence']

    track = [name, album, artist, artist_genre1, artist_genre2, release_date, 
             date_added, length, popularity, artist_popularity, acousticness, 
             danceability, energy, instrumentalness, liveness, loudness, 
             speechiness, tempo, time_signature, valence]
    return track

#%% getting track ids and dates added
ids = get_ids(1, username, p_id)
dates = get_ids(2, username, p_id)
artists = get_ids(3, username, p_id)

#%% getting all the track info into a dataframe
tracks = []

for i in range(len(ids)):
    
    track = get_track_info(ids[i], dates[i], artists[i])
    tracks.append(track)

df = pd.DataFrame(tracks, columns = 
                  ['name', 'album', 'artist', 'artist_genre1', 'artist_genre2', 
                   'release_date', 'date_added', 'length', 'popularity', 
                   'artist_popularity', 'acousticness', 'danceability', 'energy', 
                   'instrumentalness', 'liveness', 'loudness', 'speechiness', 
                   'tempo', 'time_signature', 'valence'])

#%% exporting dataframe into a .csv file
df.to_csv("song_library.csv", sep = '|')
ids = pd.DataFrame(ids)
ids.to_csv("track_ids.csv", index = False)