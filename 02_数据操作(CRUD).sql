-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第02课：数据操作 CRUD（超级详细版）
-- =============================================
-- 第02课：数据操作 CRUD
-- INSERT(插入)、SELECT(查询)、UPDATE(更新)、DELETE(删除)

-- =============================================
-- 准备工作：创建示例表
-- =============================================

-- 先清理旧表（如果存在）
DROP TABLE IF EXISTS employees_demo;
DROP TABLE IF EXISTS products_demo;

-- 创建员工演示表
CREATE TABLE IF NOT EXISTS employees_demo (
    emp_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR(50) NOT NULL,
    department  VARCHAR(50) DEFAULT '未分配',
    salary      DECIMAL(10,2),
    hire_date   DATE,
    is_active   BOOLEAN DEFAULT 1
);

-- 创建商品演示表
CREATE TABLE IF NOT EXISTS products_demo (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2),
    stock        INTEGER DEFAULT 0,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 第一节：INSERT —— 插入数据
-- =============================================

/*
 * 【INSERT 语句】
 *
 * 就像往图书馆的书架上放新书
 *
 * 语法1：指定列名（推荐）
 * INSERT INTO 表名 (列1, 列2, 列3) VALUES (值1, 值2, 值3);
 *
 * 语法2：不指定列名（按顺序）
 * INSERT INTO 表名 VALUES (值1, 值2, 值3);
 *
 * 语法3：插入多条数据
 * INSERT INTO 表名 (列1, 列2) VALUES (值1, 值2), (值3, 值4), (值5, 值6);
 */

-- 方法1：指定列名（推荐！清晰明了）
INSERT INTO employees_demo (name, department, salary, hire_date)
VALUES ('张三', '技术部', 15000.00, '2023-01-15');

/*
 * 逐行解释：
 * INSERT INTO employees_demo —— 向 employees_demo 表插入数据
 * (name, department, salary, hire_date) —— 指定要填哪些列
 * VALUES ('张三', '技术部', 15000.00, '2023-01-15') —— 具体的值
 *
 * 注意：
 * 1. 字符串用单引号 ' ' 包裹
 * 2. 数字不用引号
 * 3. 日期用单引号包裹，格式为 'YYYY-MM-DD'
 * 4. 列的顺序和值的顺序要一一对应
 */

-- 方法2：不指定列名（按表定义的顺序）
INSERT INTO employees_demo
VALUES (NULL, '李四', '市场部', 12000.00, '2023-03-20', 1);
-- NULL 表示让 emp_id 自动增长

-- 方法3：插入多条数据（批量插入，效率更高）
INSERT INTO employees_demo (name, department, salary, hire_date) VALUES
    ('王五', '技术部', 18000.00, '2022-06-01'),
    ('赵六', '人事部', 10000.00, '2023-07-10'),
    ('钱七', '财务部', 13000.00, '2023-02-28'),
    ('孙八', '技术部', 20000.00, '2021-11-15'),
    ('周九', '市场部', 11000.00, '2023-05-01'),
    ('吴十', '技术部', 16000.00, '2023-08-20');

-- 插入商品数据
INSERT INTO products_demo (product_name, category, price, stock) VALUES
    ('iPhone 15', '手机', 7999.00, 100),
    ('MacBook Pro', '电脑', 14999.00, 50),
    ('AirPods Pro', '耳机', 1899.00, 200),
    ('iPad Air', '平板', 4799.00, 80),
    ('Apple Watch', '手表', 2999.00, 150),
    ('Magic Keyboard', '配件', 999.00, 300),
    ('显示器', '配件', 3999.00, 60),
    ('机械键盘', '配件', 599.00, 500),
    ('鼠标', '配件', 299.00, 400),
    ('耳机', '配件', 199.00, 600);

-- 验证插入结果
SELECT * FROM employees_demo;
SELECT * FROM products_demo;

