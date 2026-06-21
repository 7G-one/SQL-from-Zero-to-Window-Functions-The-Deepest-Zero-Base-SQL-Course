-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第01课：数据库基础（超级详细版）
-- =============================================
-- 第01课：数据库基础
-- 数据类型、主键约束、外键关联、修改表结构

-- =============================================
-- 第一节：创建数据库
-- =============================================

/*
 * 【创建数据库】
 *
 * 就像建一座图书馆，首先要有一个建筑
 * 创建数据库就是在硬盘上开辟一块空间来存放数据
 *
 * 语法：CREATE DATABASE 数据库名;
 */

-- 创建一个数据库（MySQL）
-- CREATE DATABASE IF NOT EXISTS school;
-- IF NOT EXISTS 表示：如果这个数据库已经存在，就不要报错

-- 选择使用某个数据库（MySQL）
-- USE school;

/*
 * SQLite 的区别：
 * SQLite 不需要 CREATE DATABASE
 * 你只需要打开一个 .db 文件，它会自动创建
 * 例如：sqlite3 school.db
 *
 * 这就像 MySQL 是一个大图书馆，你需要先建好建筑
 * 而 SQLite 是一个便携笔记本，打开就能用
 */

-- =============================================
-- 第二节：数据类型详解
-- =============================================

/*
 * 【为什么要了解数据类型？】
 *
 * 就像你去超市买东西：
 * - 苹果按"个"卖（整数）
 * - 牛奶按"升"卖（小数）
 * - 薯片按"袋"卖（字符串）
 *
 * 不同类型的数据，存储方式和计算方式都不同
 *
 * 【常见的数据类型】
 *
 * 1. 整数类型：
 *    TINYINT    —— 很小的整数（-128 到 127）
 *    SMALLINT   —— 小整数（-32768 到 32767）
 *    INTEGER/INT —— 普通整数（最常用）
 *    BIGINT     —— 大整数（存身份证号、手机号）
 *
 * 2. 小数类型：
 *    FLOAT      —— 单精度浮点数（不太精确）
 *    DOUBLE     —— 双精度浮点数（更精确）
 *    DECIMAL(M,D) —— 精确小数（存钱必用！）
 *       M = 总位数，D = 小数位数
 *       例如 DECIMAL(10,2) 表示最多10位数，其中2位小数
 *
 * 3. 文本类型：
 *    CHAR(N)    —— 固定长度字符串（存手机号、身份证号）
 *       例如 CHAR(11) 存手机号，总是占11个字符
 *    VARCHAR(N) —— 可变长度字符串（存姓名、地址）
 *       例如 VARCHAR(50) 最多50个字符，实际不够就只占实际长度
 *    TEXT       —— 长文本（存文章内容、评论）
 *
 * 4. 日期时间类型：
 *    DATE       —— 日期（2024-01-15）
 *    TIME       —— 时间（14:30:00）
 *    DATETIME   —— 日期时间（2024-01-15 14:30:00）
 *    TIMESTAMP  —— 时间戳（自动记录修改时间）
 *
 * 5. 布尔类型：
 *    BOOLEAN    —— 真/假（TRUE/FALSE，或 1/0）
 */

-- =============================================
-- 第三节：创建表的完整语法
-- =============================================

/*
 * 【创建表的完整语法】
 *
 * CREATE TABLE 表名 (
 *     列名1 数据类型 约束,
 *     列名2 数据类型 约束,
 *     ...
 *     表级约束
 * );
 *
 * 就像设计一张表格：
 * - 先想好有哪些列（字段）
 * - 每列放什么类型的数据
 * - 每列有什么规则（约束）
 */

-- 创建一个完整的学生表
CREATE TABLE IF NOT EXISTS student_info (
    -- 学号：整数，主键，自动增长
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    -- 姓名：可变长度字符串，最多20个字符，不能为空
    name        VARCHAR(20) NOT NULL,
    -- 性别：固定长度字符串，1个字符（'M'或'F'）
    gender      CHAR(1) DEFAULT 'M',
    -- 年龄：整数，必须在1-150之间
    age         INTEGER CHECK (age > 0 AND age <= 150),
    -- 邮箱：可变长度字符串，必须唯一
    email       VARCHAR(100) UNIQUE,
    -- 手机号：固定长度11位
    phone       CHAR(11),
    -- 入学日期：日期类型
    enroll_date DATE DEFAULT CURRENT_DATE,
    -- 备注：长文本
    remark      TEXT
);

