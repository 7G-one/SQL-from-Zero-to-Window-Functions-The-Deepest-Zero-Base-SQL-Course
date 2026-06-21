-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第05课：聚合函数（超级详细版）
-- =============================================
-- 第05课：聚合函数
-- COUNT/SUM/AVG/MAX/MIN、GROUP BY分组、HAVING过滤

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS sales_data;
DROP TABLE IF EXISTS students_agg;

-- 销售数据表
CREATE TABLE sales_data (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    product     VARCHAR(100) NOT NULL,
    category    VARCHAR(50),
    region      VARCHAR(50),
    salesperson VARCHAR(50),
    amount      DECIMAL(10,2),
    quantity    INTEGER,
    sale_date   DATE
);

INSERT INTO sales_data (product, category, region, salesperson, amount, quantity, sale_date) VALUES
    ('iPhone 15', '手机', '北京', '张三', 7999.00, 2, '2024-01-15'),
    ('MacBook Pro', '电脑', '上海', '李四', 14999.00, 1, '2024-01-16'),
    ('AirPods Pro', '耳机', '广州', '王五', 1899.00, 3, '2024-01-17'),
    ('iPad Air', '平板', '北京', '张三', 4799.00, 1, '2024-01-18'),
    ('Apple Watch', '手表', '上海', '李四', 2999.00, 2, '2024-01-19'),
    ('iPhone 15', '手机', '广州', '王五', 7999.00, 1, '2024-01-20'),
    ('MacBook Pro', '电脑', '北京', '张三', 14999.00, 1, '2024-01-21'),
    ('AirPods Pro', '耳机', '上海', '李四', 1899.00, 2, '2024-01-22'),
    ('iPad Air', '平板', '广州', '王五', 4799.00, 1, '2024-01-23'),
    ('Apple Watch', '手表', '北京', '张三', 2999.00, 1, '2024-01-24'),
    ('iPhone 15', '手机', '上海', '李四', 7999.00, 1, '2024-01-25'),
    ('MacBook Pro', '电脑', '广州', '王五', 14999.00, 2, '2024-01-26'),
    ('AirPods Pro', '耳机', '北京', '张三', 1899.00, 1, '2024-01-27'),
    ('iPad Air', '平板', '上海', '李四', 4799.00, 2, '2024-01-28'),
    ('Apple Watch', '手表', '广州', '王五', 2999.00, 1, '2024-01-29');

-- 学生成绩表
CREATE TABLE students_agg (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    VARCHAR(50) NOT NULL,
    class   VARCHAR(20),
    subject VARCHAR(50),
    score   REAL
);

INSERT INTO students_agg (name, class, subject, score) VALUES
    ('张三', '一班', '数学', 85),
    ('张三', '一班', '语文', 78),
    ('张三', '一班', '英语', 92),
    ('李四', '一班', '数学', 90),
    ('李四', '一班', '语文', 85),
    ('李四', '一班', '英语', 88),
    ('王五', '二班', '数学', 75),
    ('王五', '二班', '语文', 82),
    ('王五', '二班', '英语', 70),
    ('赵六', '二班', '数学', 95),
    ('赵六', '二班', '语文', 90),
    ('赵六', '二班', '英语', 85),
    ('钱七', '一班', '数学', 68),
    ('钱七', '一班', '语文', 72),
    ('钱七', '一班', '英语', 75);

-- =============================================
-- 第一节：COUNT 计数函数
-- =============================================

/*
 * 【COUNT 函数】
 *
 * 用于统计行数
 *
 * 语法：
 * COUNT(*)           —— 统计所有行（包括 NULL）
 * COUNT(列名)        —— 统计该列非 NULL 的行数
 * COUNT(DISTINCT 列名) —— 统计该列不重复且非 NULL 的行数
 *
 * 生活类比：
 *   就像图书馆管理员统计：
 *   - 总共有多少本书？ COUNT(*)
 *   - 有多少本有ISBN号的书？ COUNT(ISBN)
 *   - 有多少个不同的作者？ COUNT(DISTINCT author)
 */

-- 1. 统计总行数
SELECT COUNT(*) AS 总记录数 FROM sales_data;

-- 2. 统计某列非 NULL 的行数
SELECT COUNT(salesperson) AS 有销售员的记录数 FROM sales_data;

