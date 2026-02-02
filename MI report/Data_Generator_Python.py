import pandas as pd
import numpy as np
from faker import Faker

fake=Faker()
np.random.seed(42)

# configuration
START_DATE= "2023-01-01"
END_DATE= "2025-12-31"
CURRENCY_PAIR= "USDJPY"

dates = pd.date_range(start=START_DATE, end=END_DATE, freq="B")
n = len(dates)

# Fact: Forex Rate

price = 140 + np.cumsum(np.random.normal(0, 0.25, n))

fact_forex_rates = pd.DataFrame({
    "date_key": dates,
    "currency_pair": CURRENCY_PAIR,
    "open_price": price,
    "high_price": price + np.random.uniform(0.1, 0.6, n),
    "low_price": price - np.random.uniform(0.1, 0.6, n),
    "close_price": price + np.random.normal(0, 0.15, n),
    "volume": np.random.randint(1_000_000, 5_000_000, n)
})

fact_forex_rates["daily_return"] = fact_forex_rates["close_price"].pct_change()
fact_forex_rates["volatility_20d"] = (
    fact_forex_rates["daily_return"].rolling(20).std()
)

# DIM: Economic Indicators

dim_economic_indicators = pd.DataFrame({
    "date_key": dates,
    "us_10y_yield": np.random.uniform(3.5, 5.0, n),
    "jp_10y_yield": np.random.uniform(0.1, 1.2, n),
    "us_inflation_rate": np.random.uniform(2.5, 4.5, n),
    "jp_inflation_rate": np.random.uniform(0.5, 2.5, n),
    "us_unemployment_rate": np.random.uniform(3.5, 5.0, n),
    "jp_unemployment_rate": np.random.uniform(2.0, 3.5, n),
    "fed_funds_rate": np.random.uniform(4.5, 5.5, n),
    "boj_policy_rate": np.random.uniform(-0.1, 0.2, n)
})

dim_economic_indicators["yield_spread"] = (
    dim_economic_indicators["us_10y_yield"]
    - dim_economic_indicators["jp_10y_yield"]
)

# DIM: Market Sentiment

dim_market_sentiment = pd.DataFrame({
    "date_key": dates,
    "vix_level": np.random.uniform(12, 35, n),
    "dxy_index": np.random.uniform(98, 108, n),
    "risk_sentiment": np.random.choice(
        ["RISK_ON", "RISK_OFF", "NEUTRAL"], n
    ),
    "news_sentiment_score": np.random.uniform(-1, 1, n),
    "social_sentiment_score": np.random.uniform(-1, 1, n)
})

# DIM: Technical Indicators

dim_technical_indicators = pd.DataFrame({"date_key": dates})

dim_technical_indicators["sma_20"] = (
    fact_forex_rates["close_price"].rolling(20).mean()
)
dim_technical_indicators["sma_50"] = (
    fact_forex_rates["close_price"].rolling(50).mean()
)
dim_technical_indicators["sma_200"] = (
    fact_forex_rates["close_price"].rolling(200).mean()
)

delta = fact_forex_rates["close_price"].diff()
gain = delta.clip(lower=0)
loss = -delta.clip(upper=0)

rs = gain.rolling(14).mean() / loss.rolling(14).mean()
dim_technical_indicators["rsi_14"] = 100 - (100 / (1 + rs))

dim_technical_indicators["macd_line"] = (
    fact_forex_rates["close_price"].ewm(span=12).mean()
    - fact_forex_rates["close_price"].ewm(span=26).mean()
)
dim_technical_indicators["macd_signal"] = (
    dim_technical_indicators["macd_line"].ewm(span=9).mean()
)

std_20 = fact_forex_rates["close_price"].rolling(20).std()
dim_technical_indicators["bollinger_upper"] = (
    dim_technical_indicators["sma_20"] + 2 * std_20
)
dim_technical_indicators["bollinger_lower"] = (
    dim_technical_indicators["sma_20"] - 2 * std_20
)

dim_technical_indicators["support_level"] = (
    fact_forex_rates["low_price"].rolling(20).min()
)
dim_technical_indicators["resistance_level"] = (
    fact_forex_rates["high_price"].rolling(20).max()
)

# Fact: Trading Performance

trades = 300

fact_trading_performance = pd.DataFrame({
    "date_key": np.random.choice(dates, trades),
    "entry_price": np.random.uniform(135, 150, trades),
    "exit_price": np.random.uniform(135, 150, trades),
    "position_size": np.random.uniform(10_000, 100_000, trades),
    "trade_duration_days": np.random.randint(1, 30, trades),
    "trade_type": np.random.choice(["LONG", "SHORT"], trades),
    "strategy_name": np.random.choice(
        ["Momentum", "Carry", "Mean Reversion", "Breakout"], trades
    ),
    "risk_reward_ratio": np.random.uniform(0.5, 3.0, trades)
})

fact_trading_performance["trade_pnl"] = (
    (fact_trading_performance["exit_price"]
     - fact_trading_performance["entry_price"])
    * fact_trading_performance["position_size"]
)

# Clean +Export

def clean(df):
    return df.replace([np.inf, -np.inf], np.nan).dropna()

clean(fact_forex_rates).to_csv("fact_forex_rates.csv", index=False)
clean(dim_economic_indicators).to_csv("dim_economic_indicators.csv", index=False)
clean(dim_market_sentiment).to_csv("dim_market_sentiment.csv", index=False)
clean(dim_technical_indicators).to_csv("dim_technical_indicators.csv", index=False)
fact_trading_performance.to_csv("fact_trading_performance.csv", index=False)

print("✅ Dataset generation complete")