/*
 * 逐行解释：
 *
 * id INTEGER PRIMARY KEY AUTOINCREMENT
 *   - INTEGER：整数类型
 *   - PRIMARY KEY：主键（唯一标识每一行）
 *   - AUTOINCREMENT：自动增长（每次插入新数据，id自动+1）
 *
 * name VARCHAR(20) NOT NULL
 *   - VARCHAR(20)：最多20个字符的字符串
 *   - NOT NULL：不能为空（必须填）
 *
 * gender CHAR(1) DEFAULT 'M'
 *   - CHAR(1)：固定1个字符
 *   - DEFAULT 'M'：默认值是'M'（不填就默认男生）
 *
 * age INTEGER CHECK (age > 0 AND age <= 150)
 *   - CHECK：检查约束，age 必须在 1-150 之间
 *
 * email VARCHAR(100) UNIQUE
 *   - UNIQUE：唯一约束，不能有两个相同的邮箱
 *
 * enroll_date DATE DEFAULT CURRENT_DATE
 *   - DEFAULT CURRENT_DATE：默认值是当前日期
 */

-- =============================================
-- 第四节：主键（Primary Key）
-- =============================================

/*
 * 【什么是主键？】
 *
 * 主键就是表中"唯一标识"每一行数据的列
 *
 * 生活类比：
 *   你的身份证号就是你的"主键"
 *   - 全中国每个人都有唯一的身份证号
 *   - 通过身份证号可以找到唯一一个人
 *
 * 主键的特点：
 *   1. 唯一性：不能有重复值
 *   2. 非空性：不能为 NULL
 *   3. 一个表只能有一个主键
 *
 * 主键的选择：
 *   1. 自增整数 ID（最常用）
 *   2. 业务唯一编号（如学号、工号）
 *   3. UUID（分布式系统常用）
 */

-- 单列主键
CREATE TABLE IF NOT EXISTS example_pk1 (
    id   INTEGER PRIMARY KEY,  -- id 就是主键
    name TEXT
);

-- 复合主键（两个列共同组成主键）
CREATE TABLE IF NOT EXISTS example_pk2 (
    student_id  INTEGER,
    course_id   INTEGER,
    score       REAL,
    PRIMARY KEY (student_id, course_id)  -- 两个列共同作为主键
);

/*
 * 复合主键的含义：
 * 同一个学生可以选多门课，同一门课可以有多个学生选
 * 但同一个学生同一门课只能有一条成绩记录
 */

-- =============================================
-- 第五节：约束（Constraints）详解
-- =============================================

/*
 * 【约束是什么？】
 *
 * 约束就是对数据的"规则"
 * 就像学校的规定：不能迟到、不能旷课...
 *
 * 常见的约束：
 *   1. NOT NULL    —— 不能为空
 *   2. UNIQUE      —— 不能重复
 *   3. PRIMARY KEY —— 主键（NOT NULL + UNIQUE）
 *   4. FOREIGN KEY —— 外键（关联其他表）
 *   5. CHECK       —— 检查条件
 *   6. DEFAULT     —— 默认值
 */

-- NOT NULL 约束示例
CREATE TABLE IF NOT EXISTS demo_not_null (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL,    -- 姓名不能为空
    age  INTEGER           -- 年龄可以为空（NULL）
);

-- 插入测试
INSERT INTO demo_not_null (id, name) VALUES (1, '张三');  -- 正常
INSERT INTO demo_not_null (id, age) VALUES (2, 18);       -- 错误！name 不能为空
-- 上面这行会报错：NOT NULL constraint failed

-- UNIQUE 约束示例
CREATE TABLE IF NOT EXISTS demo_unique (
    id    INTEGER PRIMARY KEY,
    email TEXT UNIQUE,     -- 邮箱不能重复
    name  TEXT
);

-- 插入测试
INSERT INTO demo_unique VALUES (1, 'test@qq.com', '张三');  -- 正常
INSERT INTO demo_unique VALUES (2, 'test@qq.com', '李四');  -- 错误！邮箱重复
-- 上面这行会报错：UNIQUE constraint failed

-- CHECK 约束示例
CREATE TABLE IF NOT EXISTS demo_check (
    id    INTEGER PRIMARY KEY,
    age   INTEGER CHECK (age >= 0 AND age <= 150),  -- 年龄范围
    score REAL CHECK (score >= 0 AND score <= 100)   -- 分数范围
);

-- 插入测试
INSERT INTO demo_check VALUES (1, 20, 85.5);   -- 正常
INSERT INTO demo_check VALUES (2, -1, 85.5);   -- 错误！年龄不能为负
INSERT INTO demo_check VALUES (3, 20, 150);    -- 错误！分数不能超过100

