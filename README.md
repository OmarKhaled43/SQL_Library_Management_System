# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
SELECT * 
FROM members

UPDATE members
SET member_address = '157 Main St'
WHERE member_id = 'c101'
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
SELECT * 
FROM issued_status

DELETE FROM issued_status
WHERE issued_id = 'IS121'
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_member_id,
COUNT(issued_member_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_member_id) > 1
```

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 6. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

7. **Task 7: Find Total Rental Income by Category**:

```sql
SELECT b.category,
SUM(b.rental_price),
COUNT(*)
FROM issued_status AS ist
LEFT JOIN books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY category
```

8. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, -180, (SELECT MAX(reg_date) FROM members))
```

9. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
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
LEFT JOIN branch AS b
ON e.branch_id = b.branch_id
JOIN employees AS e1
ON b.manager_id = e1.emp_id
```

Task 10. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
SELECT * 
INTO PriceAbove7
FROM books
WHERE rental_price > 7
```

Task 11: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT *
FROM issued_status as ist
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE return_id is null
```

**Task 12: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT ist.issued_member_id,
m.member_name,
b.book_title,
ist.issued_date,
DATEDIFF(DAY, ist.issued_date, CAST(GETDATE() AS DATE)) AS over_dues_days
FROM issued_status AS ist
JOIN members AS m
ON m.member_id = ist.issued_member_id
JOIN books AS b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE  rs.return_date is null and DATEDIFF(DAT, ist.issued_date, CAST(GETDATE() AS DATE)) > 30
ORDER BY 1;
```

**Task 13: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 14: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
SELECT DISTINCT ist.issued_member_id,
m.member_name,
COUNT(issued_id) AS #IssuedBooks
FROM issued_status AS ist
LEFT JOIN members AS m
ON ist.issued_member_id = m.member_id
WHERE issued_date >= DATEADD(DAY, -15, (SELECT MAX(issued_date) FROM issued_status))
GROUP BY ist.issued_member_id, m.member_name
ORDER BY 3 DESC
```


**Task 15: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

**Task 16: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
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
```

**Task 17: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 15 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
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
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## Author - Omar Khaled Mohamed

This project showcases SQL skills essential for database management and analysis.

LinkedIn: (www.linkedin.com/in/omar-khaled-b37465167)

Email Address: (mandomemo613@gmail.com)