-- 3. 统计不重复的值
SELECT COUNT(DISTINCT product) AS 不同商品数 FROM sales_data;
SELECT COUNT(DISTINCT category) AS 不同分类数 FROM sales_data;
SELECT COUNT(DISTINCT region) AS 不同区域数 FROM sales_data;
SELECT COUNT(DISTINCT salesperson) AS 不同销售员数 FROM sales_data;

-- =============================================
-- 第二节：SUM 求和函数
-- =============================================

/*
 * 【SUM 函数】
 *
 * 用于计算数值列的总和
 *
 * 语法：SUM(列名)
 *
 * 生活类比：
 *   就像计算这个月的总销售额
 */

-- 1. 计算总销售额
SELECT SUM(amount) AS 总销售额 FROM sales_data;

-- 2. 计算总销售数量
SELECT SUM(quantity) AS 总销售数量 FROM sales_data;

-- 3. 计算总销售额（考虑数量）
SELECT SUM(amount * quantity) AS 总销售额 FROM sales_data;

-- =============================================
-- 第三节：AVG 平均值函数
-- =============================================

/*
 * 【AVG 函数】
 *
 * 用于计算数值列的平均值
 *
 * 语法：AVG(列名)
 *
 * 注意：AVG 会忽略 NULL 值
 *
 * 生活类比：
 *   就像计算班级的平均分
 */

-- 1. 计算平均销售额
SELECT AVG(amount) AS 平均销售额 FROM sales_data;

-- 2. 计算平均销售数量
SELECT AVG(quantity) AS 平均销售数量 FROM sales_data;

-- 3. 计算平均分
SELECT AVG(score) AS 平均分 FROM students_agg;

-- =============================================
-- 第四节：MAX 和 MIN 函数
-- =============================================

/*
 * 【MAX 和 MIN 函数】
 *
 * MAX —— 最大值
 * MIN —— 最小值
 *
 * 生活类比：
 *   MAX 就像班级里的最高分
 *   MIN 就像班级里的最低分
 */

-- 1. 最高销售额和最低销售额
SELECT
    MAX(amount) AS 最高销售额,
    MIN(amount) AS 最低销售额
FROM sales_data;

-- 2. 最高分和最低分
SELECT
    MAX(score) AS 最高分,
    MIN(score) AS 最低分
FROM students_agg;

-- 3. 最新日期和最早日期
SELECT
    MAX(sale_date) AS 最新销售日期,
    MIN(sale_date) AS 最早销售日期
FROM sales_data;

-- =============================================
-- 第五节：GROUP BY 分组
-- =============================================

/*
 * 【GROUP BY 子句】
 *
 * 用于将数据按某个字段分组，然后对每组进行聚合计算
 *
 * 语法：
 * SELECT 列名, 聚合函数(列名)
 * FROM 表名
 * GROUP BY 列名;
 *
 * 生活类比：
 *   就像把全班同学按性别分成两组
 *   然后分别计算男生的平均分和女生的平均分
 *
 * 重要规则：
 *   SELECT 中的列，要么在 GROUP BY 中，要么是聚合函数
 */

-- 1. 按分类统计销售额
SELECT
    category AS 分类,
    SUM(amount) AS 总销售额,
    COUNT(*) AS 销售次数
FROM sales_data
GROUP BY category;

-- 2. 按区域统计销售额
SELECT
    region AS 区域,
    SUM(amount) AS 总销售额,
    COUNT(*) AS 销售次数
FROM sales_data
GROUP BY region;

-- 3. 按销售员统计销售额
SELECT
    salesperson AS 销售员,
    SUM(amount) AS 总销售额,
    COUNT(*) AS 销售次数,
    AVG(amount) AS 平均每笔金额
FROM sales_data
GROUP BY salesperson;

-- 4. 按班级统计平均分
SELECT
    class AS 班级,
    AVG(score) AS 平均分,
    MAX(score) AS 最高分,
    MIN(score) AS 最低分
FROM students_agg
GROUP BY class;

-- 5. 按科目统计平均分
SELECT
    subject AS 科目,
    AVG(score) AS 平均分,
    MAX(score) AS 最高分,
    MIN(score) AS 最低分
FROM students_agg
GROUP BY subject;

