-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第03课：条件查询（超级详细版）
-- =============================================
-- 第03课：条件查询
-- 比较运算、逻辑运算、LIKE模糊匹配、IN/BETWEEN、CASE WHEN

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS students_demo;
DROP TABLE IF EXISTS courses_demo;
DROP TABLE IF EXISTS scores_demo;

-- 学生表
CREATE TABLE students_demo (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    name     VARCHAR(50) NOT NULL,
    age      INTEGER,
    gender   CHAR(1),
    city     VARCHAR(50),
    grade    VARCHAR(20),
    score    REAL,
    email    VARCHAR(100),
    phone    VARCHAR(20),
    enroll_date DATE
);

-- 插入学生数据
INSERT INTO students_demo (name, age, gender, city, grade, score, email, phone, enroll_date) VALUES
    ('张三', 20, 'M', '北京', '大一', 85.5, 'zhangsan@email.com', '13800138001', '2023-09-01'),
    ('李四', 21, 'F', '上海', '大二', 92.0, 'lisi@email.com', '13800138002', '2022-09-01'),
    ('王五', 19, 'M', '广州', '大一', 78.5, 'wangwu@email.com', '13800138003', '2023-09-01'),
    ('赵六', 22, 'F', '深圳', '大三', 95.0, 'zhaoliu@email.com', '13800138004', '2021-09-01'),
    ('钱七', 20, 'M', '杭州', '大二', 68.0, 'qianqi@email.com', '13800138005', '2022-09-01'),
    ('孙八', 23, 'F', '北京', '大四', 88.5, NULL, '13800138006', '2020-09-01'),
    ('周九', 19, 'M', '上海', '大一', 72.0, 'zhoujiu@email.com', NULL, '2023-09-01'),
    ('吴十', 21, 'F', '广州', '大二', 91.5, 'wushi@email.com', '13800138008', '2022-09-01'),
    ('郑一', 20, 'M', '深圳', '大一', 55.0, 'zhengyi@email.com', '13800138009', '2023-09-01'),
    ('王二', 24, 'F', '杭州', '大四', 99.0, 'wanger@email.com', '13800138010', '2020-09-01');

-- 课程表
CREATE TABLE courses_demo (
    course_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    course_name VARCHAR(100) NOT NULL,
    teacher     VARCHAR(50),
    credit      INTEGER
);

INSERT INTO courses_demo (course_name, teacher, credit) VALUES
    ('高等数学', '张教授', 4),
    ('英语', '李教授', 3),
    ('计算机基础', '王教授', 2),
    ('数据结构', '赵教授', 3),
    ('线性代数', '刘教授', 3);

-- 成绩表
CREATE TABLE scores_demo (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER,
    course_id  INTEGER,
    score      REAL,
    FOREIGN KEY (student_id) REFERENCES students_demo(id),
    FOREIGN KEY (course_id) REFERENCES courses_demo(course_id)
);

INSERT INTO scores_demo (student_id, course_id, score) VALUES
    (1, 1, 85), (1, 2, 78), (1, 3, 90),
    (2, 1, 92), (2, 2, 88), (2, 3, 95),
    (3, 1, 78), (3, 2, 65), (3, 3, 82),
    (4, 1, 95), (4, 2, 90), (4, 3, 88),
    (5, 1, 68), (5, 2, 72), (5, 3, 75);

-- =============================================
-- 第一节：比较运算符
-- =============================================

/*
 * 【比较运算符】
 *
 * 就像数学中的比较：
 * =   等于
 * <>  不等于（也可以用 !=）
 * >   大于
 * <   小于
 * >=  大于等于
 * <=  小于等于
 */

-- 1. 等于 =
SELECT * FROM students_demo WHERE city = '北京';

-- 2. 不等于 <> 或 !=
SELECT * FROM students_demo WHERE city <> '北京';
SELECT * FROM students_demo WHERE city != '北京';

-- 3. 大于 >
SELECT * FROM students_demo WHERE age > 21;

-- 4. 小于 <
SELECT * FROM students_demo WHERE age < 20;

-- 5. 大于等于 >=
SELECT * FROM students_demo WHERE score >= 90;

-- 6. 小于等于 <=
SELECT * FROM students_demo WHERE score <= 70;

