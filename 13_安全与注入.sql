-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第13课：安全与注入（超级详细版）
-- =============================================
-- 第13课：安全与注入
-- SQL注入原理、攻击手法、参数化查询防御、输入验证

-- =============================================
-- 准备工作：创建示例数据
-- =============================================

DROP TABLE IF EXISTS users_sec;
DROP TABLE IF EXISTS admins_sec;
DROP TABLE IF EXISTS products_sec;

-- 用户表
CREATE TABLE users_sec (
    user_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    email    VARCHAR(100),
    is_admin BOOLEAN DEFAULT 0
);

INSERT INTO users_sec (username, password, email, is_admin) VALUES
    ('zhangsan', 'password123', 'zhangsan@email.com', 0),
    ('lisi', 'qwerty456', 'lisi@email.com', 0),
    ('wangwu', 'admin789', 'wangwu@email.com', 1),
    ('admin', 'supersecret', 'admin@company.com', 1);

-- 管理员表
CREATE TABLE admins_sec (
    admin_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    role     VARCHAR(20) DEFAULT 'editor'
);

INSERT INTO admins_sec (username, password, role) VALUES
    ('admin', 'admin123', 'superadmin'),
    ('editor', 'editor456', 'editor');

-- 商品表
CREATE TABLE products_sec (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2),
    stock        INTEGER
);

INSERT INTO products_sec (product_name, price, stock) VALUES
    ('iPhone 15', 7999.00, 100),
    ('MacBook Pro', 14999.00, 50),
    ('AirPods Pro', 1899.00, 200);

-- =============================================
-- 第一节：什么是 SQL 注入？
-- =============================================

/*
 * 【SQL 注入是什么？】
 *
 * SQL 注入是一种代码注入攻击
 * 攻击者通过在输入中插入恶意 SQL 代码
 * 从而欺骗服务器执行非预期的 SQL 命令
 *
 * 生活类比：
 *   想象一个自动售货机
 *   正常操作：投入硬币，选择商品，得到商品
 *   SQL注入：在选择商品时，输入特殊指令，让机器吐出所有商品
 *
 * 【SQL 注入的危害】
 *
 * 1. 数据泄露
 *    - 窃取用户密码、个人信息
 *    - 窃取商业机密
 *
 * 2. 数据篡改
 *    - 修改用户数据
 *    - 修改订单信息
 *
 * 3. 数据删除
 *    - 删除整个数据库
 *
 * 4. 权限提升
 *    - 获取管理员权限
 *    - 执行系统命令
 */

-- =============================================
-- 第二节：SQL 注入的原理
-- =============================================

/*
 * 【注入原理】
 *
 * 假设有一个登录查询：
 *
 * SELECT * FROM users
 * WHERE username = '用户名' AND password = '密码';
 *
 * 正常输入：
 * 用户名：zhangsan
 * 密码：password123
 *
 * 生成的 SQL：
 * SELECT * FROM users
 * WHERE username = 'zhangsan' AND password = 'password123';
 *
 * 结果：返回 zhangsan 的记录
 *
 * ============================================
 *
 * 恶意输入：
 * 用户名：admin' --
 * 密码：任意值
 *
 * 生成的 SQL：
 * SELECT * FROM users
 * WHERE username = 'admin' --' AND password = '任意值';
 *
 * 解释：
 * - 'admin' 是用户名
 * - -- 是 SQL 注释，后面的代码被注释掉了
 * - 密码验证被跳过了！
 *
 * 结果：以 admin 身份登录成功！
 */

-- 演示注入（仅用于教学，不要在生产环境使用！）

-- 正常查询
SELECT * FROM users_sec
WHERE username = 'zhangsan' AND password = 'password123';

-- 注入攻击（模拟）
-- 假设用户输入：admin' --
SELECT * FROM users_sec
WHERE username = 'admin' --' AND password = '任意密码';
-- 密码验证被跳过！

-- =============================================
-- 第三节：常见的 SQL 注入手法
-- =============================================

/*
 * 【常见的注入手法】
 *
 * 1. 基于注释的注入
 *    用户名：admin' --
 *    用户名：admin' #
 *
 * 2. 基于 OR 的注入
 *    用户名：' OR '1'='1
 *    密码：' OR '1'='1
 *
 *    生成的 SQL：
 *    SELECT * FROM users
 *    WHERE username = '' OR '1'='1' AND password = '' OR '1'='1';
 *
 *    结果：'1'='1' 永远为真，返回所有用户！
 *
 * 3. 基于 UNION 的注入
 *    输入：' UNION SELECT * FROM admins --
 *
 *    生成的 SQL：
 *    SELECT * FROM products
 *    WHERE name = '' UNION SELECT * FROM admins --'
 *
 *    结果：返回管理员表的数据！
 *
 * 4. 基于时间的盲注
 *    输入：' OR IF(1=1, SLEEP(5), 0) --
 *
 *    如果延迟5秒，说明注入成功
 *
 * 5. 基于错误的注入
 *    输入：' AND 1=CONVERT(int, (SELECT TOP 1 table_name FROM information_schema.tables)) --
 *
 *    通过错误信息获取数据库结构
 */

