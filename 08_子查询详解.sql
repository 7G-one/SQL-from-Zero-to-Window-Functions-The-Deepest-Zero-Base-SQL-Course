-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第08课：子查询详解（超级详细版）
-- =============================================
-- 第08课：子查询详解
-- 标量子查询、行子查询、表子查询、相关子查询、性能优化

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS employees_sub;
DROP TABLE IF EXISTS departments_sub;
DROP TABLE IF EXISTS products_sub;
DROP TABLE IF EXISTS sales_sub;

-- 部门表
CREATE TABLE departments_sub (
    dept_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    dept_name VARCHAR(50) NOT NULL,
    location  VARCHAR(50)
);

INSERT INTO departments_sub (dept_name, location) VALUES
    ('技术部', '北京'),
    ('市场部', '上海'),
    ('财务部', '广州'),
    ('人事部', '深圳'),
    ('研发部', '杭州');

-- 员工表
CREATE TABLE employees_sub (
    emp_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    emp_name   VARCHAR(50) NOT NULL,
    dept_id    INTEGER,
    salary     DECIMAL(10,2),
    hire_date  DATE,
    manager_id INTEGER,
    FOREIGN KEY (dept_id) REFERENCES departments_sub(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees_sub(emp_id)
);

INSERT INTO employees_sub (emp_name, dept_id, salary, hire_date, manager_id) VALUES
    ('张三', 1, 15000.00, '2022-01-15', NULL),
    ('李四', 1, 18000.00, '2021-06-01', 1),
    ('王五', 1, 12000.00, '2023-03-20', 1),
    ('赵六', 2, 13000.00, '2022-09-10', NULL),
    ('钱七', 2, 11000.00, '2023-01-15', 4),
    ('孙八', 3, 14000.00, '2021-11-01', NULL),
    ('周九', 3, 10000.00, '2023-05-20', 6),
    ('吴十', 4, 12500.00, '2022-07-10', NULL),
    ('郑一', 5, 20000.00, '2020-03-15', NULL),
    ('王二', 5, 16000.00, '2021-08-20', 9);

-- 商品表
CREATE TABLE products_sub (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2),
    stock        INTEGER
);

INSERT INTO products_sub (product_name, category, price, stock) VALUES
    ('iPhone 15', '手机', 7999.00, 100),
    ('MacBook Pro', '电脑', 14999.00, 50),
    ('AirPods Pro', '耳机', 1899.00, 200),
    ('iPad Air', '平板', 4799.00, 80),
    ('Apple Watch', '手表', 2999.00, 150),
    ('小米14', '手机', 3999.00, 200),
    ('ThinkPad', '电脑', 8999.00, 100),
    ('华为耳机', '耳机', 999.00, 300);

-- 销售表
CREATE TABLE sales_sub (
    sale_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER,
    quantity   INTEGER,
    sale_date  DATE,
    FOREIGN KEY (product_id) REFERENCES products_sub(product_id)
);

INSERT INTO sales_sub (product_id, quantity, sale_date) VALUES
    (1, 5, '2024-01-15'),
    (2, 3, '2024-01-16'),
    (3, 10, '2024-01-17'),
    (1, 8, '2024-01-18'),
    (4, 4, '2024-01-19'),
    (5, 6, '2024-01-20'),
    (2, 2, '2024-01-21'),
    (3, 15, '2024-01-22');

-- =============================================
-- 第一节：标量子查询
-- =============================================

/*
 * 【标量子查询】
 *
 * 返回单个值（一行一列）的子查询
 * 可以用在 SELECT、WHERE、HAVING 等子句中
 *
 * 生活类比：
 *   "我的工资比公司平均工资高吗？"
 *   这里的"公司平均工资"就是一个标量子查询
 */

-- 1. 在 WHERE 中使用标量子查询
-- 查询工资高于平均工资的员工
SELECT emp_name, salary
FROM employees_sub
WHERE salary > (SELECT AVG(salary) FROM employees_sub);

-- 2. 在 SELECT 中使用标量子查询
SELECT
    emp_name,
    salary,
    (SELECT AVG(salary) FROM employees_sub) AS 公司平均工资,
    salary - (SELECT AVG(salary) FROM employees_sub) AS 差额
FROM employees_sub;

-- 3. 查询工资最高的员工
SELECT emp_name, salary
FROM employees_sub
WHERE salary = (SELECT MAX(salary) FROM employees_sub);

-- 4. 查询每个部门中工资最高的员工
SELECT
    d.dept_name,
    e.emp_name,
    e.salary
FROM employees_sub e
INNER JOIN departments_sub d ON e.dept_id = d.dept_id
WHERE e.salary = (
    SELECT MAX(salary) FROM employees_sub e2
    WHERE e2.dept_id = e.dept_id
);

-- =============================================
-- 第二节：行子查询
-- =============================================

/*
 * 【行子查询】
 *
 * 返回一行（多列）的子查询
 * 可以用于比较多个列的组合
 *
 * 生活类比：
 *   "找出和张三同部门且工资相同的员工"
 *   这里需要同时比较部门和工资两个条件
 */

