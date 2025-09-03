-- Create new database
CREATE DATABASE regionalsalesdb;
USE regionalsalesdb;

-- 1. Region Table: Stores sales regions (like East, West, North, South)
CREATE TABLE region (
    id INT,
    name VARCHAR(50)
);

-- 2. Sales Reps Table: Stores sales representatives, linked to regions
CREATE TABLE sales_reps (
    id INT,
    name VARCHAR(100),
    region_id INT
);

-- 3. Accounts Table: Stores company accounts (clients/customers), linked to sales reps
CREATE TABLE accounts (
    id INT,
    name VARCHAR(100),
    website VARCHAR(255),
    latitude DECIMAL(10,6),       -- Geographical location
    longitude DECIMAL(10,6),      -- Geographical location
    primary_poc VARCHAR(100),     -- Point of Contact person
    sales_rep_id INT
);

-- 4. Orders Table: Stores orders placed by accounts
CREATE TABLE orders (
    id INT,
    account_id INT,
    occurred_at DATETIME,         -- When the order happened (YYYY-MM-DD HH:MM:SS)
    standard_qty INT DEFAULT 0,
    gloss_qty INT DEFAULT 0,
    poster_qty INT DEFAULT 0,
    total INT,                    -- Total quantity
    standard_amt_usd DECIMAL(10,2) DEFAULT 0.00,
    gloss_amt_usd DECIMAL(10,2) DEFAULT 0.00,
    poster_amt_usd DECIMAL(10,2) DEFAULT 0.00,
    total_amt_usd DECIMAL(12,2)   -- Total amount in USD
);

-- 5. Web Events Table: Tracks marketing/web interactions of accounts
CREATE TABLE web_events (
    id INT,
    account_id INT,
    occurred_at DATETIME,         -- When the event occurred (YYYY-MM-DD HH:MM:SS)
    channel_name VARCHAR(50)      -- Marketing channel (e.g., 'direct', 'adwords', 'facebook')
);
