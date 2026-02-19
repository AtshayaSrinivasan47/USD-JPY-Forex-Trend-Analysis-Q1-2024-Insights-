with daily_sales as (
select o.order_id,
        o.order_date,
        c.customer_id,
        c.customer_name,
        c.region,
        c.account_manager,
        p.product_name,
        p.category,
        o.quantity,
        o.amount,
        o.status
from orders o
inner join customers c on c.customer_id=o.customer_id
inner join products p  on p.product_id = o.product_id
where o.order_date='2026-02-03'
),
regional_sales as (
select region,
	   account_manager,
	   count(*) as regional_total_orders,
	   sum(amount) as regional_total_revenue,
	   ROUND(AVG(amount),2) as regional_avg_order_value
from daily_sales
group by region, account_manager
),
overall_summary as (
select count(*) as total_orders,
	   sum(amount) as total_revenue,
	   ROUND(AVG(amount),2) as avg_order_value,
	   max(amount) as mac_order,
	   min(amount) as min_order
from daily_sales
)
select
	ds.*,
	rs.regional_total_orders,
	rs.regional_total_revenue,
	rs.regional_avg_order_value,
	os.total_orders as company_total_orders,
	os.total_revenue as company_total_revenue
from daily_sales ds
left join regional_sales rs
	on ds.region=rs.region
	and ds.account_manager=rs.account_manager
cross join overall_summary os
order by ds.amount desc;