-- =============================================
-- 第二节：逻辑运算符
-- =============================================

/*
 * 【逻辑运算符】
 *
 * AND —— 与（同时满足）
 * OR  —— 或（满足其一）
 * NOT —— 非（取反）
 *
 * 优先级：NOT > AND > OR
 * 建议：用括号明确优先级，避免混淆
 */

-- 1. AND（同时满足多个条件）
SELECT * FROM students_demo
WHERE age > 20 AND gender = 'F';
-- 年龄大于20 且 性别为女

-- 2. OR（满足任一条件）
SELECT * FROM students_demo
WHERE city = '北京' OR city = '上海';
-- 来自北京 或 来自上海

-- 3. NOT（取反）
SELECT * FROM students_demo
WHERE NOT city = '北京';
-- 不是来自北京

-- 4. 组合使用（注意优先级）
SELECT * FROM students_demo
WHERE (city = '北京' OR city = '上海') AND age > 20;
-- 来自北京或上海，且年龄大于20
-- 注意：OR 的优先级低于 AND，所以需要括号

-- 5. 复杂条件组合
SELECT * FROM students_demo
WHERE (gender = 'M' AND age > 20)
   OR (gender = 'F' AND score > 90);
-- 男生且年龄大于20，或者女生且分数大于90

-- =============================================
-- 第三节：LIKE 模糊查询
-- =============================================

/*
 * 【LIKE 运算符】
 *
 * 用于模糊匹配字符串
 *
 * 通配符：
 * % —— 匹配任意多个字符（包括0个）
 * _ —— 匹配一个字符
 *
 * 生活类比：
 * % 就像"等等"，_ 就像"某一个"
 */

-- 1. 以某个字符开头
SELECT * FROM students_demo WHERE name LIKE '张%';
-- 姓张的人（张三、张四、张五...）

-- 2. 以某个字符结尾
SELECT * FROM students_demo WHERE name LIKE '%五';
-- 名字以"五"结尾的人

-- 3. 包含某个字符
SELECT * FROM students_demo WHERE email LIKE '%email%';
-- 邮箱包含"email"的人

-- 4. 匹配一个字符
SELECT * FROM students_demo WHERE name LIKE '张_';
-- 姓张，且名字是两个字（张三、张四，但不包括张小三）

-- 5. 匹配两个字符
SELECT * FROM students_demo WHERE name LIKE '___';
-- 名字是三个字的人（三个下划线）

-- 6. 组合使用
SELECT * FROM students_demo WHERE name LIKE '张%' AND name LIKE '%三';
-- 姓张，且名字以"三"结尾

-- 7. 特殊字符的转义
-- 如果要搜索 % 或 _ 本身，需要用转义符
SELECT * FROM students_demo WHERE email LIKE '%@%' ESCAPE '@';
-- ESCAPE 定义转义符，但实际使用中较少见

-- =============================================
-- 第四节：IN 运算符
-- =============================================

/*
 * 【IN 运算符】
 *
 * 用于判断某个值是否在一组值中
 *
 * 语法：列名 IN (值1, 值2, 值3, ...)
 *
 * 等价于：列名 = 值1 OR 列名 = 值2 OR 列名 = 值3
 * 但 IN 更简洁、更易读
 */

-- 1. 基本用法
SELECT * FROM students_demo
WHERE city IN ('北京', '上海', '广州');
-- 来自北京、上海或广州的学生

-- 2. NOT IN（不在列表中）
SELECT * FROM students_demo
WHERE city NOT IN ('北京', '上海');
-- 不是来自北京或上海的学生

-- 3. IN 与子查询结合（预告）
-- SELECT * FROM students_demo
-- WHERE id IN (SELECT student_id FROM scores_demo WHERE score > 90);

-- =============================================
-- 第五节：BETWEEN 运算符
-- =============================================

/*
 * 【BETWEEN 运算符】
 *
 * 用于范围查询（包含边界值）
 *
 * 语法：列名 BETWEEN 值1 AND 值2
 * 等价于：列名 >= 值1 AND 列名 <= 值2
 */

-- 1. 基本用法
SELECT * FROM students_demo
WHERE age BETWEEN 20 AND 22;
-- 年龄在20到22之间（包含20和22）

