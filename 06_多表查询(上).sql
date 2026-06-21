-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第06课：多表查询（上）（超级详细版）
-- =============================================
-- 第06课：多表查询（上）
-- INNER JOIN、LEFT JOIN、RIGHT JOIN、CROSS JOIN、自连接

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS order_items_join;
DROP TABLE IF EXISTS orders_join;
DROP TABLE IF EXISTS customers_join;
DROP TABLE IF EXISTS products_join;

-- 客户表
CREATE TABLE customers_join (
    customer_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name VARCHAR(50) NOT NULL,
    email         VARCHAR(100),
    city          VARCHAR(50)
);

INSERT INTO customers_join (customer_name, email, city) VALUES
    ('张三', 'zhangsan@email.com', '北京'),
    ('李四', 'lisi@email.com', '上海'),
    ('王五', 'wangwu@email.com', '广州'),
    ('赵六', 'zhaoliu@email.com', '深圳'),
    ('钱七', 'qianqi@email.com', '杭州'),
    ('孙八', 'sunba@email.com', '北京');

-- 商品表
CREATE TABLE products_join (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2),
    stock        INTEGER
);

INSERT INTO products_join (product_name, price, stock) VALUES
    ('iPhone 15', 7999.00, 100),
    ('MacBook Pro', 14999.00, 50),
    ('AirPods Pro', 1899.00, 200),
    ('iPad Air', 4799.00, 80),
    ('Apple Watch', 2999.00, 150);

-- 订单表
CREATE TABLE orders_join (
    order_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id  INTEGER,
    order_date   DATE,
    total_amount DECIMAL(10,2),
    status       VARCHAR(20) DEFAULT '待发货',
    FOREIGN KEY (customer_id) REFERENCES customers_join(customer_id)
);

INSERT INTO orders_join (customer_id, order_date, total_amount, status) VALUES
    (1, '2024-01-15', 7999.00, '已完成'),
    (2, '2024-01-16', 14999.00, '已完成'),
    (1, '2024-01-17', 1899.00, '已发货'),
    (3, '2024-01-18', 4799.00, '待发货'),
    (2, '2024-01-19', 2999.00, '已完成'),
    (4, '2024-01-20', 7999.00, '已发货');

-- 订单明细表
CREATE TABLE order_items_join (
    item_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id   INTEGER,
    product_id INTEGER,
    quantity   INTEGER,
    price      DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders_join(order_id),
    FOREIGN KEY (product_id) REFERENCES products_join(product_id)
);

INSERT INTO order_items_join (order_id, product_id, quantity, price) VALUES
    (1, 1, 1, 7999.00),
    (2, 2, 1, 14999.00),
    (3, 3, 1, 1899.00),
    (4, 4, 1, 4799.00),
    (5, 5, 1, 2999.00),
    (6, 1, 1, 7999.00);

-- =============================================
-- 第一节：为什么需要多表查询？
-- =============================================

/*
 * 【为什么需要多表查询？】
 *
 * 在实际应用中，数据通常分散在多个表中
 * 为了获取完整的信息，需要将多个表关联起来
 *
 * 生活类比：
 *   想象你是一个图书管理员，需要回答这个问题：
 *   "张三借了哪些书？"
 *
 *   你需要：
 *   1. 在"读者表"中找到张三的读者ID
 *   2. 在"借阅记录表"中找到这个读者ID的所有记录
 *   3. 在"书籍表"中找到这些记录对应的书名
 *
 *   这就需要关联三个表！
 */

-- =============================================
-- 第二节：INNER JOIN 内连接
-- =============================================

/*
 * 【INNER JOIN】
 *
 * 返回两个表中满足连接条件的行
 * 就像取两个集合的交集
 *
 * 语法：
 * SELECT 列名
 * FROM 表1
 * INNER JOIN 表2 ON 连接条件;
 *
 * 生活类比：
 *   "列出所有有订单的客户"
 *   只显示那些在两个表中都匹配的记录
 */

-- 1. 基本的 INNER JOIN
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers_join c
INNER JOIN orders_join o ON c.customer_id = o.customer_id;

/*
 * 解释：
 * customers_join c —— 给 customers_join 表起别名 c
 * INNER JOIN orders_join o —— 连接 orders_join 表，别名 o
 * ON c.customer_id = o.customer_id —— 连接条件：两个表的 customer_id 相等
 *
 * 结果：只显示有订单的客户（孙八没有订单，不会显示）
 */

-- 2. 使用 WHERE 进一步过滤
SELECT
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers_join c
INNER JOIN orders_join o ON c.customer_id = o.customer_id
WHERE o.total_amount > 5000;

-- 3. 三表连接
SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.price
FROM customers_join c
INNER JOIN orders_join o ON c.customer_id = o.customer_id
INNER JOIN order_items_join oi ON o.order_id = oi.order_id
INNER JOIN products_join p ON oi.product_id = p.product_id;

/*
 * 三表连接的执行过程：
 * 1. 先连接 customers_join 和 orders_join
 * 2. 再把结果与 order_items_join 连接
 * 3. 最后与 products_join 连接
 */

