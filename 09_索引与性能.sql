-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第09课：索引与性能（超级详细版）
-- =============================================
-- 第09课：索引与性能
-- B+树原理、创建索引、EXPLAIN分析、查询优化技巧

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS orders_idx;
DROP TABLE IF EXISTS customers_idx;
DROP TABLE IF EXISTS products_idx;

-- 客户表
CREATE TABLE customers_idx (
    customer_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name VARCHAR(50) NOT NULL,
    email         VARCHAR(100),
    city          VARCHAR(50),
    phone         VARCHAR(20)
);

-- 商品表
CREATE TABLE products_idx (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2),
    stock        INTEGER
);

-- 订单表
CREATE TABLE orders_idx (
    order_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id  INTEGER,
    product_id   INTEGER,
    quantity     INTEGER,
    total_amount DECIMAL(10,2),
    order_date   DATE,
    status       VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers_idx(customer_id),
    FOREIGN KEY (product_id) REFERENCES products_idx(product_id)
);

-- 插入测试数据（大量数据用于性能测试）
INSERT INTO customers_idx (customer_name, email, city, phone) VALUES
    ('张三', 'zhangsan@email.com', '北京', '13800138001'),
    ('李四', 'lisi@email.com', '上海', '13800138002'),
    ('王五', 'wangwu@email.com', '广州', '13800138003'),
    ('赵六', 'zhaoliu@email.com', '深圳', '13800138004'),
    ('钱七', 'qianqi@email.com', '杭州', '13800138005');

INSERT INTO products_idx (product_name, category, price, stock) VALUES
    ('iPhone 15', '手机', 7999.00, 100),
    ('MacBook Pro', '电脑', 14999.00, 50),
    ('AirPods Pro', '耳机', 1899.00, 200),
    ('iPad Air', '平板', 4799.00, 80),
    ('Apple Watch', '手表', 2999.00, 150);

INSERT INTO orders_idx (customer_id, product_id, quantity, total_amount, order_date, status) VALUES
    (1, 1, 1, 7999.00, '2024-01-15', '已完成'),
    (2, 2, 1, 14999.00, '2024-01-16', '已完成'),
    (1, 3, 2, 3798.00, '2024-01-17', '已发货'),
    (3, 4, 1, 4799.00, '2024-01-18', '待发货'),
    (2, 5, 1, 2999.00, '2024-01-19', '已完成'),
    (4, 1, 1, 7999.00, '2024-01-20', '已发货'),
    (1, 2, 1, 14999.00, '2024-01-21', '已完成'),
    (5, 3, 3, 5697.00, '2024-01-22', '待发货'),
    (3, 5, 2, 5998.00, '2024-01-23', '已完成'),
    (2, 4, 1, 4799.00, '2024-01-24', '已发货');

-- =============================================
-- 第一节：什么是索引？
-- =============================================

/*
 * 【什么是索引？】
 *
 * 索引就像书的目录
 *
 * 生活类比：
 *   想象一本1000页的书，你要找"数据库"这个词
 *   - 没有目录：从第1页翻到第1000页（全表扫描）
 *   - 有目录：先查目录，找到页码，直接翻到那一页（索引查找）
 *
 * 索引的作用：
 *   1. 加快查询速度（特别是大数据量）
 *   2. 加快排序速度
 *   3. 加快分组速度
 *
 * 索引的代价：
 *   1. 占用存储空间
 *   2. 降低插入、更新、删除的速度（因为要维护索引）
 *   3. 不是越多越好，需要权衡
 */

-- =============================================
-- 第二节：索引的原理 —— B+树
-- =============================================

/*
 * 【B+树索引原理】
 *
 * 大多数数据库使用 B+树作为索引结构
 *
 * B+树的特点：
 * 1. 多路平衡搜索树
 * 2. 所有数据都在叶子节点
 * 3. 叶子节点之间有指针相连
 * 4. 树的高度通常只有3-4层
 *
 * B+树的结构（简化版）：
 *
 *           [30 | 60]              <- 根节点
 *          /    |    \
 *     [10|20] [40|50] [70|80]     <- 内部节点
 *      / | \   / | \   / | \
 *    叶子节点（包含实际数据）       <- 叶子节点
 *
 * 查找过程（查找 45）：
 * 1. 从根节点开始：45 > 30 且 45 < 60，走中间
 * 2. 到内部节点：45 > 40 且 45 < 50，走中间
 * 3. 到叶子节点：找到 45
 *
 * 时间复杂度：O(log n)
 * 100万条数据，只需要 3-4 次磁盘IO
 */

-- =============================================
-- 第三节：创建索引
-- =============================================