-- 2. NOT BETWEEN（不在范围内）
SELECT * FROM students_demo
WHERE age NOT BETWEEN 20 AND 22;
-- 年龄不在20到22之间

-- 3. 用于日期范围
SELECT * FROM students_demo
WHERE enroll_date BETWEEN '2022-01-01' AND '2023-01-01';
-- 2022年入学的学生

-- 4. 用于分数范围
SELECT * FROM students_demo
WHERE score BETWEEN 80 AND 90;
-- 分数在80到90之间

-- =============================================
-- 第六节：IS NULL 和 IS NOT NULL
-- =============================================

/*
 * 【NULL 值】
 *
 * NULL 表示"未知"或"不存在"
 * 它不是0，不是空字符串，就是"没有值"
 *
 * 注意：NULL 不能用 = 或 != 比较
 * 必须用 IS NULL 或 IS NOT NULL
 */

-- 1. 查询为空的记录
SELECT * FROM students_demo WHERE email IS NULL;
-- 没有邮箱的学生

-- 2. 查询不为空的记录
SELECT * FROM students_demo WHERE phone IS NOT NULL;
-- 有手机号的学生

-- 3. NULL 的特殊性
-- 错误写法：SELECT * FROM students_demo WHERE email = NULL;
-- 这样写不会报错，但也不会返回任何结果！

-- =============================================
-- 第七节：CASE WHEN 表达式
-- =============================================

/*
 * 【CASE WHEN】
 *
 * 就像编程中的 if-else 语句
 * 可以根据条件返回不同的值
 *
 * 语法：
 * CASE
 *     WHEN 条件1 THEN 结果1
 *     WHEN 条件2 THEN 结果2
 *     ELSE 默认结果
 * END
 */

-- 1. 基本用法
SELECT
    name,
    score,
    CASE
        WHEN score >= 90 THEN '优秀'
        WHEN score >= 80 THEN '良好'
        WHEN score >= 70 THEN '中等'
        WHEN score >= 60 THEN '及格'
        ELSE '不及格'
    END AS 等级
FROM students_demo;

-- 2. 用于统计
SELECT
    CASE
        WHEN age < 20 THEN '20岁以下'
        WHEN age BETWEEN 20 AND 22 THEN '20-22岁'
        ELSE '22岁以上'
    END AS 年龄段,
    COUNT(*) AS 人数
FROM students_demo
GROUP BY 年龄段;

-- =============================================
-- 第八节：EXISTS 运算符
-- =============================================

/*
 * 【EXISTS】
 *
 * 用于判断子查询是否返回了结果
 * 如果子查询有结果，EXISTS 返回 TRUE
 *
 * 比 IN 更高效（特别是在大数据量时）
 */

-- 查询有成绩记录的学生
SELECT * FROM students_demo s
WHERE EXISTS (
    SELECT 1 FROM scores_demo sc
    WHERE sc.student_id = s.id
);

-- 查询没有成绩记录的学生
SELECT * FROM students_demo s
WHERE NOT EXISTS (
    SELECT 1 FROM scores_demo sc
    WHERE sc.student_id = s.id
);

-- =============================================
-- 第九节：条件查询的性能优化技巧
-- =============================================

/*
 * 【性能优化技巧】
 *
 * 1. 避免在 WHERE 中对列使用函数
 *    错误：WHERE YEAR(enroll_date) = 2023
 *    正确：WHERE enroll_date >= '2023-01-01' AND enroll_date < '2024-01-01'
 *
 * 2. 避免使用 OR，尽量用 IN
 *    慢：WHERE city = '北京' OR city = '上海' OR city = '广州'
 *    快：WHERE city IN ('北京', '上海', '广州')
 *
 * 3. 避免使用 <> 或 !=
 *    慢：WHERE status <> 'deleted'
 *    快：WHERE status = 'active'
 *
 * 4. LIKE 'abc%' 可以用索引，'%abc' 不能
 *    可以用索引：WHERE name LIKE '张%'
 *    不能用索引：WHERE name LIKE '%张%'
 *
 * 5. IS NULL 通常不能用索引
 *    如果经常查询 NULL，考虑设置默认值
 */

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：基础条件查询
 * Q: 查询 students_demo 表中：
 *    1. 所有来自北京的男生
 *    2. 年龄在20-22之间且分数大于80的学生
 *    3. 邮箱不为空且来自上海的学生
 */