/*
 * 【INSERT 的注意事项】
 *
 * 1. 主键不能重复
 *    如果插入的主键值已存在，会报错
 *
 * 2. NOT NULL 的列必须填值
 *    如果某列设置了 NOT NULL，插入时必须提供值
 *
 * 3. 有 DEFAULT 的列可以不填
 *    不填的话会用默认值
 *
 * 4. 数据类型要匹配
 *    字符串列不能插入数字，反之亦然
 */

-- =============================================
-- 第二节：SELECT —— 查询数据（详解）
-- =============================================

/*
 * 【SELECT 语句】
 *
 * SELECT 是 SQL 中最常用的语句
 * 它的作用是从数据库中"查询"（获取）数据
 *
 * 基本语法：
 * SELECT 列名1, 列名2, ... FROM 表名;
 *
 * 就像你对图书管理员说：
 * "请告诉我所有书的书名和作者"
 */

-- 1. 查询所有列
SELECT * FROM employees_demo;
-- * 表示"所有列"

-- 2. 查询指定列
SELECT name, department, salary FROM employees_demo;
-- 只看姓名、部门、工资

-- 3. 给列起别名（AS 关键字）
SELECT
    name AS 姓名,
    department AS 部门,
    salary AS 月薪
FROM employees_demo;

-- 4. 查询时进行计算
SELECT
    name AS 姓名,
    salary AS 月薪,
    salary * 12 AS 年薪,
    salary * 0.2 AS 税费
FROM employees_demo;

-- 5. 使用 DISTINCT 去重
SELECT DISTINCT department FROM employees_demo;
-- 查看有哪些部门（去除重复）

-- 6. 使用表达式
SELECT
    name AS 姓名,
    CASE
        WHEN salary >= 15000 THEN '高薪'
        WHEN salary >= 10000 THEN '中等'
        ELSE '待提升'
    END AS 薪资等级
FROM employees_demo;

-- =============================================
-- 第三节：WHERE —— 条件查询
-- =============================================

/*
 * 【WHERE 子句】
 *
 * 如果你只想看满足某些条件的数据，就需要 WHERE
 * 就像你对图书管理员说："我只想看2020年以后出版的书"
 *
 * 语法：SELECT 列名 FROM 表名 WHERE 条件;
 */

-- 1. 等于条件
SELECT * FROM employees_demo WHERE department = '技术部';

-- 2. 不等于条件
SELECT * FROM employees_demo WHERE department != '技术部';
-- 也可以用 <> 表示不等于
SELECT * FROM employees_demo WHERE department <> '技术部';

-- 3. 大于、小于
SELECT * FROM employees_demo WHERE salary > 15000;
SELECT * FROM employees_demo WHERE salary < 12000;
SELECT * FROM employees_demo WHERE salary >= 15000;

-- 4. AND（同时满足多个条件）
SELECT * FROM employees_demo
WHERE department = '技术部' AND salary > 15000;
-- 技术部且工资大于15000的员工

-- 5. OR（满足任一条件即可）
SELECT * FROM employees_demo
WHERE department = '技术部' OR department = '市场部';
-- 技术部或市场部的员工

-- 6. BETWEEN（范围查询）
SELECT * FROM employees_demo
WHERE salary BETWEEN 12000 AND 18000;
-- 工资在12000到18000之间（包含边界）

-- 7. IN（在某个列表中）
SELECT * FROM employees_demo
WHERE department IN ('技术部', '市场部', '财务部');
-- 部门是技术部、市场部或财务部

-- 8. LIKE（模糊匹配）
SELECT * FROM employees_demo WHERE name LIKE '张%';
-- 姓张的人（% 表示任意多个字符）

SELECT * FROM employees_demo WHERE name LIKE '%三';
-- 名字以"三"结尾的人

SELECT * FROM employees_demo WHERE name LIKE '_五';
-- 名字是两个字，且第二个字是"五"（_ 表示一个字符）

-- 9. IS NULL / IS NOT NULL
SELECT * FROM employees_demo WHERE department IS NULL;
-- 部门为空的员工

SELECT * FROM employees_demo WHERE department IS NOT NULL;
-- 部门不为空的员工

-- 10. NOT（取反）
SELECT * FROM employees_demo WHERE NOT department = '技术部';
-- 不是技术部的员工

