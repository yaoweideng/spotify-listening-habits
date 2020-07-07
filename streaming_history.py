#%% 
import pandas as pd

#%% get the json files from Spotify (request your data)
history = pd.read_json('StreamingHistory0.json', orient = 'records')
history1 = pd.read_json('StreamingHistory1.json', orient = 'records')
history2 = pd.read_json('StreamingHistory2.json', orient = 'records')
history3 = pd.read_json('StreamingHistory3.json', orient = 'records')
history4 = pd.read_json('StreamingHistory4.json', orient = 'records')
history5 = pd.read_json('StreamingHistory5.json', orient = 'records')

#%%
history = pd.concat([history, history1, history2, history3, history4, history5], axis = 0)

#%% 
history.to_csv('streaming_history.csv', sep = '|')