-- 演示基于 OR 的注入
-- 正常查询
SELECT * FROM users_sec
WHERE username = 'zhangsan' AND password = 'wrong';

-- 注入攻击（模拟）
SELECT * FROM users_sec
WHERE username = '' OR '1'='1' AND password = '' OR '1'='1';
-- 返回所有用户！

-- 演示基于 UNION 的注入
-- 正常查询
SELECT product_name, price FROM products_sec
WHERE product_name LIKE '%iPhone%';

-- 注入攻击（模拟）
SELECT product_name, price FROM products_sec
WHERE product_name LIKE '%'
UNION SELECT username, password FROM users_sec --%';
-- 返回用户密码！

-- =============================================
-- 第四节：防御 SQL 注入的方法
-- =============================================

/*
 * 【防御方法】
 *
 * 1. 参数化查询（最重要！）
 *    使用占位符，不要拼接 SQL
 *
 * 2. 输入验证
 *    检查输入是否符合预期格式
 *
 * 3. 转义特殊字符
 *    对输入中的特殊字符进行转义
 *
 * 4. 最小权限原则
 *    数据库用户只给必要的权限
 *
 * 5. 使用 ORM 框架
 *    框架通常会自动处理注入问题
 *
 * 6. 错误处理
 *    不要向用户显示详细的错误信息
 *
 * 7. Web 应用防火墙（WAF）
 *    检测和阻止恶意请求
 */

-- =============================================
-- 第五节：参数化查询
-- =============================================

/*
 * 【参数化查询】
 *
 * 参数化查询是防御 SQL 注入的最佳方法
 * 使用占位符代替直接拼接
 *
 * 【Python 示例】
 *
 * 错误写法（容易被注入）：
 * query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
 *
 * 正确写法（参数化查询）：
 * cursor.execute("SELECT * FROM users WHERE username = ? AND password = ?", (username, password))
 *
 * 【Java 示例】
 *
 * 错误写法：
 * String query = "SELECT * FROM users WHERE username = '" + username + "'";
 *
 * 正确写法：
 * PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE username = ?");
 * stmt.setString(1, username);
 *
 * 【PHP 示例】
 *
 * 错误写法：
 * $query = "SELECT * FROM users WHERE username = '$username'";
 *
 * 正确写法：
 * $stmt = $pdo->prepare("SELECT * FROM users WHERE username = :username");
 * $stmt->execute(['username' => $username]);
 */

-- =============================================
-- 第六节：输入验证
-- =============================================

/*
 * 【输入验证】
 *
 * 在处理用户输入之前，先验证其格式
 *
 * 验证规则：
 * 1. 长度检查 —— 输入不能太长
 * 2. 类型检查 —— 数字必须是数字
 * 3. 格式检查 —— 邮箱必须符合邮箱格式
 * 4. 范围检查 —— 年龄必须在合理范围内
 * 5. 白名单检查 —— 只允许特定字符
 */

-- 验证示例（伪代码）
/*
-- 验证用户名：只允许字母、数字、下划线
if not re.match(r'^[a-zA-Z0-9_]+$', username):
    raise ValueError("用户名格式错误")

-- 验证邮箱
if not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', email):
    raise ValueError("邮箱格式错误")

-- 验证年龄
if not (0 < age < 150):
    raise ValueError("年龄必须在1-150之间")
*/

-- =============================================
-- 第七节：转义特殊字符
-- =============================================

/*
 * 【转义特殊字符】
 *
 * 将输入中的特殊字符进行转义
 *
 * 需要转义的字符：
 * - 单引号 ' → ''
 * - 双引号 " → \"
 * - 反斜杠 \ → \\
 * - 百分号 % → \%
 * - 下划线 _ → \_
 *
 * Python 的 MySQL Connector 示例：
 * import mysql.connector
 * connection = mysql.connector.connect(...)
 * cursor = connection.cursor()
 * escaped_input = connection.converter.escape(username)
 */

-- =============================================
-- 第八节：最小权限原则
-- =============================================

/*
 * 【最小权限原则】
 *
 * 数据库用户只应该拥有完成任务所需的最小权限
 *
 * 不同用户的权限：
 * - 普通用户：只读权限
 * - 编辑用户：读写权限
 * - 管理员：所有权限
 *
 * 不要用 root 用户连接数据库！
 */

