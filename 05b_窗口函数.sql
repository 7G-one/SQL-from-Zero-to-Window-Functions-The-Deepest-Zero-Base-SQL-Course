-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第05b课：窗口函数（超级详细版）
-- =============================================
-- 第05b课：窗口函数
-- OVER()子句、ROW_NUMBER/RANK/DENSE_RANK、LAG/LEAD、
-- SUM/AVG OVER()、NTILE、PARTITION BY

-- =============================================
-- 生活类比：窗口函数是什么？
-- =============================================

/*
 * 【窗口函数 vs 聚合函数】
 *
 * 上节课我们学了聚合函数，它会把多行"压缩"成一行。
 * 比如：SELECT class, AVG(score) FROM students GROUP BY class;
 * 结果只有 2 行（每个班级一行），原始的每一行都消失了。
 *
 * 窗口函数不同——它在每一行旁边"开一个窗口"，显示汇总信息，
 * 但不会压缩行数。原始有多少行，结果还是多少行。
 *
 * 生活类比：
 *   聚合函数 = 成绩单汇总表
 *     "一班平均分 85，二班平均分 80" → 只有 2 行
 *
 *   窗口函数 = 每个同学的成绩单旁边贴了一张便利贴
 *     "小明 85 分，班级平均 85 分，班级排名第 2" → 每个人一行，但多了汇总信息
 *
 * 一句话总结：
 *   聚合函数：多行 → 一行（压缩）
 *   窗口函数：多行 → 多行（每行旁边附加信息）
 */

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS wf_sales;
DROP TABLE IF EXISTS wf_employees;
DROP TABLE IF EXISTS wf_students;

-- 销售数据表（用于累计求和、移动平均等）
CREATE TABLE wf_sales (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_month  VARCHAR(10) NOT NULL,   -- 月份
    salesperson VARCHAR(50) NOT NULL,   -- 销售员
    amount      DECIMAL(10,2) NOT NULL  -- 销售额
);

INSERT INTO wf_sales (sale_month, salesperson, amount) VALUES
    ('1月', '张三', 12000.00),
    ('2月', '张三', 15000.00),
    ('3月', '张三', 11000.00),
    ('4月', '张三', 18000.00),
    ('5月', '张三', 16000.00),
    ('6月', '张三', 20000.00),
    ('1月', '李四',  8000.00),
    ('2月', '李四',  9500.00),
    ('3月', '李四', 10000.00),
    ('4月', '李四', 12000.00),
    ('5月', '李四', 11000.00),
    ('6月', '李四', 13500.00);

-- 员工表（用于分组排名）
CREATE TABLE wf_employees (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR(50) NOT NULL,
    department  VARCHAR(50) NOT NULL,
    salary      DECIMAL(10,2) NOT NULL
);

INSERT INTO wf_employees (name, department, salary) VALUES
    ('张三', '技术部', 15000.00),
    ('李四', '市场部', 12000.00),
    ('王五', '技术部', 18000.00),
    ('赵六', '人事部', 10000.00),
    ('钱七', '财务部', 13000.00),
    ('孙八', '技术部', 20000.00),
    ('周九', '市场部', 11000.00),
    ('吴十', '技术部', 16000.00),
    ('郑一', '人事部',  9500.00),
    ('王二', '财务部', 14000.00),
    ('李三', '技术部', 22000.00),
    ('赵四', '市场部', 11500.00);

-- 学生成绩表（用于排名、分桶等）
CREATE TABLE wf_students (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    VARCHAR(50) NOT NULL,
    class   VARCHAR(20) NOT NULL,
    score   REAL NOT NULL
);

INSERT INTO wf_students (name, class, score) VALUES
    ('小明', 'A班', 85),
    ('小红', 'A班', 92),
    ('小刚', 'A班', 78),
    ('小丽', 'A班', 88),
    ('小美', 'A班', 95),
    ('小强', 'B班', 90),
    ('小王', 'B班', 88),
    ('小李', 'B班', 72),
    ('小张', 'B班', 95),
    ('小刘', 'B班', 80);

-- =============================================
-- 第一节：窗口函数基础 — OVER() 子句
-- =============================================

/*
 * 【OVER() 子句】
 *
 * 窗口函数的核心就是 OVER() 子句。
 * 它告诉 SQL："我要对这些行开一个窗口，在窗口内做计算。"
 *
 * 语法：
 *   函数名() OVER (
 *       [PARTITION BY 分区列]   -- 按什么分组（可选）
 *       [ORDER BY 排序列]       -- 按什么排序（可选）
 *   )
 *
 * 生活类比：
 *   OVER() 就像给每行发了一副"透视眼镜"。
 *   PARTITION BY = "只看本班级的同学"
 *   ORDER BY = "按分数从高到低排"
 */