SELECT * FROM employees_demo WHERE salary NOT BETWEEN 12000 AND 18000;
-- 工资不在12000到18000之间

-- =============================================
-- 第四节：UPDATE —— 更新数据
-- =============================================

/*
 * 【UPDATE 语句】
 *
 * 就像修改图书馆里某本书的信息
 *
 * 语法：UPDATE 表名 SET 列名 = 新值 WHERE 条件;
 *
 * ⚠️ 重要警告：
 * 如果不加 WHERE 条件，会更新所有行！！！
 */

-- 1. 更新单个字段
UPDATE employees_demo SET salary = 16000 WHERE name = '张三';
-- 把张三的工资改成16000

-- 验证
SELECT * FROM employees_demo WHERE name = '张三';

-- 2. 更新多个字段
UPDATE employees_demo
SET department = '技术总监', salary = 25000
WHERE name = '张三';
-- 同时修改部门和工资

-- 3. 使用表达式更新
UPDATE employees_demo SET salary = salary * 1.1;
-- 所有员工工资涨10%（没有WHERE，更新所有行！）

-- 验证
SELECT * FROM employees_demo;

-- 4. 使用条件更新
UPDATE employees_demo
SET salary = salary * 1.2
WHERE department = '技术部';
-- 技术部员工工资涨20%

-- 验证
SELECT * FROM employees_demo WHERE department = '技术部';

-- =============================================
-- 第五节：DELETE —— 删除数据
-- =============================================

/*
 * 【DELETE 语句】
 *
 * 就像从图书馆里拿走某本书
 *
 * 语法：DELETE FROM 表名 WHERE 条件;
 *
 * ⚠️ 重要警告：
 * 1. 如果不加 WHERE 条件，会删除所有行！！！
 * 2. 删除操作是不可逆的！删了就找不回来了！
 * 3. 建议：先用 SELECT 查看要删除的数据，确认无误再删除
 */

-- 1. 删除特定行
DELETE FROM employees_demo WHERE name = '吴十';
-- 删除吴十的记录

-- 验证
SELECT * FROM employees_demo;

-- 2. 使用条件删除
DELETE FROM employees_demo
WHERE salary < 12000;
-- 删除工资低于12000的员工

-- 验证
SELECT * FROM employees_demo;

-- 3. 删除所有数据（慎用！）
-- DELETE FROM employees_demo;
-- 这会删除表中的所有数据，但保留表结构

-- 4. TRUNCATE（清空表，比DELETE更快）
-- TRUNCATE TABLE employees_demo;
-- 注意：SQLite 不支持 TRUNCATE，需要用 DELETE

-- =============================================
-- 第六节：INSERT ... SELECT（从其他表复制数据）
-- =============================================

/*
 * 有时候你需要把一个表的数据复制到另一个表
 * 这时候可以用 INSERT ... SELECT
 */

