-- Task 1. Create a New Book Record  "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address --

SELECT * 
FROM members

UPDATE members
SET member_address = '157 Main St'
WHERE member_id = 'c101'

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table. --

SELECT * 
FROM issued_status

DELETE FROM issued_status
WHERE issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee  Objective: Select all books issued by the employee with emp_id = 'E101'. --

SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book  Objective: Use GROUP BY to find members who have issued more than one book. --

SELECT issued_member_id,
COUNT(issued_member_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_member_id) > 1

-- Task 6: Find Total Rental Income by Category:

SELECT b.category,
SUM(b.rental_price),
COUNT(*)
FROM issued_status AS ist
LEFT JOIN books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY category

-- Tasi 7 List Members Who Registered in the Last 180 Days:

SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, -180, (SELECT MAX(reg_date) FROM members))

-- Task 8 List Employees with Their Branch Manager's id and their branch details

SELECT e.emp_id,
e.emp_name,
e.position,
e.salary,
b.branch_id,
b.manager_id,
e1.emp_name AS MangerName,
b.branch_address,
b.contact_no
FROM employees AS e
left join branch AS b
ON e.branch_id = b.branch_id
join employees AS e1
ON b.manager_id = e1.emp_id

-- Task 9 Create a Table of Books with Rental Price Above a Certain Threshold:

SELECT * 
INTO PriceAbove7
FROM books
WHERE rental_price > 7

-- Task 10: Retrieve the List of Books Not Yet Returned

SELECT *
FROM issued_status as ist
left join return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE return_id is null

-- Task 11: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT ist.issued_member_id,
m.member_name,
b.book_title,
ist.issued_date,
DATEDIFF(DAY, ist.issued_date, CAST(GETDATE() AS DATE)) AS over_dues_days
FROM issued_status AS ist
join members AS m
ON m.member_id = ist.issued_member_id
join books AS b
ON b.isbn = ist.issued_book_isbn
left join return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE  rs.return_date is null and DATEDIFF(DAT, ist.issued_date, CAST(GETDATE() AS DATE)) > 30
ORDER BY 1;

-- Task 12: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

SELECT
b.branch_id,
b.manager_id,
COUNT(ist.issued_id) AS NIssuedBooks,
COUNT(rs.return_id) AS NReturnedBooks,
SUM(bk.rental_price) AS Total_Revenue
INTO Report
FROM issued_status AS ist
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
LEFT JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
LEFT JOIN branch AS b
ON b.branch_id = e.branch_id
LEFT JOIN books AS bk
ON bk.isbn = ist.issued_book_isbn
GROUP BY b.branch_id, b.manager_id
ORDER BY 5 DESC


-- Task 13: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

SELECT DISTINCT ist.issued_member_id,
m.member_name,
COUNT(issued_id) AS #IssuedBooks
FROM issued_status AS ist
LEFT JOIN members AS m
ON ist.issued_member_id = m.member_id
WHERE issued_date >= DATEADD(DAY, -15, (SELECT MAX(issued_date) FROM issued_status))
GROUP BY ist.issued_member_id, m.member_name
ORDER BY 3 DESC

-- Task 14: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT TOP 3 b.branch_id,
b.manager_id,
e.emp_name,
COUNT(issued_id) AS NumberIssuedBooks
FROM issued_status AS ist
LEFT JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
LEFT JOIN branch AS b
ON e.branch_id = b.branch_id
GROUP BY b.branch_id, b.manager_id, e.emp_name
ORDER BY 4 Desc

-- Task 15: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

ALTER TABLE books
ADD bookStatus VARCHAR(15)

UPDATE books
SET bookstatus = 'damage'
WHERE bookstatus is null

UPDATE books
SET bookstatus = 'Good'
WHERE category = 'classic'

SELECT m.member_name,
bk.book_title,
COUNT(issued_id) AS NumberIssedBooks,
bk.bookstatus
FROM issued_status AS ist
LEFT JOIN books AS bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN members AS m
ON m.member_id = ist.issued_member_id
WHERE bk.bookstatus = 'damage'
GROUP BY m.member_name, bk.book_title, bk.bookstatus

-- Task 16: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
-- Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: 
-- The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
-- The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines

SELECT m.member_name,
COUNT(ist.issued_id)
FROM issued_status ist
LEFT JOIN books AS bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN members AS m
ON m.member_id = ist.issued_member_id
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE  DATEDIFF(DAY, issued_date, (SELECT MAX(issued_date) FROM issued_status)) > 15 and rs.return_date is null
GROUP BY m.member_name