-- 1. 最简单的窗口函数：给每行编号
SELECT name, class, score,
       ROW_NUMBER() OVER (ORDER BY score DESC) AS 排名
FROM wf_students;

/*
 * 预期输出（10行，每行都有排名，不会压缩）：
 *   小美|A班|95.0|1
 *   小张|B班|95.0|2
 *   小红|A班|92.0|3
 *   小强|B班|90.0|4
 *   小丽|A班|88.0|5
 *   小王|B班|88.0|6
 *   小明|A班|85.0|7
 *   小刘|B班|80.0|8
 *   小刚|A班|78.0|9
 *   小李|B班|72.0|10
 */

-- 2. 对比：聚合函数 vs 窗口函数
-- 聚合函数：压缩成每班一行
SELECT class, AVG(score) AS 平均分
FROM wf_students
GROUP BY class;

/*
 * 预期输出（只有2行）：
 *   A班|87.6
 *   B班|85.0
 */

-- 窗口函数：每行旁边显示班级平均分，不压缩
SELECT name, class, score,
       AVG(score) OVER (PARTITION BY class) AS 班级平均分
FROM wf_students;

/*
 * 预期输出（10行，每行都有班级平均分）：
 *   小明|A班|85.0|87.6
 *   小红|A班|92.0|87.6
 *   小刚|A班|78.0|87.6
 *   小丽|A班|88.0|87.6
 *   小美|A班|95.0|87.6
 *   小强|B班|90.0|85.0
 *   小王|B班|88.0|85.0
 *   小李|B班|72.0|85.0
 *   小张|B班|95.0|85.0
 *   小刘|B班|80.0|85.0
 */

-- =============================================
-- 第二节：ROW_NUMBER() — 行号
-- =============================================

/*
 * 【ROW_NUMBER()】
 *
 * 给每一行分配一个唯一的连续编号，从 1 开始。
 * 即使值相同，编号也不同（不并列）。
 *
 * 语法：ROW_NUMBER() OVER ([PARTITION BY ...] ORDER BY ...)
 *
 * 生活类比：
 *   就像排队买奶茶，先到先得，不许插队。
 *   两个人同时到？那就随便排，反正编号不同。
 */

-- 1. 全局行号：所有学生按分数排名
SELECT name, class, score,
       ROW_NUMBER() OVER (ORDER BY score DESC) AS 行号
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0|1
 *   小张|B班|95.0|2    ← 注意：同样是95分，但行号不同
 *   小红|A班|92.0|3
 *   ...
 */

-- 2. 分组行号：每个班级内按分数排名
SELECT name, class, score,
       ROW_NUMBER() OVER (PARTITION BY class ORDER BY score DESC) AS 班级排名
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0|1    ← A班第1
 *   小红|A班|92.0|2    ← A班第2
 *   小丽|A班|88.0|3
 *   小明|A班|85.0|4
 *   小刚|A班|78.0|5
 *   小张|B班|95.0|1    ← B班第1（重新从1开始）
 *   小强|B班|90.0|2
 *   小王|B班|88.0|3
 *   小刘|B班|80.0|4
 *   小李|B班|72.0|5
 */

-- 3. 实用技巧：用 ROW_NUMBER() 取每班第一名
SELECT * FROM (
    SELECT name, class, score,
           ROW_NUMBER() OVER (PARTITION BY class ORDER BY score DESC) AS rn
    FROM wf_students
) WHERE rn = 1;

/*
 * 预期输出：
 *   小美|A班|95.0|1
 *   小张|B班|95.0|1
 */

-- =============================================
-- 第三节：RANK() 和 DENSE_RANK() — 排名
-- =============================================

/*
 * 【RANK() vs DENSE_RANK() vs ROW_NUMBER()】
 *
 * 三兄弟都会给排名，但处理"并列"的方式不同：
 *
 * ROW_NUMBER() —— 永远不并列，编号连续：1, 2, 3, 4
 * RANK()       —— 并列后跳号：    1, 1, 3, 4（两个第1，没有第2）
 * DENSE_RANK() —— 并列不跳号：    1, 1, 2, 3（两个第1，下一个是第2）
 *
 * 生活类比：
 *   ROW_NUMBER() = 跑步比赛计时排名，每个人一个名次
 *   RANK()       = 奥运奖牌排名，两个金牌并列第1，下一个直接是第3
 *   DENSE_RANK() = 学校考试排名，两个第1名，下一个是第2名（不跳号）
 */

