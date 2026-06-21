-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第10课：视图与存储过程（超级详细版）
-- =============================================
-- 第10课：视图与存储过程
-- CREATE VIEW(虚拟表)、存储过程、函数、触发器

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS sales_vp;
DROP TABLE IF EXISTS products_vp;
DROP TABLE IF EXISTS customers_vp;

-- 客户表
CREATE TABLE customers_vp (
    customer_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name VARCHAR(50) NOT NULL,
    email         VARCHAR(100),
    city          VARCHAR(50),
    vip_level     INTEGER DEFAULT 0
);

INSERT INTO customers_vp (customer_name, email, city, vip_level) VALUES
    ('张三', 'zhangsan@email.com', '北京', 2),
    ('李四', 'lisi@email.com', '上海', 1),
    ('王五', 'wangwu@email.com', '广州', 0),
    ('赵六', 'zhaoliu@email.com', '深圳', 3),
    ('钱七', 'qianqi@email.com', '杭州', 1);

-- 商品表
CREATE TABLE products_vp (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2),
    stock        INTEGER
);

INSERT INTO products_vp (product_name, category, price, stock) VALUES
    ('iPhone 15', '手机', 7999.00, 100),
    ('MacBook Pro', '电脑', 14999.00, 50),
    ('AirPods Pro', '耳机', 1899.00, 200),
    ('iPad Air', '平板', 4799.00, 80),
    ('Apple Watch', '手表', 2999.00, 150);

-- 销售表
CREATE TABLE sales_vp (
    sale_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    product_id  INTEGER,
    quantity    INTEGER,
    sale_date   DATE,
    FOREIGN KEY (customer_id) REFERENCES customers_vp(customer_id),
    FOREIGN KEY (product_id) REFERENCES products_vp(product_id)
);

INSERT INTO sales_vp (customer_id, product_id, quantity, sale_date) VALUES
    (1, 1, 1, '2024-01-15'),
    (2, 2, 1, '2024-01-16'),
    (1, 3, 2, '2024-01-17'),
    (3, 4, 1, '2024-01-18'),
    (2, 5, 1, '2024-01-19'),
    (4, 1, 1, '2024-01-20'),
    (1, 2, 1, '2024-01-21'),
    (5, 3, 3, '2024-01-22'),
    (3, 5, 2, '2024-01-23'),
    (2, 4, 1, '2024-01-24');

-- =============================================
-- 第一节：什么是视图？
-- =============================================

/*
 * 【什么是视图？】
 *
 * 视图是一个虚拟表，它基于 SQL 查询的结果
 * 视图不存储数据，只存储查询定义
 *
 * 生活类比：
 *   视图就像一个"快捷方式"
 *   你经常需要查"北京客户的订单"
 *   与其每次都写复杂的 SQL，不如创建一个视图
 *   以后直接 SELECT * FROM 北京客户订单
 *
 * 视图的优点：
 * 1. 简化复杂查询
 * 2. 提高安全性（只暴露需要的列）
 * 3. 提供数据独立性
 * 4. 可以重用 SQL 逻辑
 *
 * 视图的缺点：
 * 1. 性能可能不如直接查询
 * 2. 更新视图可能有限制
 * 3. 复杂视图可能难以维护
 */

-- =============================================
-- 第二节：创建视图
-- =============================================

/*
 * 【创建视图】
 *
 * 语法：
 * CREATE VIEW 视图名 AS
 * SELECT 语句;
 */

-- 1. 创建简单的视图
CREATE VIEW v_customer_sales AS
SELECT
    c.customer_name,
    c.city,
    p.product_name,
    p.category,
    s.quantity,
    p.price * s.quantity AS total_amount,
    s.sale_date
FROM sales_vp s
INNER JOIN customers_vp c ON s.customer_id = c.customer_id
INNER JOIN products_vp p ON s.product_id = p.product_id;

-- 使用视图（就像查询普通表一样）
SELECT * FROM v_customer_sales;

-- 2. 创建带条件的视图
CREATE VIEW v_beijing_customers AS
SELECT * FROM customers_vp WHERE city = '北京';

SELECT * FROM v_beijing_customers;

-- 3. 创建统计视图
CREATE VIEW v_product_sales_stats AS
SELECT
    p.product_name,
    p.category,
    COUNT(s.sale_id) AS 销售次数,
    SUM(s.quantity) AS 总销量,
    SUM(s.quantity * p.price) AS 总销售额
