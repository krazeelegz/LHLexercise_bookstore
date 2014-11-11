## 1 => Fetch ISBN of all book editions published by the publisher "Random House". You should have 3 results.

SELECT isbn FROM editions WHERE publisher_id = 59;

## 2 => Instead of just their ISBN number, fetch their Book Title as well.

## (A)

SELECT isbn, title 
  FROM editions e JOIN books b 
  ON (e.book_id = b.id)
  WHERE publisher_id = 59;

#     isbn    |            title
# ------------+-----------------------------
#  0394900014 | The Cat in the Hat
#  039480001X | The Cat in the Hat
#  0394800753 | Bartholomew and the Oobleck
# (3 rows)


## (B)

SELECT e.isbn, b.title
  FROM editions e JOIN publishers p
  ON e.publisher_id = p.id
  JOIN books b
  ON e.book_id = b.id
  WHERE p.name = 'Random House';

#     isbn    |            title
# ------------+-----------------------------
#  0394900014 | The Cat in the Hat
#  039480001X | The Cat in the Hat
#  0394800753 | Bartholomew and the Oobleck
#  (3 rows)


## 3 => Also include their stock information (available stock and retail price for each book edition).  
## You should still have the same 3 results but with more information. But instead of just 2 columns, 
## we should have 4 columns in the result set.

# output -> available stock (STOCK) and retail price, title, isbn

SELECT b.title, e.isbn, s.stock, s.retail
  FROM editions e, publishers p, books b, stock s
  WHERE (p.id = e.publisher_id)
  AND p.name = 'Random House'
  AND (b.id = e.book_id)
  AND (s.isbn = e.isbn);

#        title            |    isbn    | stock | retail
# -----------------------------+------------+-------+--------
#  The Cat in the Hat          | 039480001X |    31 |  32.95
#  Bartholomew and the Oobleck | 0394800753 |     4 |  16.95
#  The Cat in the Hat          | 0394900014 |     0 |  23.95
# (3 rows)

## 4 => Now modify above query so that it only returns books that are in stock (stock > 0)

SELECT books.title, editions.isbn, stock.stock, stock.retail
  FROM editions, publishers, books, stock 
  WHERE (publishers.id = editions.publisher_id)
  AND publishers.name = 'Random House'
  AND (books.id = editions.book_id)
  AND (stock.isbn = editions.isbn)
  AND stock > 0;

#    title            |    isbn    | stock | retail
# -----------------------------+------------+-------+--------
#  The Cat in the Hat          | 039480001X |    31 |  32.95
#  Bartholomew and the Oobleck | 0394800753 |     4 |  16.95
# (2 rows)

## 5 => Hardcover vs Paperback. Editions has a column called "type". Include the print type but instead 
## of just displaying "h" or "p" (the values in the column) output the human readable types 
## ("hardcover" and "paperback" accordingly). Hint: Use a CASE statement to manipulate your result set, as in this example.

SELECT books.title, editions.isbn, stock.stock, stock.retail,
  CASE
    WHEN type = 'p' THEN 'paperback'
    WHEN type = 'h' THEN 'hardcover'
  END AS cover_type
  FROM books, editions, stock, publishers
    WHERE publishers.id = editions.publisher_id
    AND publishers.name = 'Random House'
    AND books.id = editions.book_id
    AND stock.isbn = editions.isbn
    AND stock > 0;

#     title            |    isbn    | stock | retail | cover_type
# -----------------------------+------------+-------+--------+------------
#  The Cat in the Hat          | 039480001X |    31 |  32.95 | hardcover
#  Bartholomew and the Oobleck | 0394800753 |     4 |  16.95 | paperback
# (2 rows)

## 6 => List all book titles along with their publication dates (column on the editions dates) 
## That's 2 columns: "title" and "publication"

SELECT b.title, e.publication 
FROM books b JOIN editions e ON
(b.id = e.book_id);

#   title            | publication
# -----------------------------+-------------
# The Cat in the Hat          | 1957-03-01
# The Shining                 | 1981-08-01
# Bartholomew and the Oobleck | 1949-03-01
# Franklin in the Dark        | 1987-03-01
# Goodnight Moon              | 1947-03-04
# The Velveteen Rabbit        | 1922-01-01
# Little Women                | 1868-01-01
# The Cat in the Hat          | 1957-01-01
# The Shining                 | 1993-10-01
# The Tell-Tale Heart         | 1995-03-28
# The Tell-Tale Heart         | 1998-12-01
# Dune                        | 1998-09-01
# Dune                        | 1999-10-01
# 2001: A Space Odyssey       | 2000-09-12
# 2001: A Space Odyssey       | 1999-10-01
# Dynamic Anatomy             | 1958-01-01
# Programming Python          | 2001-03-01
# (17 rows)

