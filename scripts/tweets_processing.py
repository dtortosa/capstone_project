

import pandas as pd

# Reads the json generated from the CLI commands above and creates a pandas dataframe
tweets_df = pd.read_json('text-query-tweets.json', lines=True)

#process json file
	#https://www.kaggle.com/code/prathamsharma123/clean-raw-json-tweets-data/notebook

tweets_df.shape
	#as many rows as tweets
	#as many columns as features in each tweet

tweets_df.columns
	#see features

tweets_df.iloc[0, :]
	#get all columns for the first tweet
	#raw content is 3

tweet_text = tweets_df.iloc[:, 4]
	#raw text of the tweets is in column index 3

[tweet for tweet in tweet_text]