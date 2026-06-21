-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第12课：数据库设计（超级详细版）
-- =============================================
-- 第12课：数据库设计
-- ER图、范式(1NF/2NF/3NF)、反范式设计、设计原则

-- =============================================
-- 第一节：什么是数据库设计？
-- =============================================

/*
 * 【什么是数据库设计？】
 *
 * 数据库设计就是规划数据库的结构
 * 包括：有哪些表、每个表有哪些列、表之间的关系等
 *
 * 生活类比：
 *   数据库设计就像建筑设计
 *   建房子之前，需要先画图纸
 *   - 有几层楼？（几个表）
 *   - 每层有几个房间？（每个表有几个列）
 *   - 房间之间怎么连接？（表之间的关系）
 *
 * 为什么需要数据库设计？
 * 1. 保证数据的一致性
 * 2. 减少数据冗余
 * 3. 提高查询效率
 * 4. 便于维护和扩展
 */

-- =============================================
-- 第二节：ER 图（实体关系图）
-- =============================================

/*
 * 【ER 图】
 *
 * ER 图是数据库设计的工具
 * 用于描述实体（表）和它们之间的关系
 *
 * ER 图的组成：
 * 1. 实体（Entity）—— 矩形
 *    例如：学生、课程、订单
 *
 * 2. 属性（Attribute）—— 椭圆
 *    例如：学号、姓名、课程名
 *
 * 3. 关系（Relationship）—— 菱形
 *    例如：选课、下单
 *
 * 【实体之间的关系类型】
 *
 * 1. 一对一（1:1）
 *    例如：一个人只有一个身份证
 *
 * 2. 一对多（1:N）
 *    例如：一个班级有多个学生
 *
 * 3. 多对多（M:N）
 *    例如：一个学生可以选多门课，一门课可以有多个学生
 *
 * 【ER 图示例】
 *
 * 学生管理系统：
 *
 * [学生] ---(选课)--- [课程]
 *   |                    |
 *  学号                 课程号
 *  姓名                 课程名
 *  年龄                 学分
 *  班级                 教师
 */

-- =============================================
-- 第三节：数据库范式
-- =============================================

/*
 * 【什么是范式？】
 *
 * 范式是数据库设计的规则
 * 用于减少数据冗余，提高数据一致性
 *
 * 常见的范式：
 * 1NF（第一范式）
 * 2NF（第二范式）
 * 3NF（第三范式）
 * BCNF（巴斯-科德范式）
 *
 * 范式越高，数据冗余越少
 * 但查询可能越复杂（需要多表连接）
 *
 * 【第一范式（1NF）】
 *
 * 规则：每个列都是原子的，不可再分
 *
 * 反例：
 * | 学号 | 姓名 | 课程               |
 * |------|------|-------------------|
 * | 1    | 张三 | 数学,英语,物理      |
 *
 * 问题："课程"列包含了多个值，不是原子的
 *
 * 正确设计：
 * | 学号 | 姓名 | 课程  |
 * |------|------|------|
 * | 1    | 张三 | 数学  |
 * | 1    | 张三 | 英语  |
 * | 1    | 张三 | 物理  |
 */

-- 违反1NF的表（不好的设计）
CREATE TABLE IF NOT EXISTS bad_design_1nf (
    student_id INTEGER PRIMARY KEY,
    name       VARCHAR(50),
    courses    VARCHAR(200)  -- "数学,英语,物理" —— 违反1NF！
);

-- 符合1NF的表
CREATE TABLE IF NOT EXISTS good_design_1nf (
    student_id INTEGER,
    name       VARCHAR(50),
    course     VARCHAR(50),
    PRIMARY KEY (student_id, course)
);