-- 1. 查询与"李四"同部门且工资相同的员工
SELECT emp_name, dept_id, salary
FROM employees_sub
WHERE (dept_id, salary) = (
    SELECT dept_id, salary FROM employees_sub
    WHERE emp_name = '李四'
)
AND emp_name != '李四';

-- 2. 查询每个部门工资最高的员工（使用行子查询）
SELECT emp_name, dept_id, salary
FROM employees_sub
WHERE (dept_id, salary) IN (
    SELECT dept_id, MAX(salary) FROM employees_sub
    GROUP BY dept_id
);

-- =============================================
-- 第三节：表子查询
-- =============================================

/*
 * 【表子查询】
 *
 * 返回多行多列的子查询
 * 通常用在 FROM 子句中，作为临时表
 *
 * 生活类比：
 *   "从销售报表中找出销量最好的商品"
 *   这里的"销售报表"就是一个表子查询
 */

-- 1. 在 FROM 中使用表子查询
-- 查询每个部门的平均工资，只显示平均工资大于12000的部门
SELECT dept_name, 平均工资
FROM departments_sub d
INNER JOIN (
    SELECT dept_id, AVG(salary) AS 平均工资
    FROM employees_sub
    GROUP BY dept_id
    HAVING AVG(salary) > 12000
) AS dept_avg ON d.dept_id = dept_avg.dept_id;

-- 2. 查询每个分类中价格最高的商品
SELECT
    p.product_name,
    p.category,
    p.price
FROM products_sub p
INNER JOIN (
    SELECT category, MAX(price) AS max_price
    FROM products_sub
    GROUP BY category
) AS cat_max ON p.category = cat_max.category AND p.price = cat_max.max_price;

-- 3. 查询销量排名前3的商品
SELECT
    p.product_name,
    p.category,
    total_sales
FROM products_sub p
INNER JOIN (
    SELECT product_id, SUM(quantity) AS total_sales
    FROM sales_sub
    GROUP BY product_id
    ORDER BY total_sales DESC
    LIMIT 3
) AS top_sales ON p.product_id = top_sales.product_id;

-- =============================================
-- 第四节：相关子查询
-- =============================================

/*
 * 【相关子查询】
 *
 * 子查询中引用了外层查询的列
 * 外层查询每处理一行，子查询就执行一次
 *
 * 与普通子查询的区别：
 * - 普通子查询：子查询只执行一次，结果用于外层查询
 * - 相关子查询：子查询对外层查询的每一行都执行一次
 *
 * 生活类比：
 *   "找出每个部门中工资最高的员工"
 *   对于每个部门，都要重新计算该部门的最高工资
 */

-- 1. 查询每个部门中工资最高的员工
SELECT
    d.dept_name,
    e.emp_name,
    e.salary
FROM employees_sub e
INNER JOIN departments_sub d ON e.dept_id = d.dept_id
WHERE e.salary = (
    SELECT MAX(salary) FROM employees_sub e2
    WHERE e2.dept_id = e.dept_id  -- 这里引用了外层的 e.dept_id
);

-- 2. 查询有销售记录的商品
SELECT product_name, category, price
FROM products_sub p
WHERE EXISTS (
    SELECT 1 FROM sales_sub s
    WHERE s.product_id = p.product_id  -- 相关子查询
);

-- 3. 查询每个分类中销量最好的商品
SELECT
    p.product_name,
    p.category,
    (SELECT SUM(quantity) FROM sales_sub s WHERE s.product_id = p.product_id) AS 总销量
FROM products_sub p
WHERE (SELECT SUM(quantity) FROM sales_sub s WHERE s.product_id = p.product_id) = (
    SELECT MAX(total_qty) FROM (
        SELECT SUM(quantity) AS total_qty
        FROM sales_sub s2
        INNER JOIN products_sub p2 ON s2.product_id = p2.product_id
        WHERE p2.category = p.category
        GROUP BY s2.product_id
    ) AS cat_sales
);

-- =============================================
-- 第五节：子查询的性能考量
-- =============================================

/*
 * 【子查询的性能问题】
 *
 * 子查询虽然强大，但使用不当会导致性能问题：
 *
 * 1. 相关子查询效率低
 *    因为外层查询每处理一行，子查询就执行一次
 *    如果外层有1万行，子查询就执行1万次
 *
 * 2. IN 子查询可能很慢
 *    如果子查询返回大量结果，IN 的效率会很低
 *    可以用 EXISTS 或 JOIN 替代
 *
 * 3. 多层嵌套更慢
 *    子查询嵌套越深，性能越差
 *
 * 【优化技巧】
 *
 * 1. 用 JOIN 替代子查询（通常更快）
 * 2. 用 EXISTS 替代 IN（对于大数据量）
 * 3. 避免在子查询中使用 SELECT *
 * 4. 确保子查询中的列有索引
 */

-- 优化示例：用 JOIN 替代子查询