-- 1. 三种排名对比
SELECT name, class, score,
       ROW_NUMBER() OVER (ORDER BY score DESC) AS row_num,
       RANK()       OVER (ORDER BY score DESC) AS rank_num,
       DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank_num
FROM wf_students;

/*
 * 预期输出（注意小美和小张都是95分）：
 *   小美|A班|95.0|1|1|1
 *   小张|B班|95.0|2|1|1    ← ROW_NUMBER不并列，RANK和DENSE_RANK并列
 *   小红|A班|92.0|3|3|2    ← RANK跳到3，DENSE_RANK变成2
 *   小强|B班|90.0|4|4|3
 *   小丽|A班|88.0|5|5|4
 *   小王|B班|88.0|6|5|4    ← 小丽和小王并列88分
 *   小明|A班|85.0|7|7|5    ← RANK跳到7，DENSE_RANK变成5
 *   小刘|B班|80.0|8|8|6
 *   小刚|A班|78.0|9|9|7
 *   小李|B班|72.0|10|10|8
 */

-- 2. 分组排名：每个班级内排名
SELECT name, class, score,
       RANK() OVER (PARTITION BY class ORDER BY score DESC) AS 班级排名
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0|1
 *   小红|A班|92.0|2
 *   小丽|A班|88.0|3
 *   小明|A班|85.0|4
 *   小刚|A班|78.0|5
 *   小张|B班|95.0|1
 *   小强|B班|90.0|2
 *   小王|B班|88.0|3
 *   小刘|B班|80.0|4
 *   小李|B班|72.0|5
 */

-- =============================================
-- 第四节：LAG() 和 LEAD() — 前一行/后一行
-- =============================================

/*
 * 【LAG() 和 LEAD()】
 *
 * LAG(列名, N)  —— 取"往前数第 N 行"的值（默认 N=1）
 * LEAD(列名, N) —— 取"往后数第 N 行"的值（默认 N=1）
 *
 * 生活类比：
 *   LAG  = "上一个同学考了多少分？"
 *   LEAD = "下一个同学考了多少分？"
 *
 * 用途：
 *   - 计算环比（这个月 vs 上个月）
 *   - 计算与前一名的差距
 *   - 检测数据变化
 *
 * 语法：
 *   LAG(列名, 偏移量, 默认值) OVER (ORDER BY ...)
 *   LEAD(列名, 偏移量, 默认值) OVER (ORDER BY ...)
 *   偏移量默认为 1，默认值默认为 NULL
 */

-- 1. LAG：查看上一名同学的分数
SELECT name, score,
       LAG(score) OVER (ORDER BY score DESC) AS 上一名分数,
       score - LAG(score) OVER (ORDER BY score DESC) AS 与上一名差距
FROM wf_students;

/*
 * 预期输出：
 *   小美|95.0|          |        ← 第1名，没有上一名
 *   小张|95.0|95.0      |0.0     ← 与上一名同分
 *   小红|92.0|95.0      |-3.0
 *   小强|90.0|92.0      |-2.0
 *   小丽|88.0|90.0      |-2.0
 *   小王|88.0|88.0      |0.0
 *   小明|85.0|88.0      |-3.0
 *   小刘|80.0|85.0      |-5.0
 *   小刚|78.0|80.0      |-2.0
 *   小李|72.0|78.0      |-6.0
 */

-- 2. LEAD：查看下一名同学的分数
SELECT name, score,
       LEAD(score) OVER (ORDER BY score DESC) AS 下一名分数,
       score - LEAD(score) OVER (ORDER BY score DESC) AS 与下一名差距
FROM wf_students;

/*
 * 预期输出：
 *   小美|95.0|95.0|0.0
 *   小张|95.0|92.0|3.0
 *   小红|92.0|90.0|2.0
 *   ...
 *   小李|72.0|     |      ← 最后一名，没有下一名
 */

-- 3. LAG 带默认值：没有上一名时显示 0
SELECT name, score,
       LAG(score, 1, 0) OVER (ORDER BY score DESC) AS 上一名分数
FROM wf_students;

/*
 * 预期输出：
 *   小美|95.0|0.0    ← 第1名，显示默认值 0
 *   小张|95.0|95.0
 *   ...
 */

-- 4. LAG 取前第 2 名（偏移量 = 2）
SELECT name, score,
       LAG(score, 2) OVER (ORDER BY score DESC) AS 前第2名分数
FROM wf_students;

