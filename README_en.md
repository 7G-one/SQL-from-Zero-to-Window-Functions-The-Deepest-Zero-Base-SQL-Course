# SQL from Zero: Possibly the Deepest Beginner Course You'll Find

<h3 align="center"><a href="README.md">中文</a> | <a href="README_en.md">English</a></h3>

> 15 lessons + 1 window functions deep-dive, from "what's a database" to "design a complete blog system." Zero prerequisites, no depth compromised.

There are tons of SQL tutorials out there, but most stop at SELECT. This one doesn't. It goes all the way to index internals (B+ trees), transaction isolation levels, SQL injection attack and defense, and finishes with you designing a blog database from scratch. Maximum depth, zero starting point.

## What You'll Actually Learn

### Basics (00-06) -- Learning to Talk to a Database

| Lesson | File | What You'll Do | What You'll Pick Up Along the Way |
|--------|------|----------------|-----------------------------------|
| 00 | `00_零基础入门.sql` | Write your first SQL query | What a database is, what SQL can do, types of databases |
| 01 | `01_数据库基础.sql` | Create databases and tables | Data types, primary keys, constraints (NOT NULL, UNIQUE, etc.) |
| 02 | `02_数据操作(CRUD).sql` | Create, read, update, delete -- the full loop | INSERT/SELECT/UPDATE/DELETE in detail |
| 03 | `03_条件查询.sql` | Find exactly the data you need | WHERE, comparison operators, LIKE, IN/BETWEEN |
| 04 | `04_排序与分页.sql` | Sort results and paginate | ORDER BY, LIMIT/OFFSET, DISTINCT |
| 05 | `05_聚合函数.sql` | Count, sum, average, find max/min | COUNT/SUM/AVG/MAX/MIN, GROUP BY, HAVING |
| 05b | `05b_窗口函数.sql` | Aggregate without collapsing rows | ROW_NUMBER/RANK/DENSE_RANK, LEAD/LAG, SUM() OVER, NTILE |
| 06 | `06_多表查询(上).sql` | Combine data from multiple tables | INNER/LEFT/RIGHT/CROSS JOIN |

### Intermediate (07-12) -- The Inner Workings of Databases

| Lesson | File | What You'll Do | What You'll Pick Up Along the Way |
|--------|------|----------------|-----------------------------------|
| 07 | `07_多表查询(下).sql` | Handle complex table relationships | Self-joins, subqueries, EXISTS, UNION |
| 08 | `08_子查询详解.sql` | Nest queries inside queries | Scalar/row/table/correlated subqueries, performance considerations |
| 09 | `09_索引与性能.sql` | Make queries fly | B+ tree internals, composite indexes, EXPLAIN |
| 10 | `10_视图与存储过程.sql` | Encapsulate common query logic | Views, stored procedures, functions, triggers |
| 11 | `11_事务与并发.sql` | Keep your data consistent | ACID, isolation levels, locking, deadlock handling |
| 12 | `12_数据库设计.sql` | Design databases from requirements | ER diagrams, normalization (1NF-3NF), denormalization |

### Practice (13-14) -- The Real Deal

| Lesson | File | What You'll Do | What You'll Pick Up Along the Way |
|--------|------|----------------|-----------------------------------|
| 13 | `13_安全与注入.sql` | Learn how attackers strike and how you defend | SQL injection mechanics, attack techniques, parameterized queries |
| 14 | `14_项目实战.sql` | Design a complete blog database system | Users, posts, comments, tags -- from zero to complete |

## Learning Path

```
Basics
  00 Getting Started → 01 Database Basics → 02 CRUD
      ↓
  03 Filtering → 04 Sorting & Paging → 05 Aggregation → 05b Window Functions
      ↓
  06 Joins (Part 1)

Intermediate
  07 Joins (Part 2) → 08 Subqueries → 09 Indexes & Performance
      ↓
  10 Views & Stored Procedures → 11 Transactions → 12 Database Design

Practice
  13 Security & Injection → 14 Project
```

## What Makes This Course Different

### This Goes Deeper Than Most SQL Courses

It doesn't stop at SELECT. Window functions, B+ tree index theory, transaction isolation levels, SQL injection attack and defense -- these topics usually live in advanced books, but here they're explained from scratch.

### Real-Life Analogies, No Jargon

- **Database** = a filing cabinet with numbered drawers
- **Table** = one drawer in the cabinet
- **Primary key** = an ID card number, uniquely identifies each row
- **JOIN** = matching records from two different drawers
- **Index** = a book's table of contents -- you can find content without it, but it's faster with it
- **Transaction** = a bank transfer: either both accounts update, or neither does
- **Window function** = calculating a "running subtotal" for each row without collapsing the table

### Exercises in Every Lesson

Understanding isn't the same as doing. Each lesson ends with practice problems. You haven't really learned it until you've done the exercises.

### Comments That Read Like a Tutor Sitting Next to You

Every SQL statement has comments -- not the "this is a SELECT statement" kind, but the "why write it this way" and "what happens if you change it" kind.

## Getting Started

### Setup

This course uses SQLite, compatible with MySQL. Beginners should start with SQLite -- zero config, just install and go.

**SQLite:**
```bash
# Windows: download from https://www.sqlite.org/download.html
# Mac: brew install sqlite
# Linux: sudo apt-get install sqlite3

# Launch
sqlite3 mydb.db
```

**MySQL:**
```bash
mysql -u root -p
```

### Running SQL Files

**SQLite:**
```bash
sqlite3 mydb.db < 00_零基础入门.sql
# Or inside the SQLite shell:
sqlite> .read 00_零基础入门.sql
```

**MySQL:**
```bash
mysql -u root -p mydb < 00_零基础入门.sql
# Or inside the MySQL shell:
mysql> source /path/to/00_零基础入门.sql;
```

## FAQ

**Q: SQLite or MySQL?**
Start with SQLite. No server to install, data lives in a single file, and the syntax is mostly compatible with MySQL.

**Q: What can I do after finishing?**
Design databases, write all kinds of queries, optimize performance, understand database theory, and prevent SQL injection.

**Q: How do I go deeper?**
Practice on LeetCode database problems -> learn a programming language (Python/Java) -> learn an ORM framework -> study database administration (backup, recovery, monitoring) -> explore distributed databases.

## References

- [SQLite Official Docs](https://www.sqlite.org/docs.html)
- [MySQL Official Docs](https://dev.mysql.com/doc/)
- [W3School SQL Tutorial](https://www.w3schools.com/sql/)
- [LeetCode Database Problems](https://leetcode.cn/problemset/database/)

## License

For educational use only.

---

> Window functions are SQL's "hidden superpower" -- most tutorials skip them, but interviews and real projects use them all the time. This course starts from the simplest SELECT and takes you through window functions, index internals, and transaction isolation. By the end, you'll realize SQL is far more powerful than you thought.