-- 4. 连接并聚合
SELECT
    c.customer_name,
    COUNT(o.order_id) AS 订单数量,
    SUM(o.total_amount) AS 总消费
FROM customers_join c
INNER JOIN orders_join o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY 总消费 DESC;

-- =============================================
-- 第三节：LEFT JOIN 左连接
-- =============================================

/*
 * 【LEFT JOIN】
 *
 * 返回左表的所有行，即使右表没有匹配的行
 * 如果右表没有匹配，结果中右表的列显示 NULL
 *
 * 语法：
 * SELECT 列名
 * FROM 表1（左表）
 * LEFT JOIN 表2（右表）ON 连接条件;
 *
 * 生活类比：
 *   "列出所有客户，以及他们的订单（如果有的话）"
 *   即使客户没有订单，也要显示出来
 */

-- 1. 基本的 LEFT JOIN
SELECT
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers_join c
LEFT JOIN orders_join o ON c.customer_id = o.customer_id;

/*
 * 结果：
 * 孙八没有订单，但也会显示出来
 * order_id 和 total_amount 会显示为 NULL
 */

-- 2. 查找没有订单的客户
SELECT
    c.customer_name,
    c.email
FROM customers_join c
LEFT JOIN orders_join o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

/*
 * 这是一个非常实用的查询模式！
 * LEFT JOIN + WHERE IS NULL 可以找到"没有关联记录"的数据
 */

-- 3. 统计每个客户的订单数量（包括没有订单的）
SELECT
    c.customer_name,
    COUNT(o.order_id) AS 订单数量
FROM customers_join c
LEFT JOIN orders_join o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

-- =============================================
-- 第四节：RIGHT JOIN 右连接
-- =============================================

/*
 * 【RIGHT JOIN】
 *
 * 返回右表的所有行，即使左表没有匹配的行
 *
 * 注意：SQLite 不支持 RIGHT JOIN！
 * 但可以通过交换表的顺序，用 LEFT JOIN 实现相同效果
 *
 * 生活类比：
 *   "列出所有订单，以及对应的客户（如果有的话）"
 */

-- MySQL 中的 RIGHT JOIN 示例：
-- SELECT
--     c.customer_name,
--     o.order_id,
--     o.total_amount
-- FROM customers_join c
-- RIGHT JOIN orders_join o ON c.customer_id = o.customer_id;

-- 用 LEFT JOIN 实现相同效果（SQLite 兼容）
SELECT
    c.customer_name,
    o.order_id,
    o.total_amount
FROM orders_join o
LEFT JOIN customers_join c ON o.customer_id = c.customer_id;

-- =============================================
-- 第五节：CROSS JOIN 交叉连接
-- =============================================

/*
 * 【CROSS JOIN】
 *
 * 返回两个表的笛卡尔积
 * 即左表的每一行与右表的每一行组合
 *
 * 结果行数 = 左表行数 × 右表行数
 *
 * 生活类比：
 *   如果你有3件上衣和4条裤子
 *   交叉连接会返回 3×4 = 12 种搭配
 *
 * 注意：CROSS JOIN 通常用于生成测试数据或特殊场景
 * 不要轻易在大表上使用，会产生大量数据！
 */

-- 1. 基本的 CROSS JOIN
SELECT
    c.customer_name,
    p.product_name
FROM customers_join c
CROSS JOIN products_join p;
-- 结果：6个客户 × 5个商品 = 30行

-- 2. 等价的 INNER JOIN 写法
SELECT
    c.customer_name,
    p.product_name
FROM customers_join c
INNER JOIN products_join p ON 1=1;
-- ON 1=1 表示所有行都匹配

-- =============================================
-- 第六节：自连接
-- =============================================

/*
 * 【自连接】
 *
 * 一个表与自身进行连接
 * 需要给表起不同的别名
 *
 * 生活类比：
 *   "找出同城市的客户"
 *   需要将客户表与自身连接，比较每对客户的城市
 */

-- 创建一个员工表（用于演示自连接）
DROP TABLE IF EXISTS employees_self;
CREATE TABLE employees_self (
    emp_id     INTEGER PRIMARY KEY,
    emp_name   VARCHAR(50),
    manager_id INTEGER,
    FOREIGN KEY (manager_id) REFERENCES employees_self(emp_id)
);

INSERT INTO employees_self VALUES
    (1, '总经理', NULL),
    (2, '技术总监', 1),
    (3, '市场总监', 1),
    (4, '前端开发', 2),
    (5, '后端开发', 2),
    (6, '销售经理', 3);

-- 查询每个员工及其上级
SELECT
    e.emp_name AS 员工,
    m.emp_name AS 上级
FROM employees_self e
LEFT JOIN employees_self m ON e.manager_id = m.emp_id;

-- =============================================
-- 第七节：JOIN 的类型对比
-- =============================================