-- 1. 北京的男生
SELECT * FROM students_demo
WHERE city = '北京' AND gender = 'M';

-- 2. 年龄20-22且分数>80
SELECT * FROM students_demo
WHERE age BETWEEN 20 AND 22 AND score > 80;

-- 3. 邮箱不为空且来自上海
SELECT * FROM students_demo
WHERE email IS NOT NULL AND city = '上海';

/*
 * 练习2：模糊查询
 * Q: 查询 students_demo 表中：
 *    1. 姓"王"的学生
 *    2. 邮箱以"zhang"开头的学生
 *    3. 名字是两个字的学生
 */

-- 1. 姓王
SELECT * FROM students_demo WHERE name LIKE '王%';

-- 2. 邮箱以zhang开头
SELECT * FROM students_demo WHERE email LIKE 'zhang%';

-- 3. 名字两个字
SELECT * FROM students_demo WHERE name LIKE '__';

/*
 * 练习3：综合查询
 * Q: 查询 students_demo 表中：
 *    来自北京或上海，且年龄大于20，且分数在80-95之间的学生
 *    按分数从高到低排序
 */

SELECT * FROM students_demo
WHERE city IN ('北京', '上海')
  AND age > 20
  AND score BETWEEN 80 AND 95
ORDER BY score DESC;

/*
 * 练习4：CASE WHEN 练习
 * Q: 查询所有学生，显示姓名、分数、以及等级（优秀/良好/中等/及格/不及格）
 *    然后统计每个等级的人数
 */

-- 显示等级
SELECT
    name AS 姓名,
    score AS 分数,
    CASE
        WHEN score >= 90 THEN '优秀'
        WHEN score >= 80 THEN '良好'
        WHEN score >= 70 THEN '中等'
        WHEN score >= 60 THEN '及格'
        ELSE '不及格'
    END AS 等级
FROM students_demo;

-- 统计每个等级的人数
SELECT
    CASE
        WHEN score >= 90 THEN '优秀'
        WHEN score >= 80 THEN '良好'
        WHEN score >= 70 THEN '中等'
        WHEN score >= 60 THEN '及格'
        ELSE '不及格'
    END AS 等级,
    COUNT(*) AS 人数
FROM students_demo
GROUP BY 等级
ORDER BY 人数 DESC;

/*
 * 练习5：EXISTS 练习
 * Q: 查询选修了"高等数学"课程的学生姓名
 */

SELECT name FROM students_demo s
WHERE EXISTS (
    SELECT 1 FROM scores_demo sc
    JOIN courses_demo c ON sc.course_id = c.course_id
    WHERE sc.student_id = s.id AND c.course_name = '高等数学'
);

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS scores_demo;
DROP TABLE IF EXISTS courses_demo;
DROP TABLE IF EXISTS students_demo;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 比较运算符 —— =, <>, >, <, >=, <=
 * 2. 逻辑运算符 —— AND(与)、OR(或)、NOT(非)，优先级 NOT > AND > OR
 * 3. LIKE 模糊查询 —— % 匹配任意多个字符，_ 匹配一个字符
 * 4. IN(在列表中)、BETWEEN(范围查询，包含边界)
 * 5. IS NULL / IS NOT NULL —— 判断空值（不能用 = NULL）
 * 6. CASE WHEN —— 条件表达式，类似 if-else
 * 7. EXISTS —— 判断子查询是否有结果，通常比 IN 更高效
 *
 * 【常见陷阱】
 *
 * 1. NULL 不能用 = 比较！必须用 IS NULL，否则永远不返回结果
 * 2. LIKE '%abc' 无法使用索引，数据量大时很慢
 * 3. OR 的优先级低于 AND，复杂条件务必加括号
 * 4. BETWEEN 包含两端边界值（>= 且 <=）
 * 5. 字符串比较区分大小写（取决于数据库配置）
 *
 * 【下节课预告】
 *
 * 第04课将学习排序与分页：ORDER BY（升序/降序）、LIMIT（限制行数）、
 * OFFSET（分页跳过）、DISTINCT（去重）。这是前端展示数据的必备技能！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第03课：条件查询！
-- 下节课我们将学习排序与分页。
