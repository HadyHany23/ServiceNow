
CREATE TABLE books (
	book_id serial PRIMARY KEY,
	author VARCHAR(50) NOT NULL,
	description TEXT,
	price NUMERIC(10,2),
	copies INT,
	in_stock BOOLEAN DEFAULT FALSE,
	publish_date DATE,
	borrowed TIMESTAMPTZ,
	product JSONB
)


CREATE TABLE categories (
	cat_id serial PRIMARY KEY,
	book_id INT REFERENCES books(book_id)
	cat_name VARCHAR(50) UNI,
	description TEXT,
	price NUMERIC(10,2),
	copies INT,
	in_stock BOOLEAN DEFAULT FALSE,
	publish_date DATE,
	borrowed TIMESTAMPTZ,
	product JSONB
)

ALTER TABLE books ADD COLUMN is_available BOOLEAN DEFAULT FALSE;
