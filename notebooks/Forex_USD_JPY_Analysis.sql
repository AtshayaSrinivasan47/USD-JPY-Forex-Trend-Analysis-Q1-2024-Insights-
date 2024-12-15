use forex;

select * from Forex_Data;

---What is the average closing price of USD/JPY for each month in the dataset?

select Format(Date,'yyyy-MM') as Year_Month, avg(Price_Rate) as average_closing_rate
from Forex_Data
GROUP BY Format(Date,'yyyy-MM')
ORDER BY Year_Month;


---Which day had the highest single-day percentage change?

select Date, Price_Rate,Change as percentage_change
from Forex_Data
where Change=(select max(Change) From Forex_Data)

--- Which date had the highest intraday price spread (High - Low)?
select Date, High_Rate, Low_Rate, (High_Rate-Low_Rate) as max_intraday_spread
from Forex_Data
where High_Rate-Low_Rate=(select max(High_Rate-Low_Rate) from Forex_Data)

---How many days did the price fall below the support level of 151.50 
--or exceed the resistance level of 154.00?

select count(*)
from Forex_Data
where Price_Rate<151.50

select count(*) as days_above_resistance_level
from Forex_Data
where Price_Rate>154.00

select sum(case when Price_Rate<151.50 then 1 else 0 end) as day_below_support,
	   sum(case when Price_Rate>154.00 then 1 else 0 end) as day_above_resistance
from Forex_Data;

---Compute the 7-day rolling average of closing prices.
select Date,
	   Price_Rate as closing_Price,
	   AVG(Price_Rate) over(
	   order by Date
	   ROWS BETWEEN 6 PRECEDING and current ROW) as Seven_day_Rolling_average
from Forex_Data
order by Date;

---How many consecutive days was the price increasing or decreasing?

with Price_Change as(select
	Date,
	Price_Rate,
	LAG(Price_Rate) over (order by Date) as Previous_Rate,
	CASE
		when Price_Rate > LAG(Price_Rate) OVER (ORDER BY Date) THEN 'Increasing'
		when Price_Rate < LAG(Price_Rate) OVER (ORDER BY Date) THEN 'Decreasing'
		Else 'no change'
	End AS Trend
	FROM Forex_Data
),
Trend_Group as(select Date,Price_Rate, Trend,
			ROW_NUMBER() over (order by Date)
			- ROW_NUMBER() over (Partition by Trend order by Date) as Trend_Group_Id
			From Price_Change
)
select Trend,
	count(*) as Consecutive_Days,
	MIN(Date) as Start_Date,
	Max(Date) as End_Date
From Trend_Group
Group by Trend, Trend_Group_Id
order by Consecutive_Days Desc;

--- What is the average daily price change (absolute value of Change %) over the entire dataset?

select AVG(ABS(Change)) as avg_daily_price_change
from Forex_Data

---- On which days did the price cross both the support and resistance levels in a single day?
select Date, Low_Rate, High_Rate
from Forex_Data
where Low_Rate<151.50 and High_rate>154.00


---- Which month had the highest total trading range (sum of daily high-low spreads)?
select TOP 10
	   Format(Date,'yyyy-MM') as Highest_Trading_Range_Month_Year,
	   sum(High_Rate-Low_Rate) as Trading_Range
from Forex_Data
Group by Format(Date,'yyyy-MM')
order by Trading_Range desc;


