-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第11课：事务与并发（超级详细版）
-- =============================================
-- 第11课：事务与并发
-- ACID特性、BEGIN/COMMIT/ROLLBACK、隔离级别、锁与死锁

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS accounts_txn;
DROP TABLE IF EXISTS transaction_log;

-- 账户表
CREATE TABLE accounts_txn (
    account_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    account_name VARCHAR(50) NOT NULL,
    balance      DECIMAL(10,2) NOT NULL DEFAULT 0,
    CHECK (balance >= 0)
);

INSERT INTO accounts_txn (account_name, balance) VALUES
    ('张三', 10000.00),
    ('李四', 5000.00),
    ('王五', 8000.00),
    ('赵六', 3000.00);

-- 交易日志表
CREATE TABLE transaction_log (
    log_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    from_account VARCHAR(50),
    to_account   VARCHAR(50),
    amount       DECIMAL(10,2),
    log_time     DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 第一节：什么是事务？
-- =============================================

/*
 * 【什么是事务？】
 *
 * 事务是一组操作，要么全部成功，要么全部失败
 *
 * 生活类比：
 *   银行转账就是一个典型的事务
 *   张三给李四转1000元，需要两步操作：
 *   1. 张三的账户减1000元
 *   2. 李四的账户加1000元
 *
 *   这两步必须同时成功或同时失败
 *   如果第一步成功但第二步失败，钱就"消失"了！
 *
 * 事务的作用：
 *   1. 保证数据一致性
 *   2. 保证操作的原子性
 *   3. 处理并发操作
 */

-- =============================================
-- 第二节：ACID 特性
-- =============================================

/*
 * 【ACID 特性】
 *
 * A = Atomicity（原子性）
 *   事务是一个不可分割的工作单元
 *   要么全部成功，要么全部失败
 *
 * C = Consistency（一致性）
 *   事务前后，数据库从一个一致状态转换到另一个一致状态
 *   例如：转账前后，两个账户的总金额不变
 *
 * I = Isolation（隔离性）
 *   多个事务并发执行时，互不干扰
 *   每个事务都感觉不到其他事务的存在
 *
 * D = Durability（持久性）
 *   事务一旦提交，其修改就是永久性的
 *   即使系统崩溃，数据也不会丢失
 */

-- =============================================
-- 第三节：事务控制语句
-- =============================================

/*
 * 【事务控制语句】
 *
 * BEGIN / START TRANSACTION —— 开始事务
 * COMMIT —— 提交事务（保存修改）
 * ROLLBACK —— 回滚事务（撤销修改）
 * SAVEPOINT —— 设置保存点
 */

-- 1. 基本的事务操作
-- 开始事务
BEGIN TRANSACTION;

-- 张三转给李四1000元
UPDATE accounts_txn SET balance = balance - 1000 WHERE account_name = '张三';
UPDATE accounts_txn SET balance = balance + 1000 WHERE account_name = '李四';

-- 记录交易日志
INSERT INTO transaction_log (from_account, to_account, amount)
VALUES ('张三', '李四', 1000);

-- 提交事务
COMMIT;

-- 验证结果
SELECT * FROM accounts_txn;

-- 2. 回滚事务
BEGIN TRANSACTION;

-- 尝试一个错误的操作
UPDATE accounts_txn SET balance = balance - 99999 WHERE account_name = '张三';
-- 这会失败，因为 balance 不能为负（CHECK约束）

-- 回滚事务
ROLLBACK;

-- 验证（数据应该没有变化）
SELECT * FROM accounts_txn;

-- 3. 使用保存点
BEGIN TRANSACTION;

-- 第一个操作
UPDATE accounts_txn SET balance = balance - 500 WHERE account_name = '张三';
SAVEPOINT sp1;

-- 第二个操作
UPDATE accounts_txn SET balance = balance + 500 WHERE account_name = '李四';
SAVEPOINT sp2;

-- 第三个操作（假设这个操作有问题）
UPDATE accounts_txn SET balance = balance - 200 WHERE account_name = '王五';

-- 回滚到保存点 sp2（撤销第三个操作）
ROLLBACK TO sp2;

-- 提交事务
COMMIT;

-- =============================================
-- 第四节：事务隔离级别
-- =============================================

/*
 * 【事务隔离级别】
 *
 * 当多个事务同时执行时，可能会出现以下问题：
 *
 * 1. 脏读（Dirty Read）
 *    读取到其他事务未提交的数据
 *
 * 2. 不可重复读（Non-repeatable Read）
 *    同一个事务中，两次读取同一数据结果不同
 *    （其他事务修改了数据）
 *
 * 3. 幻读（Phantom Read）
 *    同一个事务中，两次查询结果的行数不同
 *    （其他事务插入或删除了数据）
 *
 * 【四种隔离级别】
 *
 * 1. READ UNCOMMITTED（读未提交）
 *    - 最低级别
 *    - 允许脏读
 *    - 几乎不用
 *
 * 2. READ COMMITTED（读已提交）
 *    - 不允许脏读
 *    - 允许不可重复读
 *    - 大多数数据库的默认级别
 *
 * 3. REPEATABLE READ（可重复读）
 *    - 不允许脏读
 *    - 不允许不可重复读
 *    - 允许幻读
 *    - MySQL 的默认级别
 *
 * 4. SERIALIZABLE（串行化）
 *    - 最高级别
 *    - 不允许任何并发问题
 *    - 性能最差
 */

-- 设置事务隔离级别（MySQL）
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 查看当前隔离级别（MySQL）
-- SELECT @@transaction_isolation;

-- =============================================
-- 第五节：锁机制
-- =============================================

/*
 * 【锁机制】
 *
 * 数据库使用锁来控制并发访问
 *
 * 锁的类型：
 *
 * 1. 共享锁（Shared Lock / S Lock）
 *    - 用于读操作
 *    - 多个事务可以同时持有共享锁
 *    - 也叫"读锁"
 *
 * 2. 排他锁（Exclusive Lock / X Lock）
 *    - 用于写操作
 *    - 同一时间只能有一个事务持有排他锁
 *    - 也叫"写锁"
 *
 * 锁的兼容性：
 * | 请求的锁 | 已持有的锁 | S锁 | X锁 |
 * |---------|-----------|-----|-----|
 * | S锁     |           | 兼容 | 冲突 |
 * | X锁     |           | 冲突 | 冲突 |
 *
 * 锁的粒度：
 * 1. 表级锁 —— 锁定整个表
 * 2. 行级锁 —— 锁定单行（InnoDB支持）
 * 3. 页级锁 —— 锁定数据页
 */

-- MySQL 中的锁示例
-- SELECT ... LOCK IN SHARE MODE;  -- 加共享锁
-- SELECT ... FOR UPDATE;          -- 加排他锁

-- =============================================
-- 第六节：死锁
-- =============================================

/*
 * 【什么是死锁？】
 *
 * 两个或多个事务互相等待对方释放锁，导致都无法继续
 *
 * 生活类比：
 *   两个人在狭窄的走廊相遇
 *   A 要往左走，B 也要往左走
 *   A 等 B 让路，B 等 A 让路
 *   结果谁也走不了！
 *
 * 死锁的例子：
 *   事务1：锁定行A，等待锁定行B
 *   事务2：锁定行B，等待锁定行A
 *   两个事务互相等待，形成死锁
 *
 * 【如何处理死锁？】
 *
 * 1. 数据库自动检测死锁
 *    - 数据库会定期检查是否存在死锁
 *    - 如果发现死锁，会选择一个事务回滚（牺牲者）
 *
 * 2. 设置超时时间
 *    - 如果等待锁的时间超过阈值，自动回滚
 *
 * 3. 预防死锁
 *    - 按固定顺序访问表和行
 *    - 减少事务持有锁的时间
 *    - 使用较低的隔离级别
 */

-- =============================================
-- 第七节：事务的最佳实践
-- =============================================

/*
 * 【事务的最佳实践】
 *
 * 1. 保持事务短小
 *    事务越长，持锁时间越长，影响并发性能
 *
 * 2. 避免在事务中等待用户输入
 *    用户可能几个小时才响应，锁会被持有几个小时
 *
 * 3. 使用合适的隔离级别
 *    不是越高越好，要根据业务需求选择
 *
 * 4. 按固定顺序访问表和行
 *    可以减少死锁的概率
 *
 * 5. 添加适当的错误处理
 *    捕获异常，及时回滚
 */

-- 事务示例：转账操作（带错误处理）
-- 这是伪代码，实际语法取决于数据库

/*
-- MySQL 事务示例
START TRANSACTION;

-- 记录转出
UPDATE accounts_txn SET balance = balance - 1000
WHERE account_name = '张三' AND balance >= 1000;

-- 检查是否成功
IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SELECT '余额不足' AS error;
ELSE
    -- 记录转入
    UPDATE accounts_txn SET balance = balance + 1000
    WHERE account_name = '李四';

    -- 记录日志
    INSERT INTO transaction_log (from_account, to_account, amount)
    VALUES ('张三', '李四', 1000);

    COMMIT;
    SELECT '转账成功' AS message;
END IF;
*/

-- =============================================
-- 第八节：并发控制的实际应用
-- =============================================

/*
 * 【实际应用场景】
 *
 * 1. 电商秒杀
 *    - 高并发下保证库存扣减正确
 *    - 使用悲观锁或乐观锁
 *
 * 2. 银行转账
 *    - 保证资金安全
 *    - 使用事务保证原子性
 *
 * 3. 订票系统
 *    - 防止超卖
 *    - 使用行级锁
 */

-- 乐观锁示例（使用版本号）
-- 假设表中有 version 字段
-- UPDATE products SET stock = stock - 1, version = version + 1
-- WHERE product_id = 1 AND version = 1;
-- 如果 affected_rows = 0，说明被其他事务修改了

-- 悲观锁示例
-- SELECT * FROM products WHERE product_id = 1 FOR UPDATE;
-- 然后再更新

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：事务基础
 * Q: 使用事务完成以下操作：
 *    1. 从张三账户转2000元给王五
 *    2. 记录交易日志
 *    3. 如果张三余额不足，回滚事务
 */

BEGIN TRANSACTION;

-- 检查余额并转出
UPDATE accounts_txn SET balance = balance - 2000
WHERE account_name = '张三' AND balance >= 2000;

-- 这里应该检查影响的行数，但 SQLite 的检查方式不同
-- 在实际应用中，需要使用编程语言来检查

-- 转入
UPDATE accounts_txn SET balance = balance + 2000
WHERE account_name = '王五';

-- 记录日志
INSERT INTO transaction_log (from_account, to_account, amount)
VALUES ('张三', '王五', 2000);

COMMIT;

-- 验证
SELECT * FROM accounts_txn;

/*
 * 练习2：保存点
 * Q: 使用保存点完成以下操作：
 *    1. 从李四账户转1000元给赵六（保存点1）
 *    2. 从赵六账户转500元给张三（保存点2）
 *    3. 如果第二步失败，回滚到保存点1
 */

BEGIN TRANSACTION;

-- 第一步
UPDATE accounts_txn SET balance = balance - 1000
WHERE account_name = '李四';
UPDATE accounts_txn SET balance = balance + 1000
WHERE account_name = '赵六';
SAVEPOINT sp_transfer1;

-- 第二步
UPDATE accounts_txn SET balance = balance - 500
WHERE account_name = '赵六';
UPDATE accounts_txn SET balance = balance + 500
WHERE account_name = '张三';
SAVEPOINT sp_transfer2;

-- 假设第二步成功，提交
COMMIT;

/*
 * 练习3：理解隔离级别
 * Q: 解释以下场景分别会出现什么问题：
 *    1. 事务A读取数据，事务B修改了数据但未提交，事务A再次读取
 *    2. 事务A读取数据，事务B修改了数据并提交，事务A再次读取
 *    3. 事务A查询数据，事务B插入了新数据，事务A再次查询
 *
 * A: 1. 脏读 —— 事务A读取到事务B未提交的数据
 *    2. 不可重复读 —— 事务A两次读取结果不同
 *    3. 幻读 —— 事务A两次查询结果的行数不同
 */

/*
 * 练习4：死锁预防
 * Q: 以下两个事务可能会产生死锁，如何修改可以避免？
 *
 *    事务1：
 *    UPDATE accounts SET balance = balance - 100 WHERE id = 1;
 *    UPDATE accounts SET balance = balance + 100 WHERE id = 2;
 *
 *    事务2：
 *    UPDATE accounts SET balance = balance - 200 WHERE id = 2;
 *    UPDATE accounts SET balance = balance + 200 WHERE id = 1;
 *
 * A: 按固定顺序访问行（总是先访问 id 小的行）：
 *
 *    事务1：
 *    UPDATE accounts SET balance = balance - 100 WHERE id = 1;
 *    UPDATE accounts SET balance = balance + 100 WHERE id = 2;
 *
 *    事务2：
 *    UPDATE accounts SET balance = balance + 200 WHERE id = 1;
 *    UPDATE accounts SET balance = balance - 200 WHERE id = 2;
 */

/*
 * 练习5：事务设计
 * Q: 设计一个简单的"购物车结算"事务，包含：
 *    1. 检查商品库存
 *    2. 扣减库存
 *    3. 创建订单
 *    4. 记录订单明细
 *
 * 写出伪代码即可
 */

/*
-- 购物车结算事务
START TRANSACTION;

-- 1. 检查库存
SELECT stock INTO @current_stock
FROM products WHERE product_id = 1;

IF @current_stock < 2 THEN
    ROLLBACK;
    SELECT '库存不足' AS error;
ELSE
    -- 2. 扣减库存
    UPDATE products SET stock = stock - 2
    WHERE product_id = 1;

    -- 3. 创建订单
    INSERT INTO orders (customer_id, total_amount, order_date)
    VALUES (1, 15998.00, NOW());

    -- 获取订单ID
    SET @order_id = LAST_INSERT_ID();

    -- 4. 记录订单明细
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES (@order_id, 1, 2, 7999.00);

    COMMIT;
    SELECT '结算成功' AS message;
END IF;
*/

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS transaction_log;
DROP TABLE IF EXISTS accounts_txn;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 事务 = 一组操作，要么全部成功(COMMIT)，要么全部失败(ROLLBACK)
 * 2. ACID —— 原子性、一致性、隔离性、持久性
 * 3. BEGIN/COMMIT/ROLLBACK 控制事务，SAVEPOINT 设置保存点
 * 4. 隔离级别 —— 读未提交(脏读) -> 读已提交 -> 可重复读 -> 串行化
 * 5. 锁 —— 共享锁(S锁/读锁) vs 排他锁(X锁/写锁)
 * 6. 死锁预防 —— 按固定顺序访问表和行，减少事务持有时间
 *
 * 【常见陷阱】
 *
 * 1. 事务太长会持锁太久，影响并发性能
 * 2. 事务中不要等待用户输入（锁会被持有几小时）
 * 3. 忘记 COMMIT/ROLLBACK 会导致事务一直持有锁
 * 4. 隔离级别越高性能越差，不是越高越好
 * 5. 按不同顺序访问表和行容易产生死锁
 *
 * 【下节课预告】
 *
 * 第12课将学习数据库设计：ER图、数据库范式(1NF/2NF/3NF)、
 * 反范式设计、设计原则。这是设计好数据库的基础！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第11课：事务与并发！
-- 下节课我们将学习数据库设计。