/*
 * 【JOIN 类型对比】
 *
 * | JOIN 类型     | 说明                           | 结果                     |
 * |--------------|-------------------------------|--------------------------|
 * | INNER JOIN   | 只返回匹配的行                  | 两表的交集                |
 * | LEFT JOIN    | 返回左表所有行 + 匹配的右表行    | 左表全部 + 交集           |
 * | RIGHT JOIN   | 返回右表所有行 + 匹配的左表行    | 右表全部 + 交集           |
 * | CROSS JOIN   | 返回笛卡尔积                   | 所有组合                  |
 *
 * 图示（用字母表示行）：
 * 表A: {1, 2, 3, 4}
 * 表B: {3, 4, 5, 6}
 *
 * INNER JOIN: {3, 4}           （交集）
 * LEFT JOIN:  {1, 2, 3, 4}     （A的全部）
 * RIGHT JOIN: {3, 4, 5, 6}     （B的全部）
 * FULL JOIN:  {1, 2, 3, 4, 5, 6}（并集，SQLite不支持）
 */

-- =============================================
-- 第八节：多表查询的性能优化
-- =============================================

/*
 * 【性能优化技巧】
 *
 * 1. 连接条件加索引
 *    ON 子句中的列应该有索引
 *
 * 2. 小表驱动大表
 *    把小表放在左边，大表放在右边
 *
 * 3. 避免不必要的 CROSS JOIN
 *    笛卡尔积会产生大量数据
 *
 * 4. 先过滤再连接
 *    在 WHERE 中先过滤，减少参与连接的数据量
 *
 * 5. 避免 SELECT *
 *    只查询需要的列
 */

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：INNER JOIN
 * Q: 查询所有已完成订单的客户姓名和订单金额
 */

SELECT
    c.customer_name,
    o.total_amount
FROM customers_join c
INNER JOIN orders_join o ON c.customer_id = o.customer_id
WHERE o.status = '已完成';

/*
 * 练习2：LEFT JOIN
 * Q: 查询所有客户的订单数量，包括没有订单的客户
 */

SELECT
    c.customer_name,
    COUNT(o.order_id) AS 订单数量
FROM customers_join c
LEFT JOIN orders_join o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

/*
 * 练习3：三表连接
 * Q: 查询每个订单的详细信息：
 *    客户名、订单日期、商品名、数量、单价
 */

SELECT
    c.customer_name,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.price
FROM customers_join c
INNER JOIN orders_join o ON c.customer_id = o.customer_id
INNER JOIN order_items_join oi ON o.order_id = oi.order_id
INNER JOIN products_join p ON oi.product_id = p.product_id;

/*
 * 练习4：查找没有订单的客户
 * Q: 使用 LEFT JOIN 找出没有任何订单的客户
 */

SELECT
    c.customer_name,
    c.email
FROM customers_join c
LEFT JOIN orders_join o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

/*
 * 练习5：统计每个商品的销售情况
 * Q: 统计每个商品的：
 *    - 销售次数
 *    - 总销售数量
 *    - 总销售金额
 *    包括没有销售记录的商品
 */

SELECT
    p.product_name,
    COUNT(oi.item_id) AS 销售次数,
    SUM(oi.quantity) AS 总销售数量,
    SUM(oi.price * oi.quantity) AS 总销售金额
FROM products_join p
LEFT JOIN order_items_join oi ON p.product_id = oi.product_id
GROUP BY p.product_name;

/*
 * 练习6：自连接练习
 * Q: 使用自连接找出住在同一城市的客户对
 */

SELECT
    a.customer_name AS 客户1,
    b.customer_name AS 客户2,
    a.city AS 城市
FROM customers_join a
INNER JOIN customers_join b ON a.city = b.city AND a.customer_id < b.customer_id;

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS order_items_join;
DROP TABLE IF EXISTS orders_join;
DROP TABLE IF EXISTS customers_join;
DROP TABLE IF EXISTS products_join;
DROP TABLE IF EXISTS employees_self;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. INNER JOIN —— 只返回两个表中都匹配的行（交集）
 * 2. LEFT JOIN —— 返回左表所有行，右表不匹配的显示 NULL
 * 3. RIGHT JOIN —— 返回右表所有行（SQLite不支持，可用LEFT JOIN交换表顺序实现）
 * 4. CROSS JOIN —— 笛卡尔积（左表每行 x 右表每行），慎用！
 * 5. 自连接 —— 表与自身连接（如找同城市的客户对）
 * 6. LEFT JOIN + WHERE IS NULL —— 找出"没有关联记录"的数据（非常实用！）
 *
 * 【常见陷阱】
 *
 * 1. 忘记写 ON 连接条件，导致笛卡尔积（数据量爆炸）
 * 2. INNER JOIN 不返回不匹配的行，需要"全部显示"时用 LEFT JOIN
 * 3. 连接条件的列应该建索引，否则大数据量时很慢
 * 4. 表名太长时用别名简化（如 customers c），但别名要有意义
 * 5. 三表以上连接时注意连接顺序，小表驱动大表
 *
 * 【下节课预告】
 *
 * 第07课将学习多表查询(下)：子查询嵌套、UNION合并结果集、
 * 复杂关联查询实战。掌握这些就能应对绝大多数查询场景！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第06课：多表查询（上）！
-- 下节课我们将学习多表查询（下）。