/*
 * 预期输出：
 *   小美|95.0|       ← 第1名，往前2行不存在
 *   小张|95.0|       ← 第2名，往前2行不存在
 *   小红|92.0|95.0   ← 第3名，往前2行是第1名的95分
 *   小强|90.0|95.0   ← 第4名，往前2行是第2名的95分
 *   ...
 */

-- 5. 实用案例：计算销售额环比
SELECT sale_month, salesperson, amount,
       LAG(amount) OVER (PARTITION BY salesperson ORDER BY sale_month) AS 上月销售额,
       amount - LAG(amount) OVER (PARTITION BY salesperson ORDER BY sale_month) AS 环比变化
FROM wf_sales
WHERE salesperson = '张三';

/*
 * 预期输出：
 *   1月|张三|12000.00|        |
 *   2月|张三|15000.00|12000.00|3000.00
 *   3月|张三|11000.00|15000.00|-4000.00
 *   4月|张三|18000.00|11000.00|7000.00
 *   5月|张三|16000.00|18000.00|-2000.00
 *   6月|张三|20000.00|16000.00|4000.00
 */

-- =============================================
-- 第五节：SUM() OVER() — 累计求和
-- =============================================

/*
 * 【SUM() OVER()】
 *
 * 普通 SUM() 会把所有行压缩成一行。
 * SUM() OVER() 会逐行累加，每行显示"到目前为止的总和"。
 *
 * 语法：
 *   SUM(列名) OVER (ORDER BY ...)          —— 累计求和
 *   SUM(列名) OVER (PARTITION BY ... ORDER BY ...) —— 分组累计
 *
 * 生活类比：
 *   就像记账本：
 *   - 1月花了 1000，累计 1000
 *   - 2月花了 1500，累计 2500
 *   - 3月花了 800，累计 3300
 *   每一行都显示"从开始到现在一共花了多少"
 */

-- 1. 累计销售额（张三）
SELECT sale_month, amount,
       SUM(amount) OVER (ORDER BY sale_month) AS 累计销售额
FROM wf_sales
WHERE salesperson = '张三';

/*
 * 预期输出：
 *   1月|12000.00|12000.00
 *   2月|15000.00|27000.00   ← 12000+15000
 *   3月|11000.00|38000.00   ← 27000+11000
 *   4月|18000.00|56000.00
 *   5月|16000.00|72000.00
 *   6月|20000.00|92000.00
 */

-- 2. 分组累计：每个销售员各自的累计销售额
SELECT sale_month, salesperson, amount,
       SUM(amount) OVER (PARTITION BY salesperson ORDER BY sale_month) AS 累计销售额
FROM wf_sales;

/*
 * 预期输出（张三和李四各自独立累计）：
 *   1月|张三|12000.00|12000.00
 *   1月|李四|8000.00 |8000.00
 *   2月|张三|15000.00|27000.00
 *   2月|李四|9500.00 |17500.00
 *   ...
 */

-- 3. 计算累计占比
SELECT sale_month, salesperson, amount,
       SUM(amount) OVER (PARTITION BY salesperson ORDER BY sale_month) AS 累计额,
       ROUND(
           SUM(amount) OVER (PARTITION BY salesperson ORDER BY sale_month) * 100.0
           / SUM(amount) OVER (PARTITION BY salesperson),
           2
       ) AS 累计占比百分比
FROM wf_sales
WHERE salesperson = '张三';

/*
 * 预期输出：
 *   1月|张三|12000.00|12000.00|13.04
 *   2月|张三|15000.00|27000.00|29.35
 *   3月|张三|11000.00|38000.00|41.3
 *   4月|张三|18000.00|56000.00|60.87
 *   5月|张三|16000.00|72000.00|78.26
 *   6月|张三|20000.00|92000.00|100.0
 */

-- =============================================
-- 第六节：AVG() OVER() — 移动平均
-- =============================================

/*
 * 【AVG() OVER()】
 *
 * 和 SUM() OVER() 类似，但计算的是平均值。
 * 配合 ROWS BETWEEN 可以实现"移动平均"。
 *
 * 语法：
 *   AVG(列名) OVER (ORDER BY ... ROWS BETWEEN n PRECEDING AND CURRENT ROW)
 *
 * 生活类比：
 *   移动平均就像"最近 3 天的平均气温"。
 *   今天看 1-3 号的平均，明天看 2-4 号的平均……
 *   窗口在数据上"滑动"，所以叫移动平均。
 *
 * ROWS BETWEEN 的含义：
 *   n PRECEDING  —— 往前数 n 行
 *   CURRENT ROW  —— 当前行
 *   n FOLLOWING  —— 往后数 n 行
 *   UNBOUNDED PRECEDING —— 从最开始
 *   UNBOUNDED FOLLOWING —— 到最末尾
 */