FROM products_vp p
LEFT JOIN sales_vp s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category;

SELECT * FROM v_product_sales_stats;

-- =============================================
-- 第三节：修改和删除视图
-- =============================================

/*
 * 【修改视图】
 *
 * 语法：CREATE OR REPLACE VIEW 视图名 AS SELECT ...;
 * 或者：ALTER VIEW 视图名 AS SELECT ...;
 */

-- 修改视图（SQLite 使用 CREATE OR REPLACE）
CREATE OR REPLACE VIEW v_beijing_customers AS
SELECT customer_id, customer_name, email
FROM customers_vp
WHERE city = '北京';

/*
 * 【删除视图】
 *
 * 语法：DROP VIEW 视图名;
 */

-- 删除视图
-- DROP VIEW IF EXISTS v_beijing_customers;

-- =============================================
-- 第四节：视图的更新
-- =============================================

/*
 * 【视图的更新限制】
 *
 * 不是所有视图都可以更新！
 * 以下情况的视图不能更新：
 * 1. 包含聚合函数（COUNT、SUM、AVG等）
 * 2. 包含 DISTINCT
 * 3. 包含 GROUP BY
 * 4. 包含 HAVING
 * 5. 包含 UNION
 * 6. 包含子查询
 * 7. 包含 JOIN（某些数据库）
 *
 * 可更新的视图通常是简单的单表查询
 */

-- 可更新的视图（简单单表查询）
CREATE VIEW v_active_customers AS
SELECT * FROM customers_vp WHERE vip_level > 0;

-- 通过视图更新数据
UPDATE v_active_customers SET vip_level = 2 WHERE customer_name = '李四';

-- 验证
SELECT * FROM customers_vp WHERE customer_name = '李四';

-- =============================================
-- 第五节：什么是存储过程？
-- =============================================

/*
 * 【什么是存储过程？】
 *
 * 存储过程是一组预编译的 SQL 语句
 * 存储在数据库中，可以通过名字调用
 *
 * 生活类比：
 *   存储过程就像一个"菜谱"
 *   你把做菜的步骤写下来，以后要做这道菜时
 *   只需要说"做红烧肉"，厨师就会按照菜谱来做
 *
 * 存储过程的优点：
 * 1. 提高性能（预编译）
 * 2. 减少网络传输
 * 3. 提高安全性
 * 4. 代码重用
 * 5. 可以包含复杂的业务逻辑
 *
 * 存储过程的缺点：
 * 1. 不同数据库语法不同（可移植性差）
 * 2. 调试困难
 * 3. 版本管理困难
 */

/*
 * 注意：SQLite 不支持存储过程！
 * 以下示例是 MySQL 语法
 * 如果你使用 SQLite，可以跳过这部分
 */

-- =============================================
-- 第六节：MySQL 存储过程语法
-- =============================================

/*
 * 【MySQL 存储过程语法】
 *
 * DELIMITER //
 * CREATE PROCEDURE 存储过程名(参数列表)
 * BEGIN
 *     SQL 语句;
 * END //
 * DELIMITER ;
 *
 * 调用：CALL 存储过程名(参数);
 */

-- 示例1：简单的存储过程（MySQL）
-- DELIMITER //
-- CREATE PROCEDURE sp_get_all_customers()
-- BEGIN
--     SELECT * FROM customers_vp;
-- END //
-- DELIMITER ;

-- 调用
-- CALL sp_get_all_customers();

-- 示例2：带参数的存储过程（MySQL）
-- DELIMITER //
-- CREATE PROCEDURE sp_get_customers_by_city(IN city_name VARCHAR(50))
-- BEGIN
--     SELECT * FROM customers_vp WHERE city = city_name;
-- END //
-- DELIMITER ;

-- 调用
-- CALL sp_get_customers_by_city('北京');

-- 示例3：带输出参数的存储过程（MySQL）
-- DELIMITER //
-- CREATE PROCEDURE sp_get_customer_count(OUT total INT)
-- BEGIN
--     SELECT COUNT(*) INTO total FROM customers_vp;
-- END //
-- DELIMITER ;

-- 调用
-- CALL sp_get_customer_count(@total);
-- SELECT @total;