-- 6. 多列分组
SELECT
    category AS 分类,
    region AS 区域,
    SUM(amount) AS 总销售额,
    COUNT(*) AS 销售次数
FROM sales_data
GROUP BY category, region
ORDER BY category, region;

/*
 * 多列分组的含义：
 * 先按 category 分组，category 相同的再按 region 分组
 * 就像先把书按"类型"分堆，同一类型再按"出版社"分堆
 */

-- =============================================
-- 第六节：HAVING 过滤分组
-- =============================================

/*
 * 【HAVING 子句】
 *
 * 用于对 GROUP BY 的结果进行过滤
 *
 * WHERE 和 HAVING 的区别：
 * WHERE  —— 在分组前过滤（过滤行）
 * HAVING —— 在分组后过滤（过滤组）
 *
 * 生活类比：
 *   WHERE：选人的时候，只要男生（先筛选）
 *   HAVING：分组后，只要平均分大于80的组（后筛选）
 */

-- 1. 查询总销售额大于20000的分类
SELECT
    category AS 分类,
    SUM(amount) AS 总销售额
FROM sales_data
GROUP BY category
HAVING SUM(amount) > 20000;

-- 2. 查询销售次数大于3次的销售员
SELECT
    salesperson AS 销售员,
    COUNT(*) AS 销售次数
FROM sales_data
GROUP BY salesperson
HAVING COUNT(*) > 3;

-- 3. 查询平均分大于80的班级
SELECT
    class AS 班级,
    AVG(score) AS 平均分
FROM students_agg
GROUP BY class
HAVING AVG(score) > 80;

-- 4. WHERE + GROUP BY + HAVING 组合
SELECT
    category AS 分类,
    SUM(amount) AS 总销售额,
    COUNT(*) AS 销售次数
FROM sales_data
WHERE region = '北京'          -- 先过滤：只要北京的数据
GROUP BY category              -- 再分组：按分类分组
HAVING SUM(amount) > 10000     -- 最后过滤：总销售额大于10000的组
ORDER BY 总销售额 DESC;        -- 排序

/*
 * 执行顺序：
 * 1. FROM —— 从表中获取数据
 * 2. WHERE —— 过滤行
 * 3. GROUP BY —— 分组
 * 4. HAVING —— 过滤组
 * 5. SELECT —— 选择列
 * 6. ORDER BY —— 排序
 * 7. LIMIT —— 限制行数
 */

-- =============================================
-- 第七节：聚合函数的高级用法
-- =============================================

-- 1. 条件聚合（CASE WHEN + 聚合函数）
SELECT
    category AS 分类,
    SUM(CASE WHEN region = '北京' THEN amount ELSE 0 END) AS 北京销售额,
    SUM(CASE WHEN region = '上海' THEN amount ELSE 0 END) AS 上海销售额,
    SUM(CASE WHEN region = '广州' THEN amount ELSE 0 END) AS 广州销售额
FROM sales_data
GROUP BY category;

-- 2. 统计每个学生的总分和平均分
SELECT
    name AS 姓名,
    SUM(score) AS 总分,
    AVG(score) AS 平均分,
    COUNT(*) AS 科目数
FROM students_agg
GROUP BY name
ORDER BY 总分 DESC;

-- 3. 统计每个学生的最高分科目
SELECT
    name AS 姓名,
    subject AS 科目,
    score AS 分数
FROM students_agg s1
WHERE score = (
    SELECT MAX(score) FROM students_agg s2
    WHERE s2.name = s1.name
);

-- =============================================
-- 第八节：常见的聚合查询模式
-- =============================================

/*
 * 【常见的聚合查询模式】
 *
 * 1. Top N 查询：每组取前N条
 * 2. 累计求和
 * 3. 移动平均
 * 4. 同比/环比
 */

-- 1. 每个分类销售额最高的商品
SELECT
    category,
    product,
    SUM(amount) AS 总销售额
FROM sales_data s1
WHERE amount = (
    SELECT MAX(amount) FROM sales_data s2
    WHERE s2.category = s1.category
)
GROUP BY category, product;

-- 2. 统计每天的累计销售额
SELECT
    sale_date,
    SUM(amount) AS 当日销售额,
    SUM(SUM(amount)) OVER (ORDER BY sale_date) AS 累计销售额
