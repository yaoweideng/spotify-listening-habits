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

#%%
def show_tracks(results, array):
    for i, item in enumerate(results['items']):
        track = item['track']
        array.append(track['id'])

def get_track_ids(username, playlist_id):
    ids = []
    playlist = sp.user_playlist(username, playlist_id)
    tracks = playlist['tracks']
    show_tracks(tracks, ids)
    while tracks['next']:
            tracks = sp.next(tracks)
            show_tracks(tracks, ids)
    return ids

def get_track_info(id):
  info = sp.track(id)
  feats = sp.audio_features(id)

  name = info['name']
  album = info['album']['name']
  artist = info['album']['artists'][0]['name']
  release_date = info['album']['release_date']
  length = info['duration_ms']
  popularity = info['popularity']
  
  if(feats[0] == None):
      feats[0] = {
		'acousticness' : NaN,
		'danceability' : NaN,
		'energy' : NaN,
		'instrumentalness' : NaN,
        'liveness' : NaN,
        'loudness' : NaN,
		'speechiness' : NaN,
		'tempo' : NaN,
		'time_signature' : NaN,
        'valence' : NaN
	}
  
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


  track = [name, album, artist, release_date, length, popularity, 
           acousticness, danceability, energy, instrumentalness, 
           liveness, loudness, speechiness, tempo, time_signature, valence]
  return track

#%%
ids = get_track_ids(username, p_id)

#%%
tracks = []
for i in range(len(ids)):
  track = get_track_info(ids[i])
  tracks.append(track)

df = pd.DataFrame(tracks, columns = 
                  ['name', 'album', 'artist', 'release_date', 'length', 'popularity',
                   'acousticness', 'danceability', 'energy', 'instrumentalness',
                   'liveness', 'loudness', 'speechiness', 'tempo', 'time_signature',
                   'valence'])

#%%
df.to_csv("myplaylist.csv", sep = '|')
