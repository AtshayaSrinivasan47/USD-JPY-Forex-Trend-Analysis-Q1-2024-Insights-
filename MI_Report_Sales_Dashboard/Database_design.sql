---create tables

create table customers(
	customer_id SERIAL primary key,
	customer_name VARCHAR(100) not null,
	region VARCHAR(50),
	account_manager VARCHAR(100)
);

create table products(
	product_id SERIAL primary key,
	product_name varchar(100) not null,
	category VARCHAR(50),
	price DECIMAL(10,2)
);

create table orders(
	order_id SERIAL primary key,
	customer_id INTEGER references customers(customer_id),
	product_id INTEGER references products(product_id),
	order_date DATE not null,
	quantity integer,
	amount DECIMAL(10,2),
	status VARCHAR(20),
	created_at timestamp default current_timestamp
);

---create indexes for better performance

create index idx_orders_date on orders(order_date);
create index idx_orders_customer on orders(customer_id);
create index idx_orders_product on orders(product_id);

-- Insert sample customers
INSERT INTO customers (customer_name, region, account_manager) VALUES
('TechCorp Ltd', 'North', 'John Smith'),
('DataSystems Inc', 'South', 'Jane Doe'),
('CloudNine Co', 'East', 'John Smith'),
('AutoBots Ltd', 'West', 'Sarah Johnson'),
('SmartData Inc', 'North', 'Jane Doe'),
('FutureStack Ltd', 'South', 'John Smith'),
('ByteWorks Inc', 'East', 'Sarah Johnson'),
('CodeCraft Co', 'West', 'Jane Doe');

-- Insert sample products
INSERT INTO products (product_name, category, price) VALUES
('Analytics License', 'Software', 1500.00),
('Consulting Hours', 'Services', 150.00),
('Training Course', 'Education', 500.00),
('Support Package', 'Services', 800.00),
('Data Integration', 'Software', 2000.00),
('Cloud Storage', 'Infrastructure', 300.00);

-- Insert sample orders (including today's data)
INSERT INTO orders (customer_id, product_id, order_date, quantity, amount, status) VALUES
-- Today's orders
(1, 1, CURRENT_DATE, 2, 3000.00, 'Completed'),
(2, 2, CURRENT_DATE, 10, 1500.00, 'Completed'),
(3, 3, CURRENT_DATE, 5, 2500.00, 'Pending'),
(1, 4, CURRENT_DATE, 1, 800.00, 'Completed'),
(4, 5, CURRENT_DATE, 1, 2000.00, 'Completed'),
(5, 6, CURRENT_DATE, 3, 900.00, 'Pending'),
-- Yesterday's orders
(4, 1, CURRENT_DATE - INTERVAL '1 day', 1, 1500.00, 'Completed'),
(5, 2, CURRENT_DATE - INTERVAL '1 day', 8, 1200.00, 'Completed'),
(6, 3, CURRENT_DATE - INTERVAL '1 day', 3, 1500.00, 'Completed'),
-- Last week's orders
(7, 4, CURRENT_DATE - INTERVAL '7 days', 2, 1600.00, 'Completed'),
(8, 5, CURRENT_DATE - INTERVAL '7 days', 1, 2000.00, 'Completed');


---verify data

select count(*) as total_orders from orders;
select count(*) as total_orders_in_current_date from orders where order_date=current_date;