/*
 * 【创建索引】
 *
 * 语法：CREATE INDEX 索引名 ON 表名 (列名);
 *
 * 索引的类型：
 * 1. 普通索引 —— 加速查询
 * 2. 唯一索引 —— 加速查询 + 保证唯一性
 * 3. 复合索引 —— 多列组合索引
 * 4. 主键索引 —— 自动创建
 */

-- 1. 创建普通索引
CREATE INDEX idx_orders_customer_id ON orders_idx(customer_id);
CREATE INDEX idx_orders_product_id ON orders_idx(product_id);
CREATE INDEX idx_orders_order_date ON orders_idx(order_date);

-- 2. 创建唯一索引
CREATE UNIQUE INDEX idx_customers_email ON customers_idx(email);

-- 3. 创建复合索引
CREATE INDEX idx_orders_customer_date ON orders_idx(customer_id, order_date);
-- 注意：列的顺序很重要！

-- 4. 查看表的索引（MySQL）
-- SHOW INDEX FROM orders_idx;

-- 5. 查看表的索引（SQLite）
-- PRAGMA index_list(orders_idx);

-- =============================================
-- 第四节：复合索引的最左前缀原则
-- =============================================

/*
 * 【最左前缀原则】
 *
 * 复合索引 (a, b, c) 可以加速以下查询：
 * - WHERE a = 1
 * - WHERE a = 1 AND b = 2
 * - WHERE a = 1 AND b = 2 AND c = 3
 *
 * 不能加速：
 * - WHERE b = 2
 * - WHERE c = 3
 * - WHERE b = 2 AND c = 3
 *
 * 就像查字典：
 * 你要先按拼音查，再按笔画查
 * 不能跳过拼音直接按笔画查
 *
 * 【索引选择性】
 *
 * 选择性 = 不重复值的数量 / 总行数
 * 选择性越高，索引效果越好
 *
 * 例如：
 * - 性别列（男/女）：选择性很低，不适合建索引
 * - 邮箱列（每个都不同）：选择性很高，适合建索引
 */

-- 复合索引示例
-- idx_orders_customer_date (customer_id, order_date)

-- 可以用到索引
SELECT * FROM orders_idx WHERE customer_id = 1;
SELECT * FROM orders_idx WHERE customer_id = 1 AND order_date = '2024-01-15';

-- 用不到索引（跳过了 customer_id）
SELECT * FROM orders_idx WHERE order_date = '2024-01-15';

-- =============================================
-- 第五节：EXPLAIN 查询计划
-- =============================================

/*
 * 【EXPLAIN 命令】
 *
 * 用于查看 SQL 语句的执行计划
 * 可以帮助我们理解查询是如何执行的，以及是否用到了索引
 *
 * 语法：EXPLAIN SELECT ...;
 *
 * 重要字段：
 * - type：访问类型（性能从好到差）
 *   system > const > eq_ref > ref > range > index > ALL
 * - key：实际使用的索引
 * - rows：预估扫描的行数
 * - Extra：额外信息
 */

-- 1. 全表扫描（最慢）
EXPLAIN SELECT * FROM orders_idx WHERE total_amount > 5000;
-- type: ALL，没有用到索引

-- 2. 使用索引（快）
EXPLAIN SELECT * FROM orders_idx WHERE customer_id = 1;
-- type: ref，用到了 idx_orders_customer_id 索引

-- 3. 使用复合索引
EXPLAIN SELECT * FROM orders_idx WHERE customer_id = 1 AND order_date = '2024-01-15';
-- type: ref，用到了 idx_orders_customer_date 索引

-- 4. 查看索引使用情况
EXPLAIN SELECT * FROM orders_idx
WHERE customer_id = 1
ORDER BY order_date;

-- =============================================
-- 第六节：查询优化技巧
-- =============================================

/*
 * 【查询优化技巧】
 *
 * 1. 避免 SELECT * —— 只查询需要的列
 * 2. 避免在 WHERE 中对列使用函数
 * 3. 避免使用 OR —— 尽量用 IN 或 UNION
 * 4. 避免使用 <> 或 != —— 改用范围查询
 * 5. 避免 LIKE '%abc' —— 无法使用索引
 * 6. 避免类型转换 —— 保持数据类型一致
 * 7. 小表驱动大表 —— 把小表放在前面
 * 8. 使用 LIMIT 限制结果集
 */

-- 优化示例1：避免 SELECT *
-- 慢：SELECT * FROM orders_idx WHERE customer_id = 1;
-- 快：SELECT order_id, total_amount FROM orders_idx WHERE customer_id = 1;

-- 优化示例2：避免在 WHERE 中使用函数
-- 慢：SELECT * FROM orders_idx WHERE YEAR(order_date) = 2024;
-- 快：SELECT * FROM orders_idx WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';