-- DEFAULT 约束示例
CREATE TABLE IF NOT EXISTS demo_default (
    id         INTEGER PRIMARY KEY,
    name       TEXT,
    status     TEXT DEFAULT 'active',           -- 默认状态为 active
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP -- 默认为当前时间
);

-- 插入测试（不指定 status 和 created_at，会用默认值）
INSERT INTO demo_default (id, name) VALUES (1, '张三');
SELECT * FROM demo_default;
-- 结果：status 会是 'active'，created_at 会是当前时间

-- =============================================
-- 第六节：外键（Foreign Key）
-- =============================================

/*
 * 【什么是外键？】
 *
 * 外键是表与表之间的"桥梁"
 * 它让一个表中的某列引用另一个表的主键
 *
 * 生活类比：
 *   "借阅记录"表中的"读者ID"就是一个外键
 *   它引用了"读者"表中的"读者ID"
 *   这样就能知道这条借阅记录是哪个读者的
 *
 * 外键的作用：
 *   1. 保证数据的一致性（不能引用不存在的数据）
 *   2. 建立表与表之间的关系
 */

-- 创建一个班级表
CREATE TABLE IF NOT EXISTS classes (
    class_id   INTEGER PRIMARY KEY,
    class_name TEXT NOT NULL
);

-- 创建一个带外键的学生表
CREATE TABLE IF NOT EXISTS students_with_fk (
    student_id INTEGER PRIMARY KEY,
    name       TEXT NOT NULL,
    class_id   INTEGER,
    -- 外键：class_id 引用 classes 表的 class_id
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

-- 插入数据
INSERT INTO classes VALUES (1, '一班');
INSERT INTO classes VALUES (2, '二班');

INSERT INTO students_with_fk VALUES (1, '张三', 1);  -- 正常，班级1存在
INSERT INTO students_with_fk VALUES (2, '李四', 2);  -- 正常，班级2存在
INSERT INTO students_with_fk VALUES (3, '王五', 99); -- 错误！班级99不存在
-- 上面这行会报错：FOREIGN KEY constraint failed

-- =============================================
-- 第七节：修改表结构（ALTER TABLE）
-- =============================================

/*
 * 【ALTER TABLE 命令】
 *
 * 就像图书馆建好后，你可能需要：
 * - 加一个新的书架（添加列）
 * - 把某个书架改大一点（修改列）
 * - 拆掉一个书架（删除列）
 */

-- 创建一个演示表
CREATE TABLE IF NOT EXISTS demo_alter (
    id   INTEGER PRIMARY KEY,
    name TEXT
);

-- 1. 添加新列
ALTER TABLE demo_alter ADD COLUMN age INTEGER;
-- 现在表多了一列 age

-- 2. 添加带默认值的列
ALTER TABLE demo_alter ADD COLUMN status TEXT DEFAULT 'active';

/*
 * 注意：
 * - MySQL 使用 ALTER TABLE ... MODIFY COLUMN 来修改列类型
 * - SQLite 不支持直接修改列类型，需要重建表
 *
 * MySQL 示例：
 * ALTER TABLE demo_alter MODIFY COLUMN name VARCHAR(100);
 *
 * SQLite 的做法：
 * 1. 创建新表
 * 2. 复制数据
 * 3. 删除旧表
 * 4. 重命名新表
 */

-- =============================================
-- 第八节：删除表和数据库
-- =============================================

/*
 * 【删除操作 —— 慎用！】
 *
 * 删除操作是不可逆的！就像把书扔进碎纸机，再也找不回来了
 *
 * DROP TABLE 表名;     —— 删除整个表（结构和数据都没了）
 * DROP DATABASE 数据库名; —— 删除整个数据库
 *
 * 建议：总是加上 IF EXISTS，避免表不存在时报错
 */

-- 删除表示例（已注释，防止误删）
-- DROP TABLE IF EXISTS demo_alter;
-- DROP TABLE IF EXISTS demo_not_null;
-- DROP TABLE IF EXISTS demo_unique;
-- DROP TABLE IF EXISTS demo_check;
-- DROP TABLE IF EXISTS demo_default;

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：数据类型选择
 * Q: 以下数据应该用什么类型？
 *    1. 手机号：CHAR(11) —— 固定11位
 *    2. 用户名：VARCHAR(50) —— 长度不固定
 *    3. 商品价格：DECIMAL(10,2) —— 需要精确到分
 *    4. 是否删除：BOOLEAN —— 只有是/否
 *    5. 文章内容：TEXT —— 长文本
 *
 * 练习2：创建表
 * Q: 创建一个"商品"表，包含：
 *    - 商品ID（主键，自动增长）
 *    - 商品名（不能为空，最多100字符）
 *    - 价格（精确到分）
 *    - 库存数量（不能为负）
 *    - 创建时间（默认当前时间）
 */

CREATE TABLE IF NOT EXISTS products (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) CHECK (price >= 0),
    stock        INTEGER CHECK (stock >= 0),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 插入测试数据
INSERT INTO products (product_name, price, stock) VALUES ('iPhone 15', 7999.00, 100);
INSERT INTO products (product_name, price, stock) VALUES ('MacBook Pro', 14999.00, 50);
INSERT INTO products (product_name, price, stock) VALUES ('AirPods', 1299.00, 200);

SELECT * FROM products;

/*
 * 练习3：外键练习
 * Q: 创建一个"订单"表，包含：
 *    - 订单ID（主键）
 *    - 商品ID（外键，引用 products 表）
 *    - 购买数量
 *    - 下单时间
 */

CREATE TABLE IF NOT EXISTS orders (
    order_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER,
    quantity   INTEGER CHECK (quantity > 0),
    order_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 插入测试数据
INSERT INTO orders (product_id, quantity) VALUES (1, 2);  -- 买2个 iPhone
INSERT INTO orders (product_id, quantity) VALUES (2, 1);  -- 买1个 MacBook

-- 查询订单（关联查询预告）
SELECT * FROM orders;

/*
 * 练习4：约束综合练习
 * Q: 设计一个"员工"表，要求：
 *    - 工号（主键，6位数字）
 *    - 姓名（不能为空）
 *    - 邮箱（唯一）
 *    - 年龄（18-65）
 *    - 部门（默认'未分配'）
 *    - 入职日期
 */

CREATE TABLE IF NOT EXISTS employees (
    emp_id      CHAR(6) PRIMARY KEY,            -- 6位工号
    emp_name    VARCHAR(50) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    age         INTEGER CHECK (age >= 18 AND age <= 65),
    department  VARCHAR(50) DEFAULT '未分配',
    hire_date   DATE
);

-- 插入测试数据
INSERT INTO employees VALUES ('EMP001', '张三', 'zhangsan@company.com', 28, '技术部', '2023-01-15');
INSERT INTO employees VALUES ('EMP002', '李四', 'lisi@company.com', 35, '市场部', '2022-06-01');
INSERT INTO employees (emp_id, emp_name, age) VALUES ('EMP003', '王五', 25);

SELECT * FROM employees;

-- =============================================
-- 清理演示表
-- =============================================
DROP TABLE IF EXISTS demo_pk1;
DROP TABLE IF EXISTS demo_pk2;
DROP TABLE IF EXISTS demo_not_null;
DROP TABLE IF EXISTS demo_unique;
DROP TABLE IF EXISTS demo_check;
DROP TABLE IF EXISTS demo_default;
DROP TABLE IF EXISTS example_pk1;
DROP TABLE IF EXISTS example_pk2;
-- 保留 student_info, classes, students_with_fk, products, orders, employees 供后续课程使用

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 数据类型 —— 整数(INT)、小数(DECIMAL)、文本(VARCHAR/TEXT)、日期(DATE)
 * 2. 主键(PRIMARY KEY) —— 唯一标识每一行，通常用自增整数
 * 3. 约束 —— NOT NULL(非空)、UNIQUE(唯一)、CHECK(检查)、DEFAULT(默认值)
 * 4. 外键(FOREIGN KEY) —— 建立表与表之间的关联关系
 * 5. ALTER TABLE —— 添加/修改/删除列
 * 6. DROP TABLE —— 删除整个表（不可逆！）
 *
 * 【常见陷阱】
 *
 * 1. DECIMAL(10,2) 存金额，不要用 FLOAT（精度丢失）
 * 2. 手机号用 CHAR(11)，不要用 INTEGER（会丢失前导0）
 * 3. 外键引用的值必须在父表中存在，否则插入失败
 * 4. DROP TABLE 没有确认提示，执行即删除，务必小心
 * 5. SQLite 不支持 ALTER TABLE MODIFY，需要重建表
 *
 * 【下节课预告】
 *
 * 第02课将学习数据操作 CRUD：INSERT(插入)、SELECT(查询)、
 * UPDATE(更新)、DELETE(删除)——这是数据库操作的灵魂！
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第01课：数据库基础！
-- 下节课我们将学习数据操作 CRUD。
