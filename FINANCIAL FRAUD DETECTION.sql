CREATE DATABASE financial_fraud_detect;
USE financial_fraud_detect;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_type ENUM('Checking', 'Savings', 'Credit'),
    balance DECIMAL(15, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer'),
    amount DECIMAL(15, 2) CHECK (amount > 0),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone)
VALUES 
('Alice', 'Smith', 'alice.smith@example.com', '123-456-7890'),
('Bob', 'Brown', 'bob.brown@example.com', '234-567-8901');

-- Insert sample accounts
INSERT INTO accounts (customer_id, account_type, balance)
VALUES
(1, 'Checking', 5000.00),
(1, 'Savings', 15000.00),
(2, 'Checking', 3000.00);

-- Insert sample transactions
INSERT INTO transactions (account_id, transaction_type, amount)
VALUES
(1, 'Deposit', 2000.00),
(1, 'Withdrawal', 1000.00),
(2, 'Transfer', 4000.00),  -- Suspicious due to amount
(3, 'Withdrawal', 1500.00);

-- Identify and flag suspicious transactions
INSERT INTO fraud_flags (transaction_id, flag_reason)
SELECT transaction_id, 'High transaction amount'
FROM transactions
WHERE amount > 3000;
-- examples

SELECT t.transaction_id, t.account_id, t.amount, t.transaction_date, f.flag_reason
FROM transactions t
JOIN fraud_flags f ON t.transaction_id = f.transaction_id;

SELECT c.customer_id, c.first_name, c.last_name, COUNT(f.flag_id) AS flagged_transactions
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
JOIN fraud_flags f ON t.transaction_id = f.transaction_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(f.flag_id) > 1;




