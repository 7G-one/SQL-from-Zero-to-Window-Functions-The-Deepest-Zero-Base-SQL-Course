-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第04课：排序与分页（超级详细版）
-- =============================================
-- 第04课：排序与分页
-- ORDER BY排序、LIMIT/OFFSET分页、DISTINCT去重

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS products_sort;
DROP TABLE IF EXISTS employees_sort;

-- 商品表
CREATE TABLE products_sort (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR(100) NOT NULL,
    category    VARCHAR(50),
    price       DECIMAL(10,2),
    stock       INTEGER,
    rating      REAL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products_sort (name, category, price, stock, rating, created_at) VALUES
    ('iPhone 15', '手机', 7999.00, 100, 4.8, '2024-01-15'),
    ('MacBook Pro', '电脑', 14999.00, 50, 4.9, '2024-01-10'),
    ('AirPods Pro', '耳机', 1899.00, 200, 4.7, '2024-01-20'),
    ('iPad Air', '平板', 4799.00, 80, 4.6, '2024-01-12'),
    ('Apple Watch', '手表', 2999.00, 150, 4.5, '2024-01-18'),
    ('Magic Keyboard', '配件', 999.00, 300, 4.3, '2024-01-25'),
    ('显示器', '配件', 3999.00, 60, 4.4, '2024-01-22'),
    ('机械键盘', '配件', 599.00, 500, 4.6, '2024-01-28'),
    ('鼠标', '配件', 299.00, 400, 4.2, '2024-01-30'),
    ('耳机', '配件', 199.00, 600, 4.1, '2024-02-01'),
    ('USB线', '配件', 29.90, 1000, 4.0, '2024-02-05'),
    ('充电器', '配件', 99.00, 800, 4.3, '2024-02-10'),
    ('手机壳', '配件', 49.90, 600, 3.9, '2024-02-15'),
    ('贴膜', '配件', 19.90, 1200, 3.8, '2024-02-20'),
    ('数据线', '配件', 39.90, 900, 4.0, '2024-02-25');

-- 员工表
CREATE TABLE employees_sort (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR(50) NOT NULL,
    department  VARCHAR(50),
    salary      DECIMAL(10,2),
    hire_date   DATE,
    age         INTEGER
);

INSERT INTO employees_sort (name, department, salary, hire_date, age) VALUES
    ('张三', '技术部', 15000.00, '2022-01-15', 28),
    ('李四', '市场部', 12000.00, '2022-06-01', 32),
    ('王五', '技术部', 18000.00, '2021-03-20', 35),
    ('赵六', '人事部', 10000.00, '2023-01-10', 25),
    ('钱七', '财务部', 13000.00, '2022-09-15', 30),
    ('孙八', '技术部', 20000.00, '2020-11-01', 38),
    ('周九', '市场部', 11000.00, '2023-04-20', 27),
    ('吴十', '技术部', 16000.00, '2021-08-10', 33),
    ('郑一', '人事部', 9500.00, '2023-07-01', 24),
    ('王二', '财务部', 14000.00, '2022-02-28', 29),
    ('李三', '技术部', 22000.00, '2019-05-15', 40),
    ('赵四', '市场部', 11500.00, '2023-03-10', 26),
    ('钱五', '人事部', 10500.00, '2023-06-20', 25),
    ('孙六', '财务部', 13500.00, '2022-11-15', 31),
    ('周七', '技术部', 17000.00, '2021-01-20', 34);

-- =============================================
-- 第一节：ORDER BY 排序
-- =============================================

/*
 * 【ORDER BY 子句】
 *
 * 用于对查询结果进行排序
 *
 * 语法：SELECT ... FROM 表名 ORDER BY 列名 [ASC|DESC];
 *
 * ASC  —— 升序（从小到大，默认）
 * DESC —— 降序（从大到小）
 *
 * 生活类比：
 *   就像你在淘宝搜索商品，可以选择：
 *   - 按价格从低到高（升序）
 *   - 按价格从高到低（降序）
 *   - 按销量排序
 *   - 按评分排序
 */

-- 1. 单列排序（升序，默认）
SELECT * FROM products_sort ORDER BY price;
-- 等价于 ORDER BY price ASC

-- 2. 单列排序（降序）
SELECT * FROM products_sort ORDER BY price DESC;
-- 价格从高到低

-- 3. 多列排序
SELECT * FROM products_sort
ORDER BY category ASC, price DESC;
-- 先按分类升序，分类相同再按价格降序

/*
 * 多列排序的规则：
 * 1. 先按第一个列排序
 * 2. 如果第一个列的值相同，再按第二个列排序
 * 3. 以此类推...
 *
 * 就像排名次：
 * 先按总分排，总分一样再按语文分排，语文也一样再按数学分排
 */

-- 4. 按表达式排序
SELECT
    name,
    price,
    stock,
    price * stock AS 总价值
FROM products_sort
ORDER BY price * stock DESC;
-- 按总价值（价格×库存）降序

-- 5. 按别名排序
SELECT
    name,
    price,
    price * 0.8 AS 折后价
FROM products_sort
ORDER BY 折后价;
-- 按折后价升序

-- 6. 按列序号排序
SELECT name, price, stock FROM products_sort ORDER BY 2;
-- 第2列是 price，按 price 升序
-- 不推荐，可读性差

-- 7. NULL 值的排序
-- NULL 在排序时被视为最小值
-- 升序时 NULL 排在最前面，降序时排在最后面

-- =============================================
-- 第二节：LIMIT 限制返回行数
-- =============================================

/*
 * 【LIMIT 子句】
 *
 * 用于限制查询返回的行数
 *
 * 语法：SELECT ... FROM 表名 LIMIT 数量;
 *
 * 生活类比：
 *   就像你问图书管理员："给我推荐3本书"
 *   管理员只会给你3本，而不是所有书
 */

-- 1. 返回前N条记录
SELECT * FROM products_sort LIMIT 5;
-- 只返回前5条

-- 2. 返回前1条记录
SELECT * FROM products_sort ORDER BY price DESC LIMIT 1;
-- 价格最高的商品

-- 3. 返回前3条记录
SELECT * FROM products_sort ORDER BY rating DESC LIMIT 3;
-- 评分最高的3个商品

-- =============================================
-- 第三节：LIMIT OFFSET 分页查询
-- =============================================

/*
 * 【LIMIT ... OFFSET ...】
 *
 * 用于分页查询
 *
 * 语法：SELECT ... FROM 表名 LIMIT 每页数量 OFFSET 跳过数量;
 *
 * 生活类比：
 *   就像看书，每页显示10条记录：
 *   - 第1页：第1-10条（跳过0条）
 *   - 第2页：第11-20条（跳过10条）
 *   - 第3页：第21-30条（跳过20条）
 *
 * 公式：OFFSET = (页码 - 1) × 每页数量
 */

-- 1. 第1页（前5条）
SELECT * FROM products_sort
ORDER BY price
LIMIT 5 OFFSET 0;
-- 跳过0条，取5条

-- 2. 第2页（第6-10条）
SELECT * FROM products_sort
ORDER BY price
LIMIT 5 OFFSET 5;
-- 跳过5条，取5条

-- 3. 第3页（第11-15条）
SELECT * FROM products_sort
ORDER BY price
LIMIT 5 OFFSET 10;
-- 跳过10条，取5条

/*
 * 分页公式：
 * 第N页：LIMIT 每页数量 OFFSET (N-1) * 每页数量
 *
 * 例如每页10条：
 * 第1页：LIMIT 10 OFFSET 0
 * 第2页：LIMIT 10 OFFSET 10
 * 第3页：LIMIT 10 OFFSET 20
 */

-- 4. MySQL 的简写语法
-- MySQL 支持另一种语法：LIMIT 跳过数量, 返回数量
-- SELECT * FROM products_sort LIMIT 5, 10;
-- 等价于 LIMIT 10 OFFSET 5

-- =============================================
-- 第四节：DISTINCT 去重
-- =============================================

/*
 * 【DISTINCT 关键字】
 *
 * 用于去除查询结果中的重复行
 *
 * 语法：SELECT DISTINCT 列名 FROM 表名;
 *
 * 生活类比：
 *   就像问："班上有哪些不同的姓氏？"
 *   不需要列出所有人的姓，只需要列出不重复的姓
 */

-- 1. 单列去重
SELECT DISTINCT category FROM products_sort;
-- 查看有哪些分类

-- 2. 多列去重
SELECT DISTINCT department, age FROM employees_sort;
-- 查看部门和年龄的组合（去除重复）

-- 3. 统计不重复的数量
SELECT COUNT(DISTINCT category) AS 分类数量 FROM products_sort;

-- 4. DISTINCT 与 ORDER BY
SELECT DISTINCT category FROM products_sort ORDER BY category;

/*
 * 注意事项：
 * 1. DISTINCT 会影响性能，大数据量时慎用
 * 2. DISTINCT 作用于所有 SELECT 的列
 * 3. 如果需要对某列去重但显示其他列，需要用子查询或 GROUP BY
 */

-- =============================================
-- 第五节：综合应用
-- =============================================

/*
 * 实际开发中，排序、分页、去重经常组合使用
 */

-- 1. 查询价格最高的3个商品
SELECT name, price
FROM products_sort
ORDER BY price DESC
LIMIT 3;

-- 2. 查询每个分类中价格最高的商品
SELECT category, name, price
FROM products_sort p1
WHERE price = (
    SELECT MAX(price) FROM products_sort p2
    WHERE p2.category = p1.category
)
ORDER BY category;

-- 3. 分页查询（第2页，每页5条，按价格升序）
SELECT * FROM products_sort
ORDER BY price ASC
LIMIT 5 OFFSET 5;

-- 4. 查询评分最高的商品（并列第一都显示）
SELECT * FROM products_sort
WHERE rating = (SELECT MAX(rating) FROM products_sort);

-- 5. 查询各部门工资最高的员工
SELECT department, name, salary
FROM employees_sort e1
WHERE salary = (
    SELECT MAX(salary) FROM employees_sort e2
    WHERE e2.department = e1.department
)
ORDER BY department;

-- =============================================
-- 第六节：排序和分页的性能优化
-- =============================================

/*
 * 【性能优化技巧】
 *
 * 1. 排序字段加索引
 *    ORDER BY 字段如果有索引，排序会更快
 *
 * 2. 避免对大量数据排序
 *    如果只需要前N条，用 LIMIT 限制
 *
 * 3. 分页深度越大越慢
 *    OFFSET 1000000 会扫描前100万条数据
 *    优化方案：使用游标分页（记住上次的位置）
 *
 * 4. 避免 SELECT *
 *    只查询需要的列，减少排序的数据量
 */

-- 游标分页示例（比 OFFSET 更高效）
-- 假设上一页最后一条的 id 是 100
-- SELECT * FROM products_sort WHERE id > 100 ORDER BY id LIMIT 10;
-- 这比 LIMIT 10 OFFSET 100 更快

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：基础排序
 * Q: 查询 employees_sort 表，按工资从高到低排序
 */

SELECT * FROM employees_sort ORDER BY salary DESC;

/*
 * 练习2：多列排序
 * Q: 查询 employees_sort 表，先按部门升序，再按工资降序
 */

SELECT * FROM employees_sort ORDER BY department ASC, salary DESC;

/*
 * 练习3：分页查询
 * Q: 查询 employees_sort 表，每页3条，查询第2页的数据
 */

SELECT * FROM employees_sort
ORDER BY id
LIMIT 3 OFFSET 3;

/*
 * 练习4：去重统计
 * Q: 统计 employees_sort 表中有多少个不同的部门
 */

SELECT COUNT(DISTINCT department) AS 部门数量 FROM employees_sort;

/*
 * 练习5：综合练习
 * Q: 完成以下查询：
 *    1. 查询价格最低的5个商品
 *    2. 查询每个分类中库存最多的商品
 *    3. 统计每个分类的商品数量，按数量从多到少排序
 */

-- 1. 价格最低的5个商品
SELECT * FROM products_sort ORDER BY price LIMIT 5;

-- 2. 每个分类中库存最多的商品
SELECT category, name, stock
FROM products_sort p1
WHERE stock = (
    SELECT MAX(stock) FROM products_sort p2
    WHERE p2.category = p1.category
);

-- 3. 统计每个分类的商品数量
SELECT category, COUNT(*) AS 商品数量
FROM products_sort
GROUP BY category
ORDER BY 商品数量 DESC;

/*
 * 练习6：分页查询练习
 * Q: 实现一个简单的分页功能：
 *    - 总共15条数据
 *    - 每页4条
 *    - 分别查询第1、2、3、4页的数据
 */

-- 第1页
SELECT * FROM products_sort ORDER BY id LIMIT 4 OFFSET 0;

-- 第2页
SELECT * FROM products_sort ORDER BY id LIMIT 4 OFFSET 4;

-- 第3页
SELECT * FROM products_sort ORDER BY id LIMIT 4 OFFSET 8;

-- 第4页
SELECT * FROM products_sort ORDER BY id LIMIT 4 OFFSET 12;

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS products_sort;
DROP TABLE IF EXISTS employees_sort;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. ORDER BY —— 排序（ASC升序/默认，DESC降序）
 * 2. 多列排序 —— ORDER BY 列1 ASC, 列2 DESC（先按列1，相同再按列2）
 * 3. LIMIT N —— 只返回前N条记录
 * 4. LIMIT N OFFSET M —— 跳过M条，取N条（分页公式：OFFSET = (页码-1)*每页数量）
 * 5. DISTINCT —— 去除重复行
 * 6. 游标分页 —— WHERE id > 上次最后一条的id LIMIT N（比OFFSET快）
 *
 * 【常见陷阱】
 *
 * 1. ORDER BY 默认是升序(ASC)，想要降序必须显式写 DESC
 * 2. OFFSET 越大查询越慢（数据库要扫描前面所有数据）
 * 3. DISTINCT 作用于所有 SELECT 的列，不是只对某一列去重
 * 4. NULL 在排序中被视为最小值（升序排最前，降序排最后）
 * 5. MySQL 的分页简写 LIMIT 5,10 等价于 LIMIT 10 OFFSET 5（顺序反的！）
 *
 * 【下节课预告】
 *
 * 第05课将学习聚合函数：COUNT(计数)、SUM(求和)、AVG(平均)、MAX/MIN(最值)，
 * 以及 GROUP BY(分组) 和 HAVING(过滤分组)。这是数据分析的核心！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第04课：排序与分页！
-- 下节课我们将学习聚合函数。
