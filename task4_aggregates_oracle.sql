
-- task4_aggregates_oracle.sql
-- Task 4: Aggregate functions and grouping (Oracle)
SET DEFINE OFF;

-- 0) Quick check: confirm tables exist (optional)
SELECT table_name FROM user_tables
WHERE table_name IN ('BOOKS','AUTHORS','BOOK_AUTHORS','MEMBERS','BORROWINGS')
ORDER BY table_name;

-- 1) COUNT total books
-- Purpose: overall count of rows in books
SELECT COUNT(*) AS total_books
FROM books;

-- 2) COUNT distinct publishers
-- Purpose: how many different publishers
SELECT COUNT(DISTINCT publisher) AS distinct_publishers
FROM books;

-- 3) SUM of copies (total number of physical book copies)
-- Purpose: total inventory
SELECT SUM(NVL(copies,0)) AS total_copies
FROM books;

-- 4) AVG copies per book (average inventory per title)
-- Purpose: average measure; NVL to ignore NULL properly
SELECT ROUND(AVG(NVL(copies,0)),2) AS avg_copies_per_book
FROM books;

-- 5) MIN / MAX published year (range of publication years)
-- Purpose: earliest and latest year present
SELECT MIN(published_year) AS earliest_year,
       MAX(published_year) AS latest_year
FROM books;

-- 6) Total copies grouped by publisher (SUM + GROUP BY)
-- Purpose: inventory per publisher; show publishers even if NULL
SELECT NVL(publisher,'(Unknown)') AS publisher,
       SUM(NVL(copies,0)) AS total_copies
FROM books
GROUP BY NVL(publisher,'(Unknown)')
ORDER BY total_copies DESC;

-- 7) Number of book titles per author (JOIN + COUNT + GROUP BY)
-- Purpose: how many titles each author has (many-to-many handled through book_authors)
SELECT a.author_id,
       a.name AS author_name,
       COUNT(b.book_id) AS titles_count
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
LEFT JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id, a.name
ORDER BY titles_count DESC, a.name;

-- 8) Borrowings count per member (COUNT + GROUP BY)
-- Purpose: find most active borrowers
SELECT m.member_id,
       m.name AS member_name,
       COUNT(br.borrow_id) AS borrow_count
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
GROUP BY m.member_id, m.name
ORDER BY borrow_count DESC, m.name;

-- 9) Average borrow duration (in days) for returned books
-- Purpose: measure typical loan length; use only returned rows (return_date not null)
-- Note: date subtraction returns number; AVG over that
SELECT ROUND(AVG(return_date - borrow_date),2) AS avg_borrow_days
FROM borrowings
WHERE status = 'returned' AND return_date IS NOT NULL;

-- 10) Publisher groups filtered with HAVING (only publishers with > 1 title)
-- Purpose: show publishers that have multiple book titles
SELECT NVL(publisher,'(Unknown)') AS publisher,
       COUNT(*) AS titles_count
FROM books
GROUP BY NVL(publisher,'(Unknown)')
HAVING COUNT(*) > 1
ORDER BY titles_count DESC;

-- 11) Combined example: average copies per publisher plus number of titles
-- Purpose: summary metrics per publisher
SELECT NVL(publisher,'(Unknown)') AS publisher,
       COUNT(*) AS titles_count,
       ROUND(AVG(NVL(copies,0)),2) AS avg_copies_per_title,
       SUM(NVL(copies,0)) AS total_copies
FROM books
GROUP BY NVL(publisher,'(Unknown)')
ORDER BY total_copies DESC;

-- 12) Grouping with JOIN & HAVING: authors with >1 titles and their total copies
-- Purpose: find prolific authors and inventory tied to them
SELECT a.author_id, a.name AS author_name,
       COUNT(b.book_id) AS titles_count,
       SUM(NVL(b.copies,0)) AS total_copies
FROM authors a
JOIN book_authors ba ON a.author_id = ba.author_id
JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id, a.name
HAVING COUNT(b.book_id) > 1
ORDER BY titles_count DESC, total_copies DESC;

-- 13) Example of COUNT with conditions (count currently borrowed books)
-- Purpose: how many borrowings currently have status = 'borrowed'
SELECT COUNT(*) AS currently_borrowed
FROM borrowings
WHERE status = 'borrowed';

-- 14) Optional: percent contribution of each publisher to total copies
-- Purpose: relative share of inventory per publisher
WITH total AS (
  SELECT SUM(NVL(copies,0)) AS grand_total FROM books
)
SELECT NVL(publisher,'(Unknown)') AS publisher,
       SUM(NVL(copies,0)) AS total_copies,
       ROUND(100 * SUM(NVL(copies,0)) / NULLIF((SELECT grand_total FROM total),0),2) AS pct_of_total
FROM books
GROUP BY NVL(publisher,'(Unknown)')
ORDER BY total_copies DESC;

-- End of script
