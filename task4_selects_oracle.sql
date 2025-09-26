SELECT COUNT(*) AS total_books FROM books;

SELECT COUNT(DISTINCT publisher) AS distinct_publishers FROM books;

SELECT SUM(NVL(copies,0)) AS total_copies FROM books;

SELECT ROUND(AVG(NVL(copies,0)),2) AS avg_copies_per_book FROM books;

SELECT MIN(published_year) AS earliest_year, MAX(published_year) AS latest_year FROM books;

SELECT NVL(publisher,'(Unknown)') AS publisher, SUM(NVL(copies,0)) AS total_copies
FROM books
GROUP BY NVL(publisher,'(Unknown)')
ORDER BY total_copies DESC;

SELECT a.author_id, a.name AS author_name, COUNT(b.book_id) AS titles_count
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
LEFT JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id, a.name
ORDER BY titles_count DESC, a.name;

SELECT m.member_id, m.name AS member_name, COUNT(br.borrow_id) AS borrow_count
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
GROUP BY m.member_id, m.name
ORDER BY borrow_count DESC, m.name;

SELECT ROUND(AVG(return_date - borrow_date),2) AS avg_borrow_days
FROM borrowings
WHERE status = 'returned' AND return_date IS NOT NULL;

SELECT NVL(publisher,'(Unknown)') AS publisher, COUNT(*) AS titles_count
FROM books
GROUP BY NVL(publisher,'(Unknown)')
HAVING COUNT(*) > 1
ORDER BY titles_count DESC;

SELECT a.author_id, a.name AS author_name, COUNT(b.book_id) AS titles_count, SUM(NVL(b.copies,0)) AS total_copies
FROM authors a
JOIN book_authors ba ON a.author_id = ba.author_id
JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id, a.name
HAVING COUNT(b.book_id) > 1
ORDER BY titles_count DESC, total_copies DESC;

SELECT COUNT(*) AS currently_borrowed FROM borrowings WHERE status = 'borrowed';

WITH total AS (SELECT SUM(NVL(copies,0)) AS grand_total FROM books)
SELECT NVL(publisher,'(Unknown)') AS publisher,
       SUM(NVL(copies,0)) AS total_copies,
       ROUND(100 * SUM(NVL(copies,0)) / NULLIF((SELECT grand_total FROM total),0),2) AS pct_of_total
FROM books
GROUP BY NVL(publisher,'(Unknown)')
ORDER BY total_copies DESC;