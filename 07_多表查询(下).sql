-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第07课：多表查询（下）（超级详细版）
-- =============================================
-- 第07课：多表查询（下）
-- 子查询嵌套、UNION合并结果集、复杂关联查询实战

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS scores_adv;
DROP TABLE IF EXISTS courses_adv;
DROP TABLE IF EXISTS students_adv;

-- 学生表
CREATE TABLE students_adv (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name       VARCHAR(50) NOT NULL,
    class      VARCHAR(20),
    age        INTEGER
);

INSERT INTO students_adv (name, class, age) VALUES
    ('张三', '一班', 20),
    ('李四', '一班', 21),
    ('王五', '二班', 19),
    ('赵六', '二班', 22),
    ('钱七', '一班', 20),
    ('孙八', '三班', 23);

-- 课程表
CREATE TABLE courses_adv (
    course_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    course_name VARCHAR(100) NOT NULL,
    teacher     VARCHAR(50)
);

INSERT INTO courses_adv (course_name, teacher) VALUES
    ('高等数学', '张教授'),
    ('英语', '李教授'),
    ('计算机基础', '王教授'),
    ('数据结构', '赵教授');

-- 成绩表
CREATE TABLE scores_adv (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER,
    course_id  INTEGER,
    score      REAL,
    FOREIGN KEY (student_id) REFERENCES students_adv(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_adv(course_id)
);

INSERT INTO scores_adv (student_id, course_id, score) VALUES
    (1, 1, 85), (1, 2, 78), (1, 3, 90), (1, 4, 88),
    (2, 1, 92), (2, 2, 88), (2, 3, 95), (2, 4, 90),
    (3, 1, 78), (3, 2, 65), (3, 3, 82), (3, 4, 75),
    (4, 1, 95), (4, 2, 90), (4, 3, 88), (4, 4, 92),
    (5, 1, 68), (5, 2, 72), (5, 3, 75), (5, 4, 70);

-- =============================================
-- 第一节：子查询基础
-- =============================================

/*
 * 【子查询】
 *
 * 子查询就是嵌套在其他查询中的查询
 * 就像"套娃"一样，一个查询里面还有一个查询
 *
 * 语法：
 * SELECT ... FROM ... WHERE 列名 IN (SELECT ...);
 *
 * 子查询可以出现在：
 * 1. WHERE 子句中
 * 2. FROM 子句中
 * 3. SELECT 子句中
 */

-- 1. 在 WHERE 中使用子查询
-- 查询选修了"高等数学"的学生
SELECT name FROM students_adv
WHERE student_id IN (
    SELECT student_id FROM scores_adv
    WHERE course_id = (
        SELECT course_id FROM courses_adv
        WHERE course_name = '高等数学'
    )
);

/*
 * 执行顺序：
 * 1. 先执行最内层：找到"高等数学"的 course_id
 * 2. 再执行中间层：找到选修该课程的 student_id
 * 3. 最后执行外层：找到这些学生的姓名
 */

-- 2. 查询没有选修任何课程的学生
SELECT name FROM students_adv
WHERE student_id NOT IN (
    SELECT DISTINCT student_id FROM scores_adv
);

-- 3. 查询成绩高于平均分的学生
SELECT s.name, sc.score
FROM students_adv s
INNER JOIN scores_adv sc ON s.student_id = sc.student_id
WHERE sc.score > (SELECT AVG(score) FROM scores_adv);

-- =============================================
-- 第二节：EXISTS 子查询
-- =============================================

/*
 * 【EXISTS 子查询】
 *
 * EXISTS 用于判断子查询是否返回了结果
 * 如果子查询有结果，EXISTS 返回 TRUE
 *
 * 比 IN 更高效（特别是在大数据量时）
 */

-- 1. 使用 EXISTS 查询有成绩的学生
SELECT name FROM students_adv s
WHERE EXISTS (
    SELECT 1 FROM scores_adv sc
    WHERE sc.student_id = s.student_id
);

-- 2. 使用 NOT EXISTS 查询没有成绩的学生
SELECT name FROM students_adv s
WHERE NOT EXISTS (
    SELECT 1 FROM scores_adv sc
    WHERE sc.student_id = s.student_id
);

-- 3. EXISTS 与 IN 的对比
-- EXISTS：对外层查询的每一行，检查子查询是否有结果
-- IN：先执行子查询，再用结果过滤外层查询

-- =============================================
-- 第三节：UNION 合并查询
-- =============================================

/*
 * 【UNION 运算符】
 *
 * 用于合并两个或多个 SELECT 语句的结果
 *
 * 规则：
 * 1. 每个 SELECT 必须有相同数量的列
 * 2. 列的数据类型必须兼容
 * 3. UNION 会自动去重
 * 4. UNION ALL 不去重（性能更好）
 *
 * 生活类比：
 *   就像把两个名单合并成一个
 *   UNION 会去掉重复的名字
 *   UNION ALL 保留所有名字（包括重复的）
 */

-- 1. 基本的 UNION
-- 查询所有"张"姓或来自"一班"的学生
SELECT name, class FROM students_adv WHERE name LIKE '张%'
UNION
SELECT name, class FROM students_adv WHERE class = '一班';

-- 2. UNION ALL（不去重）
SELECT name, class FROM students_adv WHERE name LIKE '张%'
UNION ALL
SELECT name, class FROM students_adv WHERE class = '一班';
-- 如果有姓张的一班学生，会出现两次

-- 3. UNION 与 ORDER BY
-- ORDER BY 只能放在最后一个 SELECT 后面
SELECT name, class FROM students_adv WHERE class = '一班'
UNION
SELECT name, class FROM students_adv WHERE class = '二班'
ORDER BY name;

-- =============================================
-- 第四节：复杂关联查询
-- =============================================

/*
 * 【复杂关联查询实战】
 *
 * 实际开发中，经常需要关联多个表进行复杂查询
 */

-- 1. 查询每个学生的总分和平均分
SELECT
    s.name AS 姓名,
    s.class AS 班级,
    SUM(sc.score) AS 总分,
    AVG(sc.score) AS 平均分,
    COUNT(sc.course_id) AS 选课数
FROM students_adv s
LEFT JOIN scores_adv sc ON s.student_id = sc.student_id
GROUP BY s.student_id, s.name, s.class
ORDER BY 总分 DESC;

-- 2. 查询每门课程的最高分和最低分
SELECT
    c.course_name AS 课程,
    c.teacher AS 教师,
    MAX(sc.score) AS 最高分,
    MIN(sc.score) AS 最低分,
    AVG(sc.score) AS 平均分
FROM courses_adv c
LEFT JOIN scores_adv sc ON c.course_id = sc.course_id
GROUP BY c.course_id, c.course_name, c.teacher;

-- 3. 查询每个班级的总分排名
SELECT
    s.class AS 班级,
    SUM(sc.score) AS 班级总分,
    AVG(sc.score) AS 班级平均分
FROM students_adv s
INNER JOIN scores_adv sc ON s.student_id = sc.student_id
GROUP BY s.class
ORDER BY 班级总分 DESC;

-- 4. 查询每门课程成绩最好的学生
SELECT
    c.course_name AS 课程,
    s.name AS 学生,
    sc.score AS 分数
FROM scores_adv sc
INNER JOIN students_adv s ON sc.student_id = s.student_id
INNER JOIN courses_adv c ON sc.course_id = c.course_id
WHERE sc.score = (
    SELECT MAX(score) FROM scores_adv sc2
    WHERE sc2.course_id = sc.course_id
)
ORDER BY c.course_name;

-- 5. 查询有不及格成绩的学生
SELECT DISTINCT
    s.name AS 姓名,
    s.class AS 班级
FROM students_adv s
INNER JOIN scores_adv sc ON s.student_id = sc.student_id
WHERE sc.score < 60;

-- 6. 查询所有课程都及格的学生
SELECT
    s.name AS 姓名,
    s.class AS 班级
FROM students_adv s
WHERE NOT EXISTS (
    SELECT 1 FROM scores_adv sc
    WHERE sc.student_id = s.student_id AND sc.score < 60
);

-- =============================================
-- 第五节：多表查询的执行顺序
-- =============================================

/*
 * 【SQL 语句的执行顺序】
 *
 * 1. FROM —— 确定数据来源
 * 2. JOIN —— 连接表
 * 3. WHERE —— 过滤行
 * 4. GROUP BY —— 分组
 * 5. HAVING —— 过滤组
 * 6. SELECT —— 选择列
 * 7. DISTINCT —— 去重
 * 8. ORDER BY —— 排序
 * 9. LIMIT —— 限制行数
 *
 * 这个顺序很重要！
 * 理解执行顺序有助于写出正确的查询和优化性能
 */

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：子查询
 * Q: 查询选修了所有课程的学生
 *    （提示：使用 COUNT 比较）
 */

SELECT name FROM students_adv s
WHERE (SELECT COUNT(*) FROM scores_adv sc WHERE sc.student_id = s.student_id)
    = (SELECT COUNT(*) FROM courses_adv);

/*
 * 练习2：EXISTS
 * Q: 查询没有选修"数据结构"课程的学生
 */

SELECT name FROM students_adv s
WHERE NOT EXISTS (
    SELECT 1 FROM scores_adv sc
    INNER JOIN courses_adv c ON sc.course_id = c.course_id
    WHERE sc.student_id = s.student_id AND c.course_name = '数据结构'
);

/*
 * 练习3：UNION
 * Q: 查询成绩优秀（>=90）或不及格（<60）的学生和成绩
 */

SELECT s.name, c.course_name, sc.score
FROM scores_adv sc
INNER JOIN students_adv s ON sc.student_id = s.student_id
INNER JOIN courses_adv c ON sc.course_id = c.course_id
WHERE sc.score >= 90
UNION
SELECT s.name, c.course_name, sc.score
FROM scores_adv sc
INNER JOIN students_adv s ON sc.student_id = s.student_id
INNER JOIN courses_adv c ON sc.course_id = c.course_id
WHERE sc.score < 60
ORDER BY score DESC;

/*
 * 练习4：复杂查询
 * Q: 查询每个学生的成绩详情，显示：
 *    姓名、班级、课程名、分数、以及该课程的平均分
 *    并标记是否高于平均分
 */

SELECT
    s.name AS 姓名,
    s.class AS 班级,
    c.course_name AS 课程,
    sc.score AS 分数,
    (SELECT AVG(score) FROM scores_adv WHERE course_id = c.course_id) AS 课程平均分,
    CASE
        WHEN sc.score > (SELECT AVG(score) FROM scores_adv WHERE course_id = c.course_id)
        THEN '高于平均'
        ELSE '低于平均'
    END AS 是否高于平均
FROM scores_adv sc
INNER JOIN students_adv s ON sc.student_id = s.student_id
INNER JOIN courses_adv c ON sc.course_id = c.course_id
ORDER BY s.name, c.course_name;

/*
 * 练习5：排名查询
 * Q: 查询每个学生的总分排名（不使用窗口函数）
 */

SELECT
    s.name AS 姓名,
    s.class AS 班级,
    SUM(sc.score) AS 总分,
    (SELECT COUNT(*) FROM (
        SELECT student_id, SUM(score) AS total
        FROM scores_adv GROUP BY student_id
    ) AS t WHERE t.total > SUM(sc.score)) + 1 AS 排名
FROM students_adv s
INNER JOIN scores_adv sc ON s.student_id = sc.student_id
GROUP BY s.student_id, s.name, s.class
ORDER BY 排名;

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS scores_adv;
DROP TABLE IF EXISTS courses_adv;
DROP TABLE IF EXISTS students_adv;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 子查询 —— 嵌套在其他查询中的查询（WHERE/FROM/SELECT 中均可使用）
 * 2. EXISTS/NOT EXISTS —— 判断子查询是否有结果，通常比 IN 更高效
 * 3. UNION —— 合并多个查询结果（自动去重），UNION ALL 不去重（更快）
 * 4. UNION 规则 —— 每个 SELECT 列数和类型必须一致，ORDER BY 放最后
 * 5. SQL 执行顺序 —— FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
 *
 * 【常见陷阱】
 *
 * 1. UNION 会去重（有性能开销），如果不需要去重用 UNION ALL
 * 2. UNION 中 ORDER BY 只能放在最后一个 SELECT 后面
 * 3. 子查询中 IN 遇到 NULL 值可能返回意外结果
 * 4. 相关子查询对外层每行都执行一次，数据量大时很慢
 * 5. 理解执行顺序才能正确使用别名（WHERE 中不能用 SELECT 的别名）
 *
 * 【下节课预告】
 *
 * 第08课将深入子查询：标量子查询、行子查询、表子查询、相关子查询，
 * 以及子查询的性能优化（用JOIN替代、用EXISTS替代IN）。
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第07课：多表查询（下）！
-- 下节课我们将学习子查询详解。
