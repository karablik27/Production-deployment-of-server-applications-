CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

INSERT INTO users (name, email) VALUES
    ('Алексей', 'alex@example.com'),
    ('Елена', 'elena@example.com'),
    ('Иван', 'ivan@example.com');