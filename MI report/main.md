# SQL-Based Business Intelligence Framework for USD-JPY Forex Analysis

##USD-JPY Forex Data Warehouse – Data Dictionary

This document describes the structure, purpose, and business meaning of each column in the USD-JPY Forex Data Warehouse. The model follows a star schema design with fact and dimension tables, optimised for analytical SQL, MI reporting, and BI dashboards.

###1. fact_forex_rates

Grain: One row per trading day per currency pair (USD-JPY)

Column Name	Data Type	Description
date_key	DATE (PK)	Trading date (business day). Acts as the primary key and joins to all dimension tables.
currency_pair	VARCHAR(10)	Currency pair identifier (e.g., USDJPY).
open_price	DECIMAL(10,5)	Opening exchange rate for the trading day.
high_price	DECIMAL(10,5)	Highest exchange rate reached during the day.
low_price	DECIMAL(10,5)	Lowest exchange rate reached during the day.
close_price	DECIMAL(10,5)	Closing exchange rate for the trading day.
volume	BIGINT	Estimated trading volume for the day.
daily_return	DECIMAL(8,5)	Percentage return calculated from the previous day’s close.
volatility_20d	DECIMAL(8,5)	20-day rolling standard deviation of daily returns (risk proxy).
created_timestamp	TIMESTAMP	Record creation timestamp for audit and lineage tracking.

####Business Use:

1. Core fact table for price analysis, returns, and volatility

2. Used for trend analysis, risk metrics, and performance reporting

###2. dim_economic_indicators

Grain: One row per trading day

Column Name	Data Type	Description
date_key	DATE (PK)	Trading date, aligned with fact_forex_rates.
us_10y_yield	DECIMAL(6,3)	US 10-year government bond yield (%).
jp_10y_yield	DECIMAL(6,3)	Japan 10-year government bond yield (%).
yield_spread	DECIMAL(6,3)	Difference between US and Japan 10Y yields (carry trade driver).
us_inflation_rate	DECIMAL(5,2)	US inflation rate (%).
jp_inflation_rate	DECIMAL(5,2)	Japan inflation rate (%).
us_unemployment_rate	DECIMAL(4,2)	US unemployment rate (%).
jp_unemployment_rate	DECIMAL(4,2)	Japan unemployment rate (%).
fed_funds_rate	DECIMAL(5,2)	US Federal Funds target rate (%).
boj_policy_rate	DECIMAL(5,2)	Bank of Japan policy interest rate (%).

####Business Use:

1. Explains macroeconomic drivers of USD-JPY movements

2. Supports fundamental and carry-trade analysis

###3. dim_market_sentiment

Grain: One row per trading day

Column Name	Data Type	Description
date_key	DATE (PK)	Trading date.
vix_level	DECIMAL(6,2)	CBOE Volatility Index level (market fear gauge).
dxy_index	DECIMAL(8,3)	US Dollar Index value.
risk_sentiment	VARCHAR(20)	Market regime classification: RISK_ON, RISK_OFF, NEUTRAL.
news_sentiment_score	DECIMAL(3,2)	Normalised news sentiment score (-1 to +1).
social_sentiment_score	DECIMAL(3,2)	Normalised social media sentiment score (-1 to +1).

####Business Use:

1. Identifies risk regimes affecting FX flows

2. Used for sentiment-driven strategy analysis

###4. dim_technical_indicators

Grain: One row per trading day

Column Name	Data Type	Description
date_key	DATE (PK)	Trading date.
sma_20	DECIMAL(10,5)	20-day simple moving average of closing price.
sma_50	DECIMAL(10,5)	50-day simple moving average of closing price.
sma_200	DECIMAL(10,5)	200-day simple moving average of closing price.
rsi_14	DECIMAL(5,2)	14-day Relative Strength Index (momentum indicator).
macd_line	DECIMAL(8,5)	MACD line (12-day EMA – 26-day EMA).
macd_signal	DECIMAL(8,5)	MACD signal line (9-day EMA of MACD).
bollinger_upper	DECIMAL(10,5)	Upper Bollinger Band (20-day SMA + 2σ).
bollinger_lower	DECIMAL(10,5)	Lower Bollinger Band (20-day SMA – 2σ).
support_level	DECIMAL(10,5)	Recent 20-day support price level.
resistance_level	DECIMAL(10,5)	Recent 20-day resistance price level.

####Business Use:

1. Technical analysis and signal generation

2. Used for trend, momentum, and breakout strategies

###5. fact_trading_performance

Grain: One row per executed trade

Column Name	Data Type	Description
trade_id	SERIAL (PK)	Unique identifier for each trade.
date_key	DATE (FK)	Trade execution date, joins to date_key.
entry_price	DECIMAL(10,5)	Price at which the trade was opened.
exit_price	DECIMAL(10,5)	Price at which the trade was closed.
position_size	DECIMAL(12,2)	Trade notional or position size.
trade_pnl	DECIMAL(12,2)	Profit or loss realised from the trade.
trade_duration_days	INTEGER	Number of days the position was held.
trade_type	VARCHAR(10)	Direction of trade: LONG or SHORT.
strategy_name	VARCHAR(50)	Trading strategy used for the trade.
risk_reward_ratio	DECIMAL(4,2)	Risk-to-reward ratio of the trade.

####Business Use:

1. Strategy performance evaluation

2. Risk, PnL attribution, and trade analytics

###6. Design Notes

1. All tables join via date_key to ensure time-series consistency

2. Schema supports window functions, CTEs, and BI tools

3. Designed for PostgreSQL but portable to Snowflake or BigQuery

###7. Intended Use Cases

1. SQL-based MI and performance reporting

2. Power BI / Tableau dashboards