-- 原始写法（子查询）
SELECT emp_name, salary
FROM employees_sub
WHERE dept_id IN (
    SELECT dept_id FROM departments_sub WHERE location = '北京'
);

-- 优化写法（JOIN）
SELECT e.emp_name, e.salary
FROM employees_sub e
INNER JOIN departments_sub d ON e.dept_id = d.dept_id
WHERE d.location = '北京';

-- =============================================
-- 第六节：子查询的高级用法
-- =============================================

-- 1. 使用子查询进行数据透视
SELECT
    d.dept_name,
    (SELECT COUNT(*) FROM employees_sub e WHERE e.dept_id = d.dept_id) AS 员工数,
    (SELECT AVG(salary) FROM employees_sub e WHERE e.dept_id = d.dept_id) AS 平均工资,
    (SELECT MAX(salary) FROM employees_sub e WHERE e.dept_id = d.dept_id) AS 最高工资,
    (SELECT MIN(salary) FROM employees_sub e WHERE e.dept_id = d.dept_id) AS 最低工资
FROM departments_sub d;

-- 2. 使用子查询进行排名（不使用窗口函数）
SELECT
    emp_name,
    salary,
    (SELECT COUNT(*) FROM employees_sub e2 WHERE e2.salary > e.salary) + 1 AS 排名
FROM employees_sub e
ORDER BY 排名;

-- 3. 使用子查询查找中位数
SELECT AVG(salary) AS 中位数
FROM (
    SELECT salary FROM employees_sub
    ORDER BY salary
    LIMIT 2 - (SELECT COUNT(*) FROM employees_sub) % 2
    OFFSET (SELECT (COUNT(*) - 1) / 2 FROM employees_sub)
);

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：标量子查询
 * Q: 查询工资高于部门平均工资的员工
 */

SELECT emp_name, salary, dept_id
FROM employees_sub e
WHERE salary > (
    SELECT AVG(salary) FROM employees_sub e2
    WHERE e2.dept_id = e.dept_id
);

/*
 * 练习2：表子查询
 * Q: 查询每个分类中价格最低的商品
 */

SELECT
    p.product_name,
    p.category,
    p.price
FROM products_sub p
INNER JOIN (
    SELECT category, MIN(price) AS min_price
    FROM products_sub
    GROUP BY category
) AS cat_min ON p.category = cat_min.category AND p.price = cat_min.min_price;

/*
 * 练习3：相关子查询
 * Q: 查询每个部门中入职最早的员工
 */

SELECT
    d.dept_name,
    e.emp_name,
    e.hire_date
FROM employees_sub e
INNER JOIN departments_sub d ON e.dept_id = d.dept_id
WHERE e.hire_date = (
    SELECT MIN(hire_date) FROM employees_sub e2
    WHERE e2.dept_id = e.dept_id
);

/*
 * 练习4：EXISTS 子查询
 * Q: 查询没有任何员工的部门
 */

SELECT dept_name
FROM departments_sub d
WHERE NOT EXISTS (
    SELECT 1 FROM employees_sub e
    WHERE e.dept_id = d.dept_id
);

/*
 * 练习5：综合练习
 * Q: 查询工资排名前3的员工，显示：
 *    姓名、部门名、工资、排名
 */

SELECT
    emp_name,
    (SELECT dept_name FROM departments_sub WHERE dept_id = e.dept_id) AS dept_name,
    salary,
    (SELECT COUNT(*) FROM employees_sub e2 WHERE e2.salary > e.salary) + 1 AS 排名
FROM employees_sub e
ORDER BY salary DESC
LIMIT 3;

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS sales_sub;
DROP TABLE IF EXISTS products_sub;
DROP TABLE IF EXISTS employees_sub;
DROP TABLE IF EXISTS departments_sub;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 标量子查询 —— 返回单个值，可用于 SELECT/WHERE/HAVING
 * 2. 行子查询 —— 返回一行多列，用 (col1, col2) = (SELECT ...) 比较
 * 3. 表子查询 —— 返回多行多列，用在 FROM 子句中作为临时表
 * 4. 相关子查询 —— 引用外层查询的列，每行执行一次（性能差）
 * 5. 优化：用 JOIN 替代 IN 子查询，用 EXISTS 替代 IN（大数据量时）
 *
 * 【常见陷阱】
 *
 * 1. 相关子查询每行执行一次，外层1万行就执行1万次，极慢
 * 2. IN 子查询遇到 NULL 值会返回意外结果（NOT IN + NULL = 空集）
 * 3. 子查询嵌套太深影响可读性，一般不超过3层
 * 4. 标量子查询必须只返回一个值，返回多行会报错
 * 5. 表子查询必须有别名（AS 别名），否则语法错误
 *
 * 【下节课预告】
 *
 * 第09课将学习索引与性能优化：B+树原理、创建索引、EXPLAIN分析查询计划、
 * 最左前缀原则、查询优化技巧。这是数据库调优的关键！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第08课：子查询详解！
-- 下节课我们将学习索引与性能。