/*
 * 【第二范式（2NF）】
 *
 * 规则：
 * 1. 满足1NF
 * 2. 非主键列必须完全依赖于主键
 *
 * 反例（学生选课表）：
 * | 学号 | 课程 | 姓名 | 学分 |
 * |------|------|------|------|
 * | 1    | 数学 | 张三 | 4    |
 *
 * 问题：
 * - "姓名"只依赖于"学号"，不依赖于"课程"
 * - "学分"只依赖于"课程"，不依赖于"学号"
 * - 这就是"部分依赖"
 *
 * 正确设计（拆分成多个表）：
 *
 * 学生表：
 * | 学号 | 姓名 |
 *
 * 课程表：
 * | 课程 | 学分 |
 *
 * 选课表：
 * | 学号 | 课程 | 成绩 |
 */

-- 违反2NF的表
CREATE TABLE IF NOT EXISTS bad_design_2nf (
    student_id   INTEGER,
    course       VARCHAR(50),
    student_name VARCHAR(50),  -- 只依赖于 student_id
    credit       INTEGER,      -- 只依赖于 course
    score        REAL,
    PRIMARY KEY (student_id, course)
);

-- 符合2NF的表
CREATE TABLE IF NOT EXISTS students_2nf (
    student_id   INTEGER PRIMARY KEY,
    student_name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS courses_2nf (
    course_name VARCHAR(50) PRIMARY KEY,
    credit      INTEGER
);

CREATE TABLE IF NOT EXISTS scores_2nf (
    student_id INTEGER,
    course     VARCHAR(50),
    score      REAL,
    PRIMARY KEY (student_id, course)
);

/*
 * 【第三范式（3NF）】
 *
 * 规则：
 * 1. 满足2NF
 * 2. 非主键列不能依赖于其他非主键列（消除传递依赖）
 *
 * 反例（学生表）：
 * | 学号 | 姓名 | 班级 | 班主任 |
 * |------|------|------|--------|
 * | 1    | 张三 | 一班 | 李老师 |
 *
 * 问题：
 * - "班主任"依赖于"班级"
 * - "班级"依赖于"学号"
 * - 所以"班主任"间接依赖于"学号"（传递依赖）
 *
 * 正确设计：
 *
 * 学生表：
 * | 学号 | 姓名 | 班级 |
 *
 * 班级表：
 * | 班级 | 班主任 |
 */

-- 违反3NF的表
CREATE TABLE IF NOT EXISTS bad_design_3nf (
    student_id   INTEGER PRIMARY KEY,
    student_name VARCHAR(50),
    class        VARCHAR(20),
    teacher      VARCHAR(50)  -- 依赖于 class，不直接依赖于 student_id
);

-- 符合3NF的表
CREATE TABLE IF NOT EXISTS classes_3nf (
    class   VARCHAR(20) PRIMARY KEY,
    teacher VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS students_3nf (
    student_id   INTEGER PRIMARY KEY,
    student_name VARCHAR(50),
    class        VARCHAR(20)
);

-- =============================================
-- 第四节：反范式设计
-- =============================================

/*
 * 【反范式设计】
 *
 * 有时候为了提高查询效率，会故意违反范式
 * 适当的数据冗余可以减少表连接，提高查询速度
 *
 * 生活类比：
 *   范式设计就像"精益生产"，减少浪费
 *   反范式设计就像"提前备货"，用空间换时间
 *
 * 【反范式的使用场景】
 *
 * 1. 经常需要多表连接的查询
 * 2. 读多写少的场景
 * 3. 对查询性能要求很高
 * 4. 数据量很大
 *
 * 【反范式的代价】
 *
 * 1. 数据冗余，占用更多存储空间
 * 2. 更新数据时需要更新多处，容易不一致
 * 3. 插入和删除可能异常
 */

-- 反范式示例：订单表中冗余商品名称
CREATE TABLE IF NOT EXISTS orders_denormalized (
    order_id     INTEGER PRIMARY KEY,
    product_id   INTEGER,
    product_name VARCHAR(100),  -- 冗余字段，避免连接查询
    price        DECIMAL(10,2), -- 冗余字段
    quantity     INTEGER,
    total_amount DECIMAL(10,2)
);

-- 正常化设计（需要连接查询）
CREATE TABLE IF NOT EXISTS orders_normalized (
    order_id     INTEGER PRIMARY KEY,
    product_id   INTEGER,
    quantity     INTEGER
);

CREATE TABLE IF NOT EXISTS products_normalized (
    product_id   INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    price        DECIMAL(10,2)
);

-- =============================================
-- 第五节：数据库设计原则
-- =============================================

/*
 * 【数据库设计原则】
 *
 * 1. 命名规范
 *    - 表名使用复数形式（students, orders）
 *    - 列名使用小写字母和下划线（student_name）
 *    - 主键使用 id 或 表名_id
 *    - 外键使用 关联表名_id
 *
 * 2. 主键设计
 *    - 每个表都应该有主键
 *    - 推荐使用自增整数作为主键
 *    - 避免使用业务字段作为主键
 *
 * 3. 外键设计
 *    - 建立表与表之间的关系
 *    - 使用外键约束保证数据完整性
 *    - 考虑级联更新和删除
 *
 * 4. 数据类型选择
 *    - 选择合适的数据类型，不要过大
 *    - 字符串长度要合理
 *    - 金额使用 DECIMAL，不要用 FLOAT
 *
 * 5. 索引设计
 *    - 在经常查询的列上创建索引
 *    - 在连接条件的列上创建索引
 *    - 不要创建过多索引
 *
 * 6. 约束设计
 *    - 使用 NOT NULL 保证必填字段
 *    - 使用 UNIQUE 保证唯一性
 *    - 使用 CHECK 保证数据范围
 *    - 使用 DEFAULT 设置默认值
 */

-- =============================================
-- 第六节：设计实战 —— 学生选课系统
-- =============================================

/*
 * 【需求分析】
 *
 * 设计一个学生选课系统，需要管理：
 * 1. 学生信息
 * 2. 课程信息
 * 3. 教师信息
 * 4. 选课记录
 * 5. 成绩记录
 *
 * 【ER 图】
 *
 * [教师] ---< [课程] >---< [选课] >--- [学生]
 *                                        |
 *                                       [成绩]
 *
 * 【关系分析】
 *
 * - 一个教师可以教多门课程（1:N）
 * - 一个学生可以选多门课程（M:N）
 * - 一门课程可以有多个学生选（M:N）
 * - 选课记录包含成绩
 */

-- 创建数据库表

-- 教师表
CREATE TABLE IF NOT EXISTS teachers (
    teacher_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    teacher_name VARCHAR(50) NOT NULL,
    department   VARCHAR(50),
    email        VARCHAR(100) UNIQUE
);

-- 课程表
CREATE TABLE IF NOT EXISTS courses_design (
    course_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    course_name VARCHAR(100) NOT NULL,
    teacher_id  INTEGER,
    credit      INTEGER CHECK (credit > 0),
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

-- 学生表
CREATE TABLE IF NOT EXISTS students_design (
    student_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    student_name VARCHAR(50) NOT NULL,
    gender       CHAR(1) CHECK (gender IN ('M', 'F')),
    birth_date   DATE,
    class        VARCHAR(20)
);

-- 选课表（学生和课程的多对多关系）
CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id    INTEGER,
    course_id     INTEGER,
    enroll_date   DATE DEFAULT CURRENT_DATE,
    score         REAL CHECK (score >= 0 AND score <= 100),
    FOREIGN KEY (student_id) REFERENCES students_design(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_design(course_id),
    UNIQUE (student_id, course_id)  -- 一个学生同一门课只能选一次
);

-- 插入测试数据
INSERT INTO teachers (teacher_name, department, email) VALUES
    ('张教授', '数学系', 'zhang@school.com'),
    ('李教授', '英语系', 'li@school.com'),
    ('王教授', '计算机系', 'wang@school.com');

INSERT INTO courses_design (course_name, teacher_id, credit) VALUES
    ('高等数学', 1, 4),
    ('英语', 2, 3),
    ('数据结构', 3, 3);

INSERT INTO students_design (student_name, gender, birth_date, class) VALUES
    ('张三', 'M', '2000-01-15', '一班'),
    ('李四', 'F', '2001-05-20', '一班'),
    ('王五', 'M', '2000-11-08', '二班');

INSERT INTO enrollments (student_id, course_id, score) VALUES
    (1, 1, 85), (1, 2, 78), (1, 3, 90),
    (2, 1, 92), (2, 2, 88),
    (3, 1, 78), (3, 3, 82);

-- 验证设计
SELECT
    s.student_name,
    c.course_name,
    t.teacher_name,
    e.score
FROM enrollments e
INNER JOIN students_design s ON e.student_id = s.student_id
INNER JOIN courses_design c ON e.course_id = c.course_id
INNER JOIN teachers t ON c.teacher_id = t.teacher_id;

-- =============================================
-- 第七节：数据库设计的常见错误
-- =============================================

/*
 * 【常见错误】
 *
 * 1. 没有主键
 *    每个表都应该有主键，即使没有业务主键，也要用自增ID
 *
 * 2. 数据冗余
 *    同样的数据存储在多个地方，更新时容易不一致
 *
 * 3. 没有外键约束
 *    不使用外键约束，容易产生"孤儿数据"
 *
 * 4. 数据类型选择不当
 *    - 金额用 FLOAT（不精确）
 *    - 手机号用 INTEGER（丢失前导0）
 *    - 地址用 TEXT（应该用 VARCHAR）
 *
 * 5. 没有索引
 *    在经常查询的列上没有创建索引
 *
 * 6. 过度设计
 *    设计过于复杂，增加不必要的表和关系
 *
 * 7. 命名不规范
 *    表名和列名没有统一的命名规则
 */

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：识别范式
 * Q: 以下表属于第几范式？有什么问题？
 *
 * 订单表：
 * | 订单ID | 商品名 | 商品价格 | 客户名 | 客户电话 |
 * |--------|--------|----------|--------|----------|
 * | 1      | iPhone | 7999     | 张三   | 138xxxx  |
 *
 * A: 这个表存在以下问题：
 *    1. 满足1NF（所有列都是原子的）
 *    2. 不满足2NF（如果主键是订单ID，所有列都依赖于主键，所以满足2NF）
 *    3. 不满足3NF：
 *       - "商品价格"依赖于"商品名"，不直接依赖于"订单ID"
 *       - "客户电话"依赖于"客户名"，不直接依赖于"订单ID"
 *       - 存在传递依赖
 *
 * 正确设计：
 * - 商品表：商品ID、商品名、价格
 * - 客户表：客户ID、客户名、电话
 * - 订单表：订单ID、商品ID、客户ID、数量
 */

/*
 * 练习2：设计数据库
 * Q: 设计一个"图书馆管理系统"的数据库，需要管理：
 *    1. 图书信息
 *    2. 读者信息
 *    3. 借阅记录
 *    写出建表语句
 */

-- 图书表
CREATE TABLE IF NOT EXISTS library_books (
    book_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    title       VARCHAR(200) NOT NULL,
    author      VARCHAR(100),
    isbn        VARCHAR(20) UNIQUE,
    publisher   VARCHAR(100),
    pub_year    INTEGER,
    category    VARCHAR(50),
    total_copies INTEGER DEFAULT 1,
    available   INTEGER DEFAULT 1
);

-- 读者表
CREATE TABLE IF NOT EXISTS library_readers (
    reader_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    reader_name VARCHAR(50) NOT NULL,
    phone       VARCHAR(20),
    email       VARCHAR(100),
    register_date DATE DEFAULT CURRENT_DATE
);

-- 借阅记录表
CREATE TABLE IF NOT EXISTS library_borrowings (
    borrowing_id INTEGER PRIMARY KEY AUTOINCREMENT,
    reader_id    INTEGER,
    book_id      INTEGER,
    borrow_date  DATE DEFAULT CURRENT_DATE,
    return_date  DATE,
    due_date     DATE,
    FOREIGN KEY (reader_id) REFERENCES library_readers(reader_id),
    FOREIGN KEY (book_id) REFERENCES library_books(book_id)
);

/*
 * 练习3：反范式设计
 * Q: 什么情况下应该使用反范式设计？举例说明
 *
 * A: 以下情况可以考虑反范式设计：
 *    1. 查询性能要求很高，读多写少
 *    2. 经常需要多表连接的查询
 *    3. 数据量很大，连接查询很慢
 *
 *    例如：电商商品详情页
 *    - 正常化设计：商品表、品牌表、分类表
 *    - 反范式设计：在商品表中冗余品牌名和分类名
 *    - 原因：商品详情页访问频率极高，减少连接查询
 */

/*
 * 练习4：外键约束
 * Q: 设计一个外键约束，实现以下规则：
 *    当删除课程时，自动删除相关的选课记录
 */

-- 使用级联删除
CREATE TABLE IF NOT EXISTS enrollments_cascade (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id    INTEGER,
    course_id     INTEGER,
    score         REAL,
    FOREIGN KEY (student_id) REFERENCES students_design(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_design(course_id)
        ON DELETE CASCADE  -- 级联删除
        ON UPDATE CASCADE  -- 级联更新
);

/*
 * 练习5：设计评审
 * Q: 评审以下设计，找出问题并改进
 *
 * 用户表：
 * CREATE TABLE users (
 *     id INT,
 *     name VARCHAR(50),
 *     email VARCHAR(100),
 *     address TEXT,
 *     city VARCHAR(50),
 *     province VARCHAR(50),
 *     country VARCHAR(50)
 * );
 *
 * A: 存在以下问题：
 *    1. 没有主键约束（应该加上 PRIMARY KEY）
 *    2. name 没有 NOT NULL 约束
 *    3. email 没有 UNIQUE 约束
 *    4. 地址信息应该拆分（可以考虑单独的地址表）
 *    5. 没有创建时间、更新时间字段
 *    6. 没有索引
 */

-- 改进后的设计
CREATE TABLE IF NOT EXISTS users_improved (
    user_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    username     VARCHAR(50) NOT NULL UNIQUE,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone        VARCHAR(20),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses_design;
DROP TABLE IF EXISTS students_design;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS bad_design_1nf;
DROP TABLE IF EXISTS good_design_1nf;
DROP TABLE IF EXISTS bad_design_2nf;
DROP TABLE IF EXISTS students_2nf;
DROP TABLE IF EXISTS courses_2nf;
DROP TABLE IF EXISTS scores_2nf;
DROP TABLE IF EXISTS bad_design_3nf;
DROP TABLE IF EXISTS classes_3nf;
DROP TABLE IF EXISTS students_3nf;
DROP TABLE IF EXISTS orders_denormalized;
DROP TABLE IF EXISTS orders_normalized;
DROP TABLE IF EXISTS products_normalized;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS library_readers;
DROP TABLE IF EXISTS library_borrowings;
DROP TABLE IF EXISTS enrollments_cascade;
DROP TABLE IF EXISTS users_improved;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. ER 图 —— 实体(矩形)、属性(椭圆)、关系(菱形)，1:1/1:N/M:N
 * 2. 1NF —— 每列原子不可再分（不能存"数学,英语"在一个字段）
 * 3. 2NF —— 非主键列完全依赖主键（消除部分依赖）
 * 4. 3NF —— 非主键列不依赖其他非主键列（消除传递依赖）
 * 5. 反范式 —— 适当冗余提高查询性能（读多写少场景）
 * 6. 设计原则 —— 每表有主键、外键约束、合理数据类型、适当索引
 *
 * 【常见陷阱】
 *
 * 1. 没有主键的表无法唯一标识行，后续维护困难
 * 2. 金额用 DECIMAL 不用 FLOAT（精度丢失）
 * 3. 过度范式化导致大量 JOIN，查询性能差
 * 4. 反范式冗余字段需要在代码中同步更新，否则数据不一致
 * 5. 外键约束会影响写入性能，高并发场景可考虑应用层保证
 *
 * 【下节课预告】
 *
 * 第13课将学习安全与注入：SQL注入原理、常见攻击手法、
 * 参数化查询防御、输入验证。这是每个开发者必须知道的安全知识！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第12课：数据库设计！
-- 下节课我们将学习安全与注入。