## 7 => What's the total inventory of books in this library (i.e. how many total copies are in stock)?

SELECT SUM(stock)
FROM stock;

#  sum
# -----
#  512
# (1 row)

## total number of books in stock

SELECT COUNT(*) AS total FROM stock;

# total
# -------
#  16
# (1 row)

## total different titles in stock. They have 16 books for sale, with 512 copies between them

## 8 => What is the overall average cost and retail price for all books for sale? Return three columns 
## "Average cost", "Average Retail" and "Average Profit"

SELECT ROUND(AVG(cost),2) AS average_cost, 
       ROUND(AVG(retail),2) AS average_price,
       ROUND(AVG(retail - cost),2) AS average_profit
  FROM stock;

#  average_cost | average_price | average_profit
# --------------+---------------+----------------
#         23.88 |         28.45 |           4.58
# (1 row)

## 9 => Which book ID has the most pieces in stock?

SELECT book_id
FROM stock, editions
## both tables have isbns so we connect/join using these
WHERE stock.isbn = editions.isbn
## orders in descending by amount of stock per book_id
ORDER BY stock.stock DESC
## limits the returned query to one instance (the book_id with most in stock)
LIMIT 1;

# book_id
# ---------
#   4513
# (1 row)

## 10 and 11 => List author ID along with the full name and the number of books they have written. 
## Output 3 columns: "ID", "Full name" and "Number of Books"

##(need tables => author(all columns), books(author_id))

SELECT COUNT(books.author_id) AS number_of_books_written,
  CONCAT(authors.id, ': ', authors.first_name, ' ', authors.last_name) AS author_full_name
  FROM books, authors
  WHERE authors.id = books.author_id
  GROUP BY authors.id
  ## puts author with most books written at top
  ORDER BY COUNT(books.author_id) DESC;

# number_of_books_written |        author_full_name
#-------------------------+--------------------------------
#                       2 | 7805: Mark Lutz
#                       1 | 1644: Burne Hogarth
#                       1 | 115: Edgar Allen Poe
#                       1 | 4156: Stephen King
#                       1 | 2001: Arthur C. Clarke
#                       1 | 1212: John Worsley
#                       1 | 7806: Tom Christiansen
#                       1 | 25041: Margery Williams Bianco
#                       1 | 2031: Margaret Wise Brown
#                       1 | 15990: Paulette Bourgeois
#                       1 | 1866: Frank Herbert
#                       1 | 16: Louisa May Alcott
# (12 rows)

## (or, by last_name only... a little more concise)

SELECT authors.last_name, authors.id, COUNT(books.id)
  FROM books
  JOIN authors ON books.author_id = authors.id
  GROUP BY authors.id;

# last_name   |  id   | count
# --------------+-------+-------
# Herbert      |  1866 |     1
# Hogarth      |  1644 |     1
# Poe          |   115 |     1
# King         |  4156 |     1
# Clarke       |  2001 |     1
# Worsley      |  1212 |     1
# Christiansen |  7806 |     1
# Bianco       | 25041 |     1
# Brown        |  2031 |     1
# Lutz         |  7805 |     2
# Bourgeois    | 15990 |     1
# Alcott       |    16 |     1
# (12 rows)

## 12 => List books that have both paperback and hardcover editions. That means at 
## least one edition of the book in both formats. Returns 4 books.

SELECT b.title
  FROM books b JOIN editions e 
  ON (b.id = e.book_id)
  WHERE e.type = 'h'
INTERSECT
SELECT bb.title
  FROM books bb JOIN editions ee
  ON (bb.id = ee.book_id)
  WHERE ee.type = 'p';

#  title
# -----------------------
#  2001: A Space Odyssey
#  The Shining
#  Dune
# The Cat in the Hat
# (4 rows)

## 13 => For each publisher, list their average book sale price, number of editions published.

SELECT publishers.name AS publisher_name,
  ROUND(AVG(stock.retail), 2) AS avg_price,
  COUNT(editions.edition) AS number_of_editions
    FROM publishers, editions, stock
    WHERE (publishers.id = editions.publisher_id)
    AND (editions.isbn = stock.isbn)
    GROUP BY publishers.name;

#       publisher_name        | avg_price | number_of_editions
#-----------------------------+-----------+--------------------
# Roc                         |     34.95 |                  2
# Henry Holt & Company, Inc.  |     23.95 |                  1
# Doubleday                   |     32.95 |                  2
# Penguin                     |     24.95 |                  1
# Mojo Press                  |     24.95 |                  1
# Ace Books                   |     33.95 |                  2
# HarperCollins               |     28.95 |                  1
# Random House                |     24.62 |                  3
# Kids Can Press              |     23.95 |                  1
# Watson-Guptill Publications |     28.95 |                  1
# Books of Wonder             |     21.95 |                  1
#(11 rows)