-- 1. 简单的累计平均分
SELECT name, class, score,
       AVG(score) OVER (ORDER BY id) AS 累计平均分
FROM wf_students;

/*
 * 预期输出：
 *   小明|A班|85.0|85.0     ← 只有小明，平均 85
 *   小红|A班|92.0|88.5     ← (85+92)/2 = 88.5
 *   小刚|A班|78.0|85.0     ← (85+92+78)/3 = 85
 *   小丽|A班|88.0|85.75
 *   ...
 */

-- 2. 3 日移动平均（最近 3 行的平均值）
SELECT sale_month, amount,
       ROUND(AVG(amount) OVER (
           ORDER BY sale_month
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS 三月移动平均
FROM wf_sales
WHERE salesperson = '张三';

/*
 * 预期输出：
 *   1月|12000.00|12000.00    ← 只有1行，就是自己
 *   2月|15000.00|13500.00    ← (12000+15000)/2 = 13500
 *   3月|11000.00|12666.67    ← (12000+15000+11000)/3
 *   4月|18000.00|14666.67    ← (15000+11000+18000)/3
 *   5月|16000.00|15000.00    ← (11000+18000+16000)/3
 *   6月|20000.00|18000.00    ← (18000+16000+20000)/3
 */

-- 3. 分组平均：显示每个学生与班级平均分的差距
SELECT name, class, score,
       ROUND(AVG(score) OVER (PARTITION BY class), 2) AS 班级平均分,
       ROUND(score - AVG(score) OVER (PARTITION BY class), 2) AS 与平均分差距
FROM wf_students;

/*
 * 预期输出：
 *   小明|A班|85.0 |87.6|-2.6
 *   小红|A班|92.0 |87.6|4.4
 *   小刚|A班|78.0 |87.6|-9.6
 *   小丽|A班|88.0 |87.6|0.4
 *   小美|A班|95.0 |87.6|7.4
 *   小强|B班|90.0 |85.0|5.0
 *   小王|B班|88.0 |85.0|3.0
 *   小李|B班|72.0 |85.0|-13.0
 *   小张|B班|95.0 |85.0|10.0
 *   小刘|B班|80.0 |85.0|-5.0
 */

-- =============================================
-- 第七节：NTILE() — 分桶
-- =============================================

/*
 * 【NTILE(N)】
 *
 * 把数据平均分成 N 个"桶"（组），每行分配一个桶号（从 1 开始）。
 * 如果不能整除，前面的桶会多分一行。
 *
 * 语法：NTILE(N) OVER (ORDER BY ...)
 *
 * 生活类比：
 *   就像老师把 30 个学生按成绩分成 4 组（A/B/C/D）。
 *   第 1 组：第 1-8 名（优秀）
 *   第 2 组：第 9-16 名（良好）
 *   第 3 组：第 17-24 名（中等）
 *   第 4 组：第 25-30 名（及格）
 */

-- 1. 把学生分成 2 组（高分组和低分组）
SELECT name, score,
       NTILE(2) OVER (ORDER BY score DESC) AS 分组
FROM wf_students;

/*
 * 预期输出（10人分2组，每组5人）：
 *   小美|95.0|1
 *   小张|95.0|1
 *   小红|92.0|1
 *   小强|90.0|1
 *   小丽|88.0|1
 *   小王|88.0|2
 *   小明|85.0|2
 *   小刘|80.0|2
 *   小刚|78.0|2
 *   小李|72.0|2
 */

-- 2. 分成 4 组（A/B/C/D 等级）
SELECT name, score,
       NTILE(4) OVER (ORDER BY score DESC) AS 桶号,
       CASE NTILE(4) OVER (ORDER BY score DESC)
           WHEN 1 THEN 'A（优秀）'
           WHEN 2 THEN 'B（良好）'
           WHEN 3 THEN 'C（中等）'
           WHEN 4 THEN 'D（及格）'
       END AS 等级
FROM wf_students;

/*
 * 预期输出（10人分4组，前2组3人，后2组2人）：
 *   小美|95.0|1|A（优秀）
 *   小张|95.0|1|A（优秀）
 *   小红|92.0|1|A（优秀）
 *   小强|90.0|2|B（良好）
 *   小丽|88.0|2|B（良好）
 *   小王|88.0|2|B（良好）
 *   小明|85.0|3|C（中等）
 *   小刘|80.0|3|C（中等）
 *   小刚|78.0|4|D（及格）
 *   小李|72.0|4|D（及格）
 */

-- 3. 分组分桶：每个班级内分 2 组
SELECT name, class, score,
       NTILE(2) OVER (PARTITION BY class ORDER BY score DESC) AS 组内分桶
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0|1
 *   小红|A班|92.0|1
 *   小丽|A班|88.0|1
 *   小明|A班|85.0|2
 *   小刚|A班|78.0|2
 *   小张|B班|95.0|1
 *   小强|B班|90.0|1
 *   小王|B班|88.0|1
 *   小刘|B班|80.0|2
 *   小李|B班|72.0|2
 */

-- =============================================
-- 第八节：PARTITION BY — 分区窗口详解
-- =============================================

/*
 * 【PARTITION BY 子句】
 *
 * PARTITION BY 把数据分成若干"区"（分区），窗口函数在每个分区内独立计算。
 * 就像 GROUP BY 把数据分组，但不会压缩行数。
 *
 * 对比：
 *   GROUP BY    → 分组后压缩，每组只留一行
 *   PARTITION BY → 分区后不压缩，每行都保留
 *
 * 生活类比：
 *   GROUP BY    = 把全班按性别分成男生组和女生组，每组交一张汇总表
 *   PARTITION BY = 每个同学的成绩单上写着"你是男生组/女生组的第几名"
 */

-- 1. 不用 PARTITION BY：全局排名
SELECT name, class, score,
       RANK() OVER (ORDER BY score DESC) AS 全局排名
FROM wf_students;

/*
 * 预期输出（10人混在一起排名）：
 *   小美|A班|95.0|1
 *   小张|B班|95.0|1
 *   小红|A班|92.0|3
 *   ...
 */

-- 2. 用 PARTITION BY：班级内排名
SELECT name, class, score,
       RANK() OVER (PARTITION BY class ORDER BY score DESC) AS 班级排名
FROM wf_students;

/*
 * 预期输出（A班和B班各自独立排名）：
 *   小美|A班|95.0|1
 *   小红|A班|92.0|2
 *   ...
 *   小张|B班|95.0|1
 *   小强|B班|90.0|2
 *   ...
 */

-- 3. 多列分区
SELECT sale_month, salesperson, amount,
       RANK() OVER (PARTITION BY salesperson ORDER BY amount DESC) AS 月度排名
FROM wf_sales;

/*
 * 预期输出（每个销售员各自按销售额排名）：
 *   6月|张三|20000.00|1
 *   4月|张三|18000.00|2
 *   5月|张三|16000.00|3
 *   2月|张三|15000.00|4
 *   1月|张三|12000.00|5
 *   3月|张三|11000.00|6
 *   6月|李四|13500.00|1
 *   4月|李四|12000.00|2
 *   5月|李四|11000.00|3
 *   3月|李四|10000.00|4
 *   2月|李四|9500.00 |5
 *   1月|李四|8000.00 |6
 */

-- =============================================
-- 实战项目：学生成绩排名系统
-- =============================================

/*
 * 综合运用窗口函数，构建一个完整的成绩分析系统。
 * 包含：排名、累计成绩、分差分析、分桶评级。
 */

-- 1. 完整排名报表：一次查询显示所有排名方式
SELECT name, class, score,
       ROW_NUMBER() OVER (ORDER BY score DESC)        AS 行号,
       RANK()       OVER (ORDER BY score DESC)         AS 排名,
       DENSE_RANK() OVER (ORDER BY score DESC)         AS 密集排名,
       ROW_NUMBER() OVER (PARTITION BY class ORDER BY score DESC) AS 班级排名
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0|1 |1|1|1
 *   小张|B班|95.0|2 |1|1|1
 *   小红|A班|92.0|3 |3|2|2
 *   小强|B班|90.0|4 |4|3|2
 *   小丽|A班|88.0|5 |5|4|3
 *   小王|B班|88.0|6 |5|4|3
 *   小明|A班|85.0|7 |7|5|4
 *   小刘|B班|80.0|8 |8|6|4
 *   小刚|A班|78.0|9 |9|7|5
 *   小李|B班|72.0|10|10|8|5
 */

-- 2. 与上一名的分差分析
SELECT name, score,
       LAG(score) OVER (ORDER BY score DESC) AS 上一名分数,
       score - LAG(score) OVER (ORDER BY score DESC) AS 与上一名差距,
       LEAD(score) OVER (ORDER BY score DESC) AS 下一名分数,
       score - LEAD(score) OVER (ORDER BY score DESC) AS 与下一名差距
FROM wf_students;

/*
 * 预期输出：
 *   小美|95.0|     |     |95.0|0.0
 *   小张|95.0|95.0 |0.0  |92.0|3.0
 *   小红|92.0|95.0 |-3.0 |90.0|2.0
 *   小强|90.0|92.0 |-2.0 |88.0|2.0
 *   小丽|88.0|90.0 |-2.0 |88.0|0.0
 *   小王|88.0|88.0 |0.0  |85.0|3.0
 *   小明|85.0|88.0 |-3.0 |80.0|5.0
 *   小刘|80.0|85.0 |-5.0 |78.0|2.0
 *   小刚|78.0|80.0 |-2.0 |72.0|6.0
 *   小李|72.0|78.0 |-6.0 |     |
 */

-- 3. 累计成绩与班级占比
SELECT name, class, score,
       SUM(score) OVER (PARTITION BY class ORDER BY score DESC) AS 班级累计分,
       ROUND(
           score * 100.0 / SUM(score) OVER (PARTITION BY class),
           2
       ) AS 占班级总分百分比
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0 |95.0 |21.69
 *   小红|A班|92.0 |187.0|20.91
 *   小丽|A班|88.0 |275.0|20.0
 *   小明|A班|85.0 |360.0|19.32
 *   小刚|A班|78.0 |438.0|17.73
 *   小张|B班|95.0 |95.0 |22.35
 *   小强|B班|90.0 |185.0|21.18
 *   小王|B班|88.0 |273.0|20.71
 *   小刘|B班|80.0 |353.0|18.82
 *   小李|B班|72.0 |425.0|16.94
 */

-- 4. 成绩等级分桶
SELECT name, class, score,
       NTILE(4) OVER (ORDER BY score DESC) AS 桶号,
       CASE NTILE(4) OVER (ORDER BY score DESC)
           WHEN 1 THEN 'A'
           WHEN 2 THEN 'B'
           WHEN 3 THEN 'C'
           WHEN 4 THEN 'D'
       END AS 等级
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0|1|A
 *   小张|B班|95.0|1|A
 *   小红|A班|92.0|1|A
 *   小强|B班|90.0|2|B
 *   小丽|A班|88.0|2|B
 *   小王|B班|88.0|2|B
 *   小明|A班|85.0|3|C
 *   小刘|B班|80.0|3|C
 *   小刚|A班|78.0|4|D
 *   小李|B班|72.0|4|D
 */

-- =============================================
-- 练习题
-- =============================================

-- ------------------------------------------
-- 练习1：基础 — 部门薪资排名
-- ------------------------------------------

/*
 * 题目：用 ROW_NUMBER() 给每个部门的员工按薪资从高到低排名。
 *
 * 提示：
 *   - PARTITION BY department
 *   - ORDER BY salary DESC
 */

-- 参考答案：
SELECT name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS 部门薪资排名
FROM wf_employees;

/*
 * 预期输出：
 *   李三|技术部|22000.00|1
 *   孙八|技术部|20000.00|2
 *   王五|技术部|18000.00|3
 *   吴十|技术部|16000.00|4
 *   张三|技术部|15000.00|5
 *   王二|财务部|14000.00|1
 *   钱七|财务部|13000.00|2
 *   李四|市场部|12000.00|1
 *   赵四|市场部|11500.00|2
 *   周九|市场部|11000.00|3
 *   赵六|人事部|10000.00|1
 *   郑一|人事部|9500.00 |2
 */

-- ------------------------------------------
-- 练习2：应用 — 销售额环比增长
-- ------------------------------------------

/*
 * 题目：用 LAG() 计算张三每个月的销售额环比增长率。
 *
 * 环比增长率 = (本月 - 上月) / 上月 * 100
 *
 * 提示：
 *   - 先用 LAG() 取上月销售额
 *   - 再用公式计算增长率
 *   - 用 ROUND() 保留 2 位小数
 *   - 筛选 salesperson = '张三'
 */

-- 参考答案：
SELECT sale_month, amount,
       LAG(amount) OVER (ORDER BY sale_month) AS 上月销售额,
       ROUND(
           (amount - LAG(amount) OVER (ORDER BY sale_month)) * 100.0
           / LAG(amount) OVER (ORDER BY sale_month),
           2
       ) AS 环比增长率
FROM wf_sales
WHERE salesperson = '张三';

/*
 * 预期输出：
 *   1月|12000.00|        |
 *   2月|15000.00|12000.00|25.0
 *   3月|11000.00|15000.00|-26.67
 *   4月|18000.00|11000.00|63.64
 *   5月|16000.00|18000.00|-11.11
 *   6月|20000.00|16000.00|25.0
 */

-- ------------------------------------------
-- 练习3：进阶 — 成绩分桶
-- ------------------------------------------

/*
 * 题目：用 NTILE(4) 把学生成绩分成四个等级。
 *   桶 1 = A（优秀）
 *   桶 2 = B（良好）
 *   桶 3 = C（中等）
 *   桶 4 = D（及格）
 *
 * 提示：
 *   - NTILE(4) OVER (ORDER BY score DESC)
 *   - 用 CASE WHEN 转换成等级文字
 */

-- 参考答案：
SELECT name, class, score,
       NTILE(4) OVER (ORDER BY score DESC) AS 桶号,
       CASE NTILE(4) OVER (ORDER BY score DESC)
           WHEN 1 THEN 'A（优秀）'
           WHEN 2 THEN 'B（良好）'
           WHEN 3 THEN 'C（中等）'
           WHEN 4 THEN 'D（及格）'
       END AS 等级
FROM wf_students;

/*
 * 预期输出：
 *   小美|A班|95.0|1|A（优秀）
 *   小张|B班|95.0|1|A（优秀）
 *   小红|A班|92.0|1|A（优秀）
 *   小强|B班|90.0|2|B（良好）
 *   小丽|A班|88.0|2|B（良好）
 *   小王|B班|88.0|2|B（良好）
 *   小明|A班|85.0|3|C（中等）
 *   小刘|B班|80.0|3|C（中等）
 *   小刚|A班|78.0|4|D（及格）
 *   小李|B班|72.0|4|D（及格）
 */

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS wf_sales;
DROP TABLE IF EXISTS wf_employees;
DROP TABLE IF EXISTS wf_students;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 窗口函数在每行旁边显示汇总信息，不压缩行数（与聚合函数的核心区别）
 * 2. OVER() 是窗口函数的灵魂，PARTITION BY 分区，ORDER BY 排序
 * 3. ROW_NUMBER() 永不并列，RANK() 并列跳号，DENSE_RANK() 并列不跳号
 * 4. LAG() 取前一行，LEAD() 取后一行，适合计算环比、分差
 * 5. SUM() OVER() 实现累计求和，AVG() OVER() + ROWS BETWEEN 实现移动平均
 * 6. NTILE(N) 把数据平均分成 N 个桶，适合做分层/分级
 * 7. PARTITION BY 让窗口函数在每个分区内独立计算
 *
 * 【常见陷阱】
 *
 * 1. 窗口函数不能在 WHERE 子句中使用（因为执行顺序：WHERE 在 SELECT 之前）
 *    → 解决：用子查询或 CTE 包一层
 * 2. 窗口函数中 ORDER BY 很重要：没有 ORDER BY 时，LAG/LEAD/累计结果不确定
 * 3. NTILE 不能整除时，前面的桶会多分一行（不是均匀的）
 * 4. LAG/LEAD 默认返回 NULL，不是 0，注意用第三个参数设默认值
 * 5. ROWS BETWEEN 的默认范围是 UNBOUNDED PRECEDING TO CURRENT ROW
 *
 * 【常用函数速查表】
 *
 *   函数                  用途              是否需要 ORDER BY
 *   ─────────────────────────────────────────────────────────
 *   ROW_NUMBER()          唯一行号          是
 *   RANK()                排名（跳号）      是
 *   DENSE_RANK()          排名（不跳号）    是
 *   LAG(列, n)            前第 n 行的值     是
 *   LEAD(列, n)           后第 n 行的值     是
 *   SUM() OVER()          累计求和          推荐
 *   AVG() OVER()          累计/移动平均     推荐
 *   MAX() OVER()          分区最大值        可选
 *   MIN() OVER()          分区最小值        可选
 *   COUNT() OVER()        分区计数          可选
 *   NTILE(N)              分桶              是
 *
 * 【下节课预告】
 *
 * 第06课将学习多表查询(上)：INNER JOIN(内连接)、LEFT JOIN(左连接)、
 * RIGHT JOIN(右连接)、CROSS JOIN(交叉连接)。把多张表的数据合在一起查！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第 05b 课：窗口函数！
-- 你已经掌握了 ROW_NUMBER、RANK、LAG/LEAD、SUM OVER、AVG OVER、NTILE 等核心窗口函数。
-- 下节课我们将学习多表查询——把多张表的数据合在一起查。