-- MySQL 权限管理示例
-- CREATE USER 'webapp'@'localhost' IDENTIFIED BY 'password';
-- GRANT SELECT, INSERT, UPDATE ON mydb.* TO 'webapp'@'localhost';
-- FLUSH PRIVILEGES;

-- =============================================
-- 第九节：其他安全措施
-- =============================================

/*
 * 【其他安全措施】
 *
 * 1. 密码加密存储
 *    不要明文存储密码！
 *    使用 bcrypt、scrypt 等算法
 *
 * 2. HTTPS 传输
 *    使用 HTTPS 加密数据传输
 *
 * 3. 防止 XSS 攻击
 *    对输出进行 HTML 转义
 *
 * 4. 防止 CSRF 攻击
 *    使用 CSRF Token
 *
 * 5. 日志记录
 *    记录所有数据库操作
 *
 * 6. 定期备份
 *    定期备份数据库
 *
 * 7. 及时更新
 *    及时更新数据库软件，修复安全漏洞
 */

-- =============================================
-- 第十节：SQL 注入的检测
-- =============================================

/*
 * 【如何检测 SQL 注入？】
 *
 * 1. 手动测试
 *    在输入中输入特殊字符，观察程序反应
 *
 * 2. 自动化工具
 *    - sqlmap
 *    - Burp Suite
 *    - OWASP ZAP
 *
 * 3. 代码审计
 *    检查代码中是否有拼接 SQL 的地方
 *
 * 4. 渗透测试
 *    请专业安全团队进行测试
 */

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：识别注入
 * Q: 以下代码存在什么安全问题？如何修复？
 *
 *    query = "SELECT * FROM users WHERE username = '" + username + "'"
 *
 * A: 存在 SQL 注入风险！
 *    修复：使用参数化查询
 *    cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
 */

/*
 * 练习2：编写安全代码
 * Q: 编写一个安全的用户登录查询（使用参数化查询）
 *
 * A: Python 示例：
 *    cursor.execute(
 *        "SELECT * FROM users WHERE username = ? AND password = ?",
 *        (username, password_hash)
 *    )
 */

/*
 * 练习3：输入验证
 * Q: 设计一个输入验证规则，用于用户注册
 *
 * A: 验证规则：
 *    1. 用户名：3-20个字符，只允许字母、数字、下划线
 *    2. 密码：至少8个字符，包含大小写字母和数字
 *    3. 邮箱：符合邮箱格式
 *    4. 年龄：1-150之间的整数
 */

/*
 * 练习4：分析攻击
 * Q: 分析以下输入，解释它是如何绕过验证的：
 *    用户名：' OR '1'='1' --
 *
 * A: 分析：
 *    1. ' OR '1'='1' 使 WHERE 条件永远为真
 *    2. -- 注释掉后面的密码验证
 *    3. 结果：返回所有用户
 */

/*
 * 练习5：防御方案
 * Q: 列出至少5种防御 SQL 注入的方法
 *
 * A: 1. 参数化查询
 *    2. 输入验证
 *    3. 转义特殊字符
 *    4. 最小权限原则
 *    5. 使用 ORM 框架
 *    6. 错误处理（不显示详细错误）
 *    7. Web 应用防火墙
 */

-- =============================================
-- 清理
-- =============================================
DROP TABLE IF EXISTS users_sec;
DROP TABLE IF EXISTS admins_sec;
DROP TABLE IF EXISTS products_sec;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. SQL注入 = 在输入中插入恶意SQL代码，欺骗服务器执行非预期操作
 * 2. 攻击手法 —— 注释注入(' --)、OR注入(' OR '1'='1)、UNION注入
 * 3. 参数化查询 —— 用占位符代替拼接，是防御注入的最佳方法
 * 4. 输入验证 —— 长度/类型/格式/范围/白名单检查
 * 5. 最小权限原则 —— 数据库用户只给必要的权限，不用root
 * 6. 密码用bcrypt等算法加密存储，绝不明文存储
 *
 * 【常见陷阱】
 *
 * 1. 永远不要用字符串拼接构造SQL！即使用了转义也不安全
 * 2. 即使前端做了验证，后端也必须再次验证（前端可被绕过）
 * 3. 错误信息不要暴露数据库结构（如表名、列名）
 * 4. ORM框架也不能100%防注入，原生SQL仍需参数化
 * 5. SQL注入不仅影响数据泄露，还可能导致数据篡改和删除
 *
 * 【下节课预告】
 *
 * 第14课是最后一课——项目实战！将综合运用所有知识，
 * 设计一个完整的博客数据库系统（用户、文章、评论、标签）。
 */

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第13课：安全与注入！
-- 下节课我们将学习项目实战。
