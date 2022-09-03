# **Improving prediction of EUR/USD exchange rate using Twitter sentiment**

The goal of this project is to improve the prediction of EUR/USD exchange rate using the previous Twitter sentiment around these currencies.

## Introduction

The prediction of currencies is relevant for minimizing losses due to currency fluctuations. In this regard, the [euro](https://en.wikipedia.org/wiki/Euro) (EUR) is the [second most important currency worldwide](https://www.statista.com/statistics/247362/global-foreign-exchange-market-turnover-by-currency/), thus being its prediction relevant for many economic agents. 

The euro is [fiat money](https://en.wikipedia.org/wiki/Fiat_money), being a financial asset instead of a real asset. Therefore, it is the financial liability or debt that the European Central Bank (BCE) acquires with the holder of the euros. The value of this financial asset depends on the expected services that this asset can give in the future. What expect euro holders from this currency? They hold euros because this currency is backed by the European Central Bank, so they expect it will be more or less stable. If for any reason, the demand of Euros decreases, the ECB can sell its assets to buy euros, decreasing the amount of euros in circulation and stabilizing its value. In addition, the balance of the European Union also influences the amount of euros in circulation. If these countries are spending less than they gain (i.e., profits in the form of taxes are higher than the Government's spending), they will act as a sink of euros, decreasing the amount of euros in circulation. In contrast, many European countries in deficit would mean more euros in circulation and more difficulties to stabilize the value of this currency.

All of this supports that the expectations of the economic agents around, not only the actions of the ECB, but also around the economy of European countries, can influence the value of the euro. I have used Twitter to collect echoes of these previous expectations and improve the predictions of EUR/USD exchange rate. This will be relevant for anyone trying to predict fiat currencies in general and, in particular, the euro in order to get more beneficial exchanges in the short term. Therefore, the approach I have developed here can be included in existing pipelines dedicated to predict the value of fiat currencies.

## Project

### Data collection and processing

#### EUR/USD exchange rate

I have obtained the EUR/USD exchange rate from the webpage of the [European Central Bank](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/eurofxref-graph-usd.en.html). In particular, I obtained exchange rates at the end of the day from the launching of the euro (1999) to the end of August 2022. The data format was XML, so I loaded the XML file into python creating dictionaries for each date (`xmltodict.parse`). Then, I obtained tuples with the date and EUR/USD exchange rate in each dictionary, finally converting all the tuples to a Pandas DataFrame. The exchange rate on each day was selected as the response variable or target for this project. 

This dataset was also used to obtain features that could predict the exchange rate of a given day using the EUR pricing of previous days:

- EUR/USD exchange rate of the previous day (`shift` method of Pandas).
- Moving average of the exchange rate in windows including the previous 5, 10, 60 and 120 days (`rolling` method of Pandas). For example, the 5-days moving average of July 10th would consider the exchange rate between July 5th and 9th. For July 11th, it would consider the exchange rate between July 6th and 10th, and so on...
- Exponential moving average which gives more weight to recent observations (`ewm` method of Pandas).

The implementation of these steps along with step-by-step explanations can be found in the first notebook ([`01_data_preparation_eur_pricing.ipynb`](/scripts/01_data_preparation_eur_pricing.ipynb)).

#### Twitter sentiment around EUR and USD

I obtained tweets about the ECB, its presidents over the last years and the economy of European Union countries using the euro. In this way, I attempted to cover the expectations around key aspects determining the value of the euro as explained in the [Introduction](https://github.com/dtortosa/capstone_project#introduction). I also obtained tweets about the Federal Reserve (i.e., the central bank of the US) in order to get the sentiment around the US dollar (USD), given this currency is the direct competitor of the euro and its value will influence the EUR/USD exchange rate. This dataset included tweets from 2008 and 2009 for the EUR and USD, respectively. To download them, I used [SNScrape](https://github.com/JustAnotherArchivist/snscrape), a Python program dedicated to scrape data from social networks like Twitter. See the second notebook of my GitHub repository for further details ([`02a_data_preparation_scrapping_tweets.ipynb`](/scripts/02a_data_preparation_scrapping_tweets.ipynb)).

Tweets were obtained in json format and loaded into Python as Pandas DataFrames with a custom function that used the `read_json` Pandas method. This was parallelized across multiple cores with `multiprocessing` in order to speed up the loading of this data, which totaled to **13 GB**. Then, I processed the tweets by removing duplicates (i.e., the exact same tweet found in different searches; `drop_duplicates` Pandas method) and tweets in languages other than English, leading to a total of **3.6 millions of tweets**.

Each of these tweets was then cleaned (removing URLs, "#", etc...) with a custom function and then its sentiment was estimated using VADER from the Python package `vaderSentiment`. This generated a compound sentiment of the tweet considering positive, negative and neutral sentiment. Again, this was parallelized with a custom function in order to reduce the computation time.

I performed additional operations on this data in order to obtain metrics summarizing the sentiment of all tweets per day. For example, the average sentiment of all tweets of a given day, the median, standard deviation, etc... With the purpose of really testing the predictive power of Twitter, sentiment I created a function that calculates the mean, median, variance, sd.... of all tweets of a previous day. In other words, **I used Twitter sentiment to predict future EUR pricing**. For example, the average sentiment for all tweets 2 days ago. I calculated a total of **20 summary statistics** across the 15 previous days to each day. In order words, for each day, I calculated the average sentiment (and the other 19 metrics) during the previous day, then 2 days ago, 3, and so on... Each date was run independently in a different core in order to reduce computation time. Using this approach, I generated a battery of 600 predictors, 300 for the sentiment of tweets about EUR and 300 for tweets about USD. 

More details and the implementation of these steps can be found in the third ([`02b_data_preparation_twitter_sentiment_eur.ipynb`](/scripts/02b_data_preparation_twitter_sentiment_eur.ipynb)) and fourth notebooks ([`02c_data_preparation_twitter_sentiment_usd.ipynb`](/scripts/02c_data_preparation_twitter_sentiment_usd.ipynb)) for EUR and USD sentiment, respectively.

### Modeling

The EUR/USD exchange ratio, the EUR predictors and the Twitter sentiment predictors were all merged into one single dataset per date. This included data for all the variables over the past **9 years**. I used this dataset to model the EUR/USD exchange rate of a given day as a function of the previous EUR pricing and Twitter sentiment. 

#### Selection of the regressor

Initially, I ran multiple regressors that are recommended for this type of regression problem ([Scikit learn flowchart](https://scikit-learn.org/stable/tutorial/machine_learning_map/index.html)). I used the `scikit-learn` Python library for all models. As I did not have a priori reasons to think that just a few or many features were important, I tried models recommended in each of these scenarios. I used cross validation by randomly splitting the data in multiple train-test sets with `ShuffleSplit`. Then I used `cross_val_score` to calculate the average R<sup>2</sup> across the test sets. I used models with all predictors, but also models with only EUR-pricing features and with only Twitter sentiment features. I tested multiple regressors:

- [Lasso](https://scikit-learn.org/stable/modules/linear_model.html#lasso)
- [Elastic-Net](https://scikit-learn.org/stable/modules/linear_model.html#elastic-net)
- [Ridge](https://scikit-learn.org/stable/modules/linear_model.html#ridge-regression)
- [Supporting Vector Machines](https://scikit-learn.org/stable/modules/svm.html#regression)
- [Random Forest](https://scikit-learn.org/stable/modules/ensemble.html#random-forests)
- [Extra Trees](https://scikit-learn.org/stable/modules/ensemble.html#extremely-randomized-trees)
- [Gradient Tree Boosting](https://scikit-learn.org/stable/modules/ensemble.html#gradient-tree-boosting)
- [Voting Regressor](https://scikit-learn.org/stable/modules/ensemble.html#voting-regressor)

All these regressors were run with default parameters being extra trees regressors the ones showing the highest R<sup>2</sup> in the test sets in general. Therefore, this regressor was used in subsequent analyses.

#### Optimization of the selected regressor

I then performed a random grid search (`RandomizedSearchCV`) to find the best combination of 6 hyperparameters (`n_estimators`, `min_samples_split`, `min_samples_leaf`, `max_features`, `max_depth`, `bootstrap`). This was done separately for the full model (EUR pricing + Twitter sentiment), EUR-only model and Twitter-only model. The optimized models were used to fit and predict the EUR/USD exchange rate in the whole dataset. Features importance and observed vs. predicted EUR/USD exchange rate were then visualized. All these models were compared between them and with the simplest model possible, which assumes that the current EUR/USD exchange rate is equal to the exchange rate of the previous day.

All these modeling steps along with the corresponding results are shown in the last notebook ([`03_predicting_exchange_rate.ipynb`](/scripts/03_predicting_exchange_rate.ipynb)).

## Results

The simplest model with just the previous EUR pricing and without any modeling approach (i.e., current pricing is the same than the previous day) had a high predictive power (R<sup>2</sup> = 0.9968). This may be explained by the fact that euro pricing changes but at a slow pace, being the value of the previous day a very good predictor. Indeed, the previous pricing is the most important feature in all the models (see the [last notebook](/scripts/03_predicting_exchange_rate.ipynb) for all plots about feature importance) and, as expected, there is a clear correlation between EUR/USD exchange rate and the value of the previous day.

<p align="center">
  <img src="https://github.com/dtortosa/capstone_project/blob/main/results/figures/eur_pricing_vs_previous_day.jpg" />
</p>

When predicting in the test sets, the extra tree regressors showed a very high predictive power having the full model (EUR pricing + Twitter sentiment) the highest R<sup>2</sup> (R<sup>2</sup> = 0.9966). This suggests that the performance of the Twitter-based models is not caused just by an increase of predictors and overfitting. Note that this predictive power was still below the simplest model. However, the extra tree regressors surpassed the simplest model when fitted to the whole dataset, having again the full model the highest predictive power (R<sup>2</sup> = 0.9993), followed by the Twitter-only model (R<sup>2</sup> = 0.9989) and the EUR-only model (R<sup>2</sup> = 0.9982). It is worth to highlight that adding the Twitter sentiment increased the R<sup>2</sup> by **0.11%**, a small increase but still relevant given the already high predictive power used as baseline. In addition, the model considering **only** the Twitter sentiment in the previous 15 days had a remarkable high predictive power.

<p align="center">
  <img src="https://github.com/dtortosa/capstone_project/blob/main/results/figures/eur_predictions_final_models.jpg" />
</p>

These results support the potential of public Twitter sentiment to capture the expectations around the Euro and improve the predictions of EUR/USD exchange rate. It could also be useful to improve the prediction of other fiat currencies, maybe even more useful for those exhibiting higher instability and thus being less influenced by the pricing of the previous day. Note that here I found an improved prediction using Twitter sentiment of the previous 15 days. Therefore, it may be the case that rapid changes in the expectations around a less stable currency could be detected in twitter, anticipating short-term changes in the value of the currency. 

This approach can be included in existing pipelines dedicated to predict EUR and other fiat currencies in order to improve prediction and increase the probabilities of more beneficial exchange rates. The step-by-step explanations in all the notebooks will make the implementation easier. The different notebooks are ordered following the steps of this project and stored in the `script` folder of this repository:

- [`01_data_preparation_eur_pricing.ipynb`](scripts/01_data_preparation_eur_pricing.ipynb)
- [`02a_data_preparation_scrapping_tweets.ipynb`](scripts/02a_data_preparation_scrapping_tweets.ipynb)
- [`02b_data_preparation_twitter_sentiment_eur.ipynb`](scripts/02b_data_preparation_twitter_sentiment_eur.ipynb)
- [`02c_data_preparation_twitter_sentiment_usd.ipynb`](scripts/02c_data_preparation_twitter_sentiment_usd.ipynb)
- [`03_predicting_exchange_rate.ipynb`](scripts/03_predicting_exchange_rate.ipynb)