-- 示例4：带条件逻辑的存储过程（MySQL）
-- DELIMITER //
-- CREATE PROCEDURE sp_check_stock(IN prod_id INT)
-- BEGIN
--     DECLARE current_stock INT;
--     SELECT stock INTO current_stock FROM products_vp WHERE product_id = prod_id;
--     IF current_stock > 100 THEN
--         SELECT '库存充足' AS status;
--     ELSEIF current_stock > 50 THEN
--         SELECT '库存正常' AS status;
--     ELSE
--         SELECT '库存不足' AS status;
--     END IF;
-- END //
-- DELIMITER ;

-- =============================================
-- 第七节：函数（MySQL）
-- =============================================

/*
 * 【函数 vs 存储过程】
 *
 * 函数：
 * - 必须返回一个值
 * - 可以在 SQL 语句中使用
 * - 不能修改数据库状态
 *
 * 存储过程：
 * - 可以不返回值
 * - 需要 CALL 调用
 * - 可以修改数据库状态
 */

-- 示例：创建函数（MySQL）
-- DELIMITER //
-- CREATE FUNCTION fn_calculate_discount(price DECIMAL(10,2), vip_level INT)
-- RETURNS DECIMAL(10,2)
-- DETERMINISTIC
-- BEGIN
--     DECLARE discount DECIMAL(10,2);
--     CASE vip_level
--         WHEN 1 THEN SET discount = price * 0.95;
--         WHEN 2 THEN SET discount = price * 0.90;
--         WHEN 3 THEN SET discount = price * 0.85;
--         ELSE SET discount = price;
--     END CASE;
--     RETURN discount;
-- END //
-- DELIMITER ;

-- 使用函数
-- SELECT product_name, price, fn_calculate_discount(price, 2) AS 折后价
-- FROM products_vp;

-- =============================================
-- 第八节：触发器（Trigger）
-- =============================================

/*
 * 【什么是触发器？】
 *
 * 触发器是自动执行的存储过程
 * 当某个事件发生时（INSERT、UPDATE、DELETE）自动触发
 *
 * 生活类比：
 *   触发器就像"自动报警器"
 *   当烟雾浓度超标时，自动触发报警
 *
 * 触发器的类型：
 * - BEFORE INSERT —— 插入前触发
 * - AFTER INSERT —— 插入后触发
 * - BEFORE UPDATE —— 更新前触发
 * - AFTER UPDATE —— 更新后触发
 * - BEFORE DELETE —— 删除前触发
 * - AFTER DELETE —— 删除后触发
 */

-- 示例：创建触发器（MySQL）
-- 记录价格变动历史
-- DELIMITER //
-- CREATE TRIGGER trg_price_change
-- BEFORE UPDATE ON products_vp
-- FOR EACH ROW
-- BEGIN
--     IF OLD.price != NEW.price THEN
--         INSERT INTO price_history (product_id, old_price, new_price, change_date)
--         VALUES (OLD.product_id, OLD.price, NEW.price, NOW());
--     END IF;
-- END //
-- DELIMITER ;

-- =============================================
-- 第九节：SQLite 的替代方案
-- =============================================

/*
 * 【SQLite 不支持存储过程和触发器语法】
 *
 * 但 SQLite 支持：
 * 1. 视图（CREATE VIEW）
 * 2. 触发器（CREATE TRIGGER）
 * 3. 事务（BEGIN、COMMIT、ROLLBACK）
 *
 * 如果需要存储过程的功能，可以：
 * 1. 在应用程序中实现逻辑
 * 2. 使用多个 SQL 语句组合
 */

-- SQLite 触发器示例
-- CREATE TRIGGER IF NOT EXISTS trg_update_stock
-- AFTER INSERT ON sales_vp
-- BEGIN
--     UPDATE products_vp
--     SET stock = stock - NEW.quantity
--     WHERE product_id = NEW.product_id;
-- END;

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：创建视图
 * Q: 创建一个视图，显示每个客户的购买统计：
 *    客户名、购买次数、总金额
 */

CREATE OR REPLACE VIEW v_customer_purchase_stats AS
SELECT
    c.customer_name,
    COUNT(s.sale_id) AS 购买次数,
    SUM(s.quantity * p.price) AS 总金额
FROM customers_vp c
LEFT JOIN sales_vp s ON c.customer_id = s.customer_id
LEFT JOIN products_vp p ON s.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name;

SELECT * FROM v_customer_purchase_stats;

/*
 * 练习2：视图查询
 * Q: 使用视图查询总金额大于10000的客户
 */

SELECT * FROM v_customer_purchase_stats WHERE 总金额 > 10000;

/*
 * 练习3：创建统计视图
 * Q: 创建一个视图，显示每个分类的销售统计：
 *    分类名、商品数、总销量、总销售额
 */

CREATE OR REPLACE VIEW v_category_sales_stats AS
SELECT
    p.category AS 分类名,
    COUNT(DISTINCT p.product_id) AS 商品数,
    SUM(s.quantity) AS 总销量,
    SUM(s.quantity * p.price) AS 总销售额
FROM products_vp p
LEFT JOIN sales_vp s ON p.product_id = s.product_id
GROUP BY p.category;

SELECT * FROM v_category_sales_stats;

/*
 * 练习4：删除视图
 * Q: 删除之前创建的视图
 */

DROP VIEW IF EXISTS v_customer_purchase_stats;
DROP VIEW IF EXISTS v_category_sales_stats;

/*
 * 练习5：设计存储过程（MySQL）
 * Q: 设计一个存储过程，实现以下功能：
 *    输入客户ID和商品ID，自动创建订单
 *    如果库存不足，返回错误信息
 *
 * 答案（MySQL语法）：
 * DELIMITER //
 * CREATE PROCEDURE sp_create_order(
 *     IN p_customer_id INT,
 *     IN p_product_id INT,
 *     IN p_quantity INT
 * )
 * BEGIN
 *     DECLARE current_stock INT;
 *     DECLARE product_price DECIMAL(10,2);
 *     DECLARE order_total DECIMAL(10,2);
 *
 *     -- 检查库存
 *     SELECT stock, price INTO current_stock, product_price
 *     FROM products_vp WHERE product_id = p_product_id;
 *
 *     IF current_stock < p_quantity THEN
 *         SIGNAL SQLSTATE '45000'
 *         SET MESSAGE_TEXT = '库存不足';
 *     ELSE
 *         -- 计算总价
 *         SET order_total = product_price * p_quantity;
 *
 *         -- 创建订单
 *         INSERT INTO sales_vp (customer_id, product_id, quantity, sale_date)
 *         VALUES (p_customer_id, p_product_id, p_quantity, CURDATE());
 *
 *         -- 更新库存
 *         UPDATE products_vp
 *         SET stock = stock - p_quantity
 *         WHERE product_id = p_product_id;
 *
 *         SELECT '订单创建成功' AS message;
 *     END IF;
 * END //
 * DELIMITER ;
 */

-- =============================================
-- 清理
-- =============================================
DROP VIEW IF EXISTS v_customer_sales;
DROP VIEW IF EXISTS v_beijing_customers;
DROP VIEW IF EXISTS v_product_sales_stats;
DROP VIEW IF EXISTS v_active_customers;
DROP TABLE IF EXISTS sales_vp;
DROP TABLE IF EXISTS products_vp;
DROP TABLE IF EXISTS customers_vp;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 视图 = 虚拟表，基于 SELECT 查询，不存储数据（简化复杂查询）
 * 2. CREATE VIEW / CREATE OR REPLACE VIEW / DROP VIEW
 * 3. 可更新视图 —— 简单单表查询的视图可以通过视图修改数据
 * 4. 存储过程 —— 预编译的SQL语句集，通过 CALL 调用（MySQL语法）
 * 5. 触发器 —— INSERT/UPDATE/DELETE 时自动执行的代码
 * 6. SQLite 支持视图和触发器，但不支持存储过程
 *
 * 【常见陷阱】
 *
 * 1. 包含聚合函数/DISTINCT/GROUP BY/JOIN 的视图通常不可更新
 * 2. 视图只是"快捷方式"，不会加速查询（可能更慢）
 * 3. 存储过程语法在 MySQL/PostgreSQL/SQL Server 之间差异很大
 * 4. 触发器中的错误不容易调试，慎用
 * 5. 删除视图不会影响原始表的数据
 *
 * 【下节课预告】
 *
 * 第11课将学习事务与并发：ACID特性、BEGIN/COMMIT/ROLLBACK、
 * 事务隔离级别、锁机制、死锁处理。这是保证数据一致性的核心！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第10课：视图与存储过程！
-- 下节课我们将学习事务与并发。