-- 创建一个备份表
CREATE TABLE IF NOT EXISTS employees_backup (
    emp_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR(50),
    department  VARCHAR(50),
    salary      DECIMAL(10,2),
    backup_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 从 employees_demo 复制数据到备份表
INSERT INTO employees_backup (name, department, salary)
SELECT name, department, salary FROM employees_demo;

-- 验证
SELECT * FROM employees_backup;

-- =============================================
-- 第七节：批量操作技巧
-- =============================================

/*
 * 【批量插入的效率】
 *
 * 插入大量数据时，一条一条 INSERT 效率很低
 * 应该使用批量插入：
 *
 * 方法1：一条 INSERT 插入多条数据
 * INSERT INTO table VALUES (...), (...), (...);
 *
 * 方法2：使用事务包裹（后面会学）
 * BEGIN;
 * INSERT INTO ...;
 * INSERT INTO ...;
 * COMMIT;
 *
 * 方法3：使用 LOAD DATA（MySQL）或 .import（SQLite）
 */

-- 批量插入示例
INSERT INTO products_demo (product_name, category, price, stock) VALUES
    ('USB线', '配件', 29.90, 1000),
    ('充电器', '配件', 99.00, 800),
    ('手机壳', '配件', 49.90, 600),
    ('贴膜', '配件', 19.90, 1200),
    ('数据线', '配件', 39.90, 900);

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：INSERT 练习
 * Q: 向 employees_demo 表插入一条新员工记录：
 *    姓名：小明，部门：设计部，工资：9500，入职日期：2024-01-01
 */

INSERT INTO employees_demo (name, department, salary, hire_date)
VALUES ('小明', '设计部', 9500.00, '2024-01-01');

/*
 * 练习2：SELECT 练习
 * Q: 查询 products_demo 表中，价格大于1000且库存小于100的商品
 */

SELECT * FROM products_demo
WHERE price > 1000 AND stock < 100;

/*
 * 练习3：UPDATE 练习
 * Q: 把 products_demo 表中所有"配件"类商品的价格打8折
 */

UPDATE products_demo SET price = price * 0.8 WHERE category = '配件';

-- 验证
SELECT * FROM products_demo WHERE category = '配件';

/*
 * 练习4：DELETE 练习
 * Q: 删除 products_demo 表中库存为0的商品
 */

-- 先查看要删除的数据
SELECT * FROM products_demo WHERE stock = 0;

-- 确认后删除
DELETE FROM products_demo WHERE stock = 0;

/*
 * 练习5：综合练习
 * Q: 完成以下操作：
 *    1. 创建一个"学生成绩"表（学号、姓名、科目、分数）
 *    2. 插入5条数据
 *    3. 查询所有分数大于80的学生
 *    4. 把某个学生的分数更新为95
 *    5. 删除分数最低的一条记录
 */

-- 1. 创建表
CREATE TABLE IF NOT EXISTS student_scores (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    VARCHAR(50) NOT NULL,
    subject VARCHAR(50),
    score   REAL
);

-- 2. 插入数据
INSERT INTO student_scores (name, subject, score) VALUES
    ('张三', '数学', 85),
    ('李四', '数学', 92),
    ('王五', '数学', 78),
    ('赵六', '数学', 95),
    ('钱七', '数学', 65);

-- 3. 查询分数大于80的学生
SELECT * FROM student_scores WHERE score > 80;

-- 4. 更新分数
UPDATE student_scores SET score = 95 WHERE name = '王五';

-- 5. 删除分数最低的记录
DELETE FROM student_scores WHERE score = (SELECT MIN(score) FROM student_scores);

-- 验证最终结果
SELECT * FROM student_scores ORDER BY score DESC;

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS employees_backup;
DROP TABLE IF EXISTS student_scores;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. INSERT —— 插入数据（指定列名、批量插入、INSERT...SELECT）
 * 2. SELECT —— 查询数据（*所有列、指定列、AS别名、计算列、DISTINCT去重）
 * 3. UPDATE —— 更新数据（SET修改字段、WHERE限定范围）
 * 4. DELETE —— 删除数据（WHERE限定范围、不加WHERE删除全部）
 * 5. TRUNCATE —— 快速清空表（比DELETE快，但SQLite不支持）
 *
 * 【常见陷阱】
 *
 * 1. UPDATE/DELETE 不加 WHERE 会操作所有行！先用 SELECT 确认范围
 * 2. INSERT 时不指定列名，必须按表定义顺序提供所有列的值
 * 3. 字符串用单引号，数字不用引号，日期用单引号
 * 4. 删除操作不可逆，建议先 SELECT 再 DELETE
 * 5. INSERT INTO ... SELECT 可以从其他表复制数据，注意列要对应
 *
 * 【下节课预告】
 *
 * 第03课将深入条件查询：比较运算符、逻辑运算符(AND/OR/NOT)、
 * LIKE模糊匹配、IN列表、BETWEEN范围、IS NULL空值判断、CASE WHEN表达式。
 */

-- =============================================
-- 生活类比
-- =============================================
-- CRUD 就像图书馆管理书籍：
-- CREATE（新增）= 新书上架
-- READ（查询）= 找书
-- UPDATE（更新）= 修改书的信息
-- DELETE（删除）= 下架旧书

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第02课：数据操作 CRUD！
-- 下节课我们将学习条件查询。