FROM sales_data
GROUP BY sale_date
ORDER BY sale_date;
-- 注意：窗口函数 OVER 是高级语法，这里只是预告

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：基础聚合
 * Q: 统计 sales_data 表中的：
 *    1. 总销售额
 *    2. 平均每笔销售额
 *    3. 最高单笔销售额
 *    4. 最低单笔销售额
 */

SELECT
    SUM(amount) AS 总销售额,
    AVG(amount) AS 平均销售额,
    MAX(amount) AS 最高销售额,
    MIN(amount) AS 最低销售额
FROM sales_data;

/*
 * 练习2：分组统计
 * Q: 按区域统计：
 *    - 每个区域的总销售额
 *    - 每个区域的销售次数
 *    - 每个区域的平均销售额
 */

SELECT
    region AS 区域,
    SUM(amount) AS 总销售额,
    COUNT(*) AS 销售次数,
    AVG(amount) AS 平均销售额
FROM sales_data
GROUP BY region;

/*
 * 练习3：HAVING 过滤
 * Q: 查询总销售额大于30000的区域
 */

SELECT
    region AS 区域,
    SUM(amount) AS 总销售额
FROM sales_data
GROUP BY region
HAVING SUM(amount) > 30000;

/*
 * 练习4：综合练习
 * Q: 查询每个班级中：
 *    - 每个科目的平均分
 *    - 只显示平均分大于80的科目
 *    - 按班级和平均分排序
 */

SELECT
    class AS 班级,
    subject AS 科目,
    AVG(score) AS 平均分
FROM students_agg
GROUP BY class, subject
HAVING AVG(score) > 80
ORDER BY class, 平均分 DESC;

/*
 * 练习5：条件聚合
 * Q: 统计每个学生的：
 *    - 数学最高分
 *    - 语文最高分
 *    - 英语最高分
 */

SELECT
    name AS 姓名,
    MAX(CASE WHEN subject = '数学' THEN score END) AS 数学最高分,
    MAX(CASE WHEN subject = '语文' THEN score END) AS 语文最高分,
    MAX(CASE WHEN subject = '英语' THEN score END) AS 英语最高分
FROM students_agg
GROUP BY name;

/*
 * 练习6：综合统计
 * Q: 统计每个学生的：
 *    - 总分
 *    - 平均分
 *    - 最高分科目
 *    - 最低分科目
 *    - 优秀科目数（分数>=90）
 */

SELECT
    name AS 姓名,
    SUM(score) AS 总分,
    AVG(score) AS 平均分,
    MAX(score) AS 最高分,
    MIN(score) AS 最低分,
    SUM(CASE WHEN score >= 90 THEN 1 ELSE 0 END) AS 优秀科目数
FROM students_agg
GROUP BY name
ORDER BY 总分 DESC;

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS sales_data;
DROP TABLE IF EXISTS students_agg;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. COUNT(*) 统计行数，COUNT(列名) 统计非NULL行，COUNT(DISTINCT) 统计不重复值
 * 2. SUM(求和)、AVG(平均值)、MAX(最大值)、MIN(最小值)
 * 3. GROUP BY 将数据分组后对每组进行聚合计算
 * 4. HAVING 对分组结果过滤（WHERE过滤行，HAVING过滤组）
 * 5. 执行顺序：FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
 * 6. 条件聚合：SUM(CASE WHEN ... THEN ... ELSE 0 END) 实现分列统计
 *
 * 【常见陷阱】
 *
 * 1. SELECT 中的非聚合列必须出现在 GROUP BY 中，否则报错
 * 2. WHERE 不能用聚合函数（如 WHERE COUNT(*) > 3），要用 HAVING
 * 3. 聚合函数忽略 NULL 值（COUNT(列名) 不计 NULL，AVG 不含 NULL）
 * 4. COUNT(*) 和 COUNT(1) 效果相同，但 COUNT(列名) 不计 NULL
 * 5. GROUP BY 后的查询结果顺序不确定，需要显式 ORDER BY
 *
 * 【下节课预告】
 *
 * 第06课将学习多表查询(上)：INNER JOIN(内连接)、LEFT JOIN(左连接)、
 * RIGHT JOIN(右连接)、CROSS JOIN(交叉连接)。这是SQL最强大的功能！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第05课：聚合函数！
-- 下节课我们将学习多表查询（上）。