-- 优化示例3：使用 EXISTS 替代 IN
-- 慢：SELECT * FROM customers_idx WHERE customer_id IN (SELECT customer_id FROM orders_idx);
-- 快：SELECT * FROM customers_idx c WHERE EXISTS (SELECT 1 FROM orders_idx o WHERE o.customer_id = c.customer_id);

-- 优化示例4：使用 LIMIT
-- 慢：SELECT * FROM orders_idx ORDER BY order_date DESC;
-- 快：SELECT * FROM orders_idx ORDER BY order_date DESC LIMIT 10;

-- =============================================
-- 第七节：索引的使用场景
-- =============================================

/*
 * 【适合创建索引的场景】
 *
 * 1. 经常用于 WHERE 的列
 * 2. 经常用于 JOIN 的列
 * 3. 经常用于 ORDER BY 的列
 * 4. 经常用于 GROUP BY 的列
 * 5. 选择性高的列（不重复值多）
 *
 * 【不适合创建索引的场景】
 *
 * 1. 数据量很小的表
 * 2. 经常更新的列
 * 3. 选择性低的列（如性别）
 * 4. 很少用于查询条件的列
 */

-- =============================================
-- 第八节：删除索引
-- =============================================

/*
 * 【删除索引】
 *
 * 语法：DROP INDEX 索引名;
 *
 * 什么时候需要删除索引？
 * 1. 索引不再需要
 * 2. 索引影响了写入性能
 * 3. 需要重建索引
 */

-- 删除索引示例
-- DROP INDEX idx_orders_customer_id;
-- DROP INDEX idx_orders_product_id;

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：创建索引
 * Q: 为 customers_idx 表的 city 列创建索引
 */

CREATE INDEX idx_customers_city ON customers_idx(city);

/*
 * 练习2：复合索引设计
 * Q: 设计一个复合索引，优化以下查询：
 *    SELECT * FROM orders_idx WHERE status = '已完成' AND order_date > '2024-01-20';
 */

CREATE INDEX idx_orders_status_date ON orders_idx(status, order_date);

/*
 * 练习3：EXPLAIN 分析
 * Q: 使用 EXPLAIN 分析以下查询的执行计划：
 *    SELECT * FROM orders_idx WHERE customer_id = 1 AND order_date > '2024-01-20';
 */

EXPLAIN SELECT * FROM orders_idx WHERE customer_id = 1 AND order_date > '2024-01-20';

/*
 * 练习4：查询优化
 * Q: 优化以下查询（假设 orders_idx 表有100万行数据）：
 *    SELECT * FROM orders_idx WHERE YEAR(order_date) = 2024;
 */

-- 优化后
SELECT * FROM orders_idx
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';

/*
 * 练习5：索引选择
 * Q: 以下哪些列适合创建索引？为什么？
 *    1. 用户表的"手机号"列
 *    2. 订单表的"状态"列（只有3个值：待付款、已完成、已取消）
 *    3. 商品表的"商品名"列
 *    4. 日志表的"创建时间"列
 *
 * A: 1. 适合 —— 选择性高，经常用于查询
 *    2. 不适合 —— 选择性低，只有3个值
 *    3. 适合 —— 选择性高，经常用于搜索
 *    4. 适合 —— 经常用于范围查询和排序
 */

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS orders_idx;
DROP TABLE IF EXISTS customers_idx;
DROP TABLE IF EXISTS products_idx;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 索引 = 数据库的"目录"，加速查询（O(log n) vs O(n)全表扫描）
 * 2. B+树索引 —— 3-4层可索引百万数据，叶子节点有序链表
 * 3. 索引类型 —— 普通索引、唯一索引(UNIQUE)、复合索引(多列)
 * 4. 最左前缀原则 —— 复合索引 (a,b,c) 只能从最左列开始匹配
 * 5. EXPLAIN —— type列看访问类型(key > ref > range > ALL)
 * 6. 索引选择性 —— 不重复值/总行数，越高索引效果越好
 *
 * 【常见陷阱】
 *
 * 1. 索引不是越多越好！每个索引都会降低 INSERT/UPDATE/DELETE 速度
 * 2. WHERE 中对列使用函数（如 YEAR(col)）会导致索引失效
 * 3. LIKE '%abc' 前缀通配符无法使用索引
 * 4. 复合索引跳过最左列（如只用 b,c）无法使用索引
 * 5. 小表（几百行）不需要索引，全表扫描反而更快
 *
 * 【下节课预告】
 *
 * 第10课将学习视图与存储过程：CREATE VIEW(虚拟表)、存储过程(预编译SQL集)、
 * 函数、触发器。这些是数据库的高级功能！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第09课：索引与性能！
-- 下节课我们将学习视图与存储过程。
