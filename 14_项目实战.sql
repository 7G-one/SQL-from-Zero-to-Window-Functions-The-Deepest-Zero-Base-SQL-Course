-- -*- coding: utf-8 -*-
-- =============================================
-- 板书教学 第14课：项目实战（超级详细版）
-- =============================================
-- 第14课：项目实战
-- 综合运用全部知识，设计完整的博客数据库系统

-- =============================================
-- 第一节：需求分析
-- =============================================

/*
 * 【博客系统需求分析】
 *
 * 我们要设计一个博客系统，需要管理：
 *
 * 1. 用户系统
 *    - 用户注册、登录
 *    - 用户个人信息
 *    - 用户角色（管理员、作者、读者）
 *
 * 2. 文章系统
 *    - 文章的创建、编辑、删除
 *    - 文章的发布状态
 *    - 文章的分类和标签
 *
 * 3. 评论系统
 *    - 文章评论
 *    - 评论的回复（嵌套评论）
 *
 * 4. 标签系统
 *    - 文章标签
 *    - 标签管理
 *
 * 5. 分类系统
 *    - 文章分类
 *    - 分类层级
 *
 * 【ER 图】
 *
 * [用户] ---< [文章] >---< [分类]
 *               |
 *               >---< [标签]（多对多）
 *               |
 *            [评论]
 *               |
 *            [回复]（自关联）
 */

-- =============================================
-- 第二节：数据库设计
-- =============================================

-- 清理旧表（如果存在）
DROP TABLE IF EXISTS post_tags;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users_blog;

-- =============================================
-- 用户表
-- =============================================

/*
 * 【用户表设计】
 *
 * 存储博客系统的所有用户信息
 *
 * 字段说明：
 * - user_id：用户唯一标识（主键）
 * - username：用户名（唯一，用于登录）
 * - email：邮箱（唯一，用于找回密码）
 * - password_hash：密码哈希值（不要存明文！）
 * - nickname：昵称（显示用）
 * - avatar_url：头像URL
 * - bio：个人简介
 * - role：角色（admin/author/reader）
 * - status：状态（active/banned/inactive）
 * - created_at：注册时间
 * - updated_at：更新时间
 * - last_login_at：最后登录时间
 */

CREATE TABLE users_blog (
    user_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    username      VARCHAR(50) NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nickname      VARCHAR(50),
    avatar_url    VARCHAR(255),
    bio           TEXT,
    role          VARCHAR(20) DEFAULT 'reader' CHECK (role IN ('admin', 'author', 'reader')),
    status        VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'banned', 'inactive')),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_at DATETIME
);

-- 创建索引
CREATE INDEX idx_users_username ON users_blog(username);
CREATE INDEX idx_users_email ON users_blog(email);
CREATE INDEX idx_users_role ON users_blog(role);

-- =============================================
-- 分类表
-- =============================================

/*
 * 【分类表设计】
 *
 * 存储文章分类，支持层级分类
 *
 * 字段说明：
 * - category_id：分类唯一标识（主键）
 * - category_name：分类名称
 * - parent_id：父分类ID（用于层级分类）
 * - description：分类描述
 * - sort_order：排序顺序
 * - created_at：创建时间
 *
 * 例如：
 * - 技术（父分类）
 *   - 前端（子分类）
 *   - 后端（子分类）
 *   - 数据库（子分类）
 */

CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name VARCHAR(50) NOT NULL,
    parent_id     INTEGER,
    description   TEXT,
    sort_order    INTEGER DEFAULT 0,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
        ON DELETE SET NULL
);

-- 创建索引
CREATE INDEX idx_categories_parent ON categories(parent_id);

-- =============================================
-- 标签表
-- =============================================

/*
 * 【标签表设计】
 *
 * 存储文章标签
 *
 * 字段说明：
 * - tag_id：标签唯一标识（主键）
 * - tag_name：标签名称（唯一）
 * - created_at：创建时间
 *
 * 标签和分类的区别：
 * - 分类：层级结构，一篇文章通常属于一个分类
 * - 标签：扁平结构，一篇文章可以有多个标签
 */

CREATE TABLE tags (
    tag_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    tag_name  VARCHAR(50) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_tags_name ON tags(tag_name);

-- =============================================
-- 文章表
-- =============================================

/*
 * 【文章表设计】
 *
 * 存储博客文章
 *
 * 字段说明：
 * - post_id：文章唯一标识（主键）
 * - title：文章标题
 * - content：文章内容
 * - summary：文章摘要
 * - author_id：作者ID（外键）
 * - category_id：分类ID（外键）
 * - status：状态（draft/published/archived）
 * - view_count：浏览次数
 * - like_count：点赞次数
 * - comment_count：评论次数
 * - is_top：是否置顶
 * - published_at：发布时间
 * - created_at：创建时间
 * - updated_at：更新时间
 */

CREATE TABLE posts (
    post_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    title         VARCHAR(200) NOT NULL,
    content       TEXT NOT NULL,
    summary       VARCHAR(500),
    author_id     INTEGER NOT NULL,
    category_id   INTEGER,
    status        VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    view_count    INTEGER DEFAULT 0,
    like_count    INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    is_top        BOOLEAN DEFAULT 0,
    published_at  DATETIME,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users_blog(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL
);

-- 创建索引
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_category ON posts(category_id);
CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_published_at ON posts(published_at);
CREATE INDEX idx_posts_is_top ON posts(is_top);

-- =============================================
-- 文章标签关联表
-- =============================================

/*
 * 【文章标签关联表】
 *
 * 实现文章和标签的多对多关系
 *
 * 一篇文章可以有多个标签
 * 一个标签可以属于多篇文章
 */

CREATE TABLE post_tags (
    post_id INTEGER,
    tag_id  INTEGER,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
        ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
        ON DELETE CASCADE
);

-- =============================================
-- 评论表
-- =============================================

/*
 * 【评论表设计】
 *
 * 存储文章评论，支持嵌套回复
 *
 * 字段说明：
 * - comment_id：评论唯一标识（主键）
 * - post_id：所属文章ID（外键）
 * - user_id：评论者ID（外键）
 * - parent_id：父评论ID（用于回复）
 * - content：评论内容
 * - status：状态（pending/approved/rejected）
 * - created_at：创建时间
 * - updated_at：更新时间
 *
 * 嵌套评论：
 * - 顶级评论：parent_id = NULL
 * - 回复评论：parent_id = 被回复的评论ID
 */

CREATE TABLE comments (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id    INTEGER NOT NULL,
    user_id    INTEGER NOT NULL,
    parent_id  INTEGER,
    content    TEXT NOT NULL,
    status     VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users_blog(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(comment_id)
        ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_comments_post ON comments(post_id);
CREATE INDEX idx_comments_user ON comments(user_id);
CREATE INDEX idx_comments_parent ON comments(parent_id);
CREATE INDEX idx_comments_status ON comments(status);

-- =============================================
-- 第三节：插入测试数据
-- =============================================

-- 插入用户数据
INSERT INTO users_blog (username, email, password_hash, nickname, role, bio) VALUES
    ('admin', 'admin@blog.com', '$2b$12$hashed_password_here', '管理员', 'admin', '博客系统管理员'),
    ('zhangsan', 'zhangsan@email.com', '$2b$12$hashed_password_here', '张三', 'author', '热爱编程的开发者'),
    ('lisi', 'lisi@email.com', '$2b$12$hashed_password_here', '李四', 'author', '前端工程师'),
    ('wangwu', 'wangwu@email.com', '$2b$12$hashed_password_here', '王五', 'reader', '技术爱好者');

-- 插入分类数据
INSERT INTO categories (category_name, parent_id, description, sort_order) VALUES
    ('技术', NULL, '技术相关文章', 1),
    ('前端', 1, '前端开发技术', 1),
    ('后端', 1, '后端开发技术', 2),
    ('数据库', 1, '数据库技术', 3),
    ('生活', NULL, '生活随笔', 2);

-- 插入标签数据
INSERT INTO tags (tag_name) VALUES
    ('JavaScript'), ('Python'), ('SQL'), ('React'), ('Vue'),
    ('Node.js'), ('Docker'), ('Git'), ('算法'), ('设计模式');

-- 插入文章数据
INSERT INTO posts (title, content, summary, author_id, category_id, status, published_at, view_count, like_count) VALUES
    ('SQL入门指南', '这是一篇关于SQL入门的文章...', 'SQL入门的基础知识', 2, 4, 'published', '2024-01-15 10:00:00', 1500, 120),
    ('JavaScript异步编程', '深入理解Promise和async/await...', 'JavaScript异步编程详解', 3, 2, 'published', '2024-01-20 14:30:00', 2300, 180),
    ('Python数据分析', '使用Pandas进行数据分析...', 'Python数据分析入门', 2, 3, 'published', '2024-02-01 09:00:00', 1800, 150),
    ('React Hooks详解', '深入理解React Hooks...', 'React Hooks使用指南', 3, 2, 'published', '2024-02-10 16:00:00', 2100, 165),
    ('Docker容器化部署', '使用Docker部署应用...', 'Docker入门教程', 2, 3, 'draft', NULL, 0, 0);

-- 插入文章标签关联数据
INSERT INTO post_tags (post_id, tag_id) VALUES
    (1, 3), (1, 9),  -- SQL入门指南：SQL、算法
    (2, 1), (2, 4),  -- JavaScript异步编程：JavaScript、React
    (3, 2), (3, 9),  -- Python数据分析：Python、算法
    (4, 1), (4, 4),  -- React Hooks详解：JavaScript、React
    (5, 7);           -- Docker容器化部署：Docker

-- 插入评论数据
INSERT INTO comments (post_id, user_id, parent_id, content, status) VALUES
    (1, 3, NULL, '写得很好，受益匪浅！', 'approved'),
    (1, 4, NULL, '请问有进阶教程吗？', 'approved'),
    (1, 2, 2, '进阶教程正在准备中...', 'approved'),
    (2, 4, NULL, 'Promise解释得很清楚！', 'approved'),
    (2, 2, NULL, '建议加上实际案例', 'approved'),
    (3, 3, NULL, 'Pandas真的很强大！', 'approved');

-- 更新文章的评论数量
UPDATE posts SET comment_count = (
    SELECT COUNT(*) FROM comments
    WHERE comments.post_id = posts.post_id
    AND comments.status = 'approved'
);

-- =============================================
-- 第四节：常用查询示例
-- =============================================

/*
 * 【查询1：获取所有已发布的文章】
 * 包含作者信息、分类信息、标签信息
 */

SELECT
    p.post_id,
    p.title,
    p.summary,
    p.published_at,
    p.view_count,
    p.like_count,
    p.comment_count,
    u.nickname AS author_name,
    u.avatar_url AS author_avatar,
    c.category_name
FROM posts p
INNER JOIN users_blog u ON p.author_id = u.user_id
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE p.status = 'published'
ORDER BY p.is_top DESC, p.published_at DESC;

/*
 * 【查询2：获取文章的标签】
 */

SELECT
    p.post_id,
    p.title,
    GROUP_CONCAT(t.tag_name) AS tags
FROM posts p
INNER JOIN post_tags pt ON p.post_id = pt.post_id
INNER JOIN tags t ON pt.tag_id = t.tag_id
WHERE p.status = 'published'
GROUP BY p.post_id, p.title;

/*
 * 【查询3：获取文章的评论（包含嵌套）】
 */

SELECT
    c.comment_id,
    c.content,
    c.created_at,
    u.nickname AS commenter,
    u.avatar_url,
    c.parent_id
FROM comments c
INNER JOIN users_blog u ON c.user_id = u.user_id
WHERE c.post_id = 1 AND c.status = 'approved'
ORDER BY c.created_at;

/*
 * 【查询4：统计每个分类的文章数量】
 */

SELECT
    c.category_name,
    COUNT(p.post_id) AS article_count
FROM categories c
LEFT JOIN posts p ON c.category_id = p.category_id AND p.status = 'published'
GROUP BY c.category_id, c.category_name
ORDER BY article_count DESC;

/*
 * 【查询5：统计每个作者的文章数量和总浏览量】
 */

SELECT
    u.nickname,
    COUNT(p.post_id) AS article_count,
    SUM(p.view_count) AS total_views,
    SUM(p.like_count) AS total_likes
FROM users_blog u
LEFT JOIN posts p ON u.user_id = p.author_id AND p.status = 'published'
WHERE u.role = 'author'
GROUP BY u.user_id, u.nickname
ORDER BY total_views DESC;

/*
 * 【查询6：获取热门文章（按浏览量排序）】
 */

SELECT
    p.post_id,
    p.title,
    p.view_count,
    p.like_count,
    u.nickname AS author_name
FROM posts p
INNER JOIN users_blog u ON p.author_id = u.user_id
WHERE p.status = 'published'
ORDER BY p.view_count DESC
LIMIT 10;

/*
 * 【查询7：获取最新评论】
 */

SELECT
    c.comment_id,
    c.content,
    c.created_at,
    u.nickname AS commenter,
    p.title AS post_title
FROM comments c
INNER JOIN users_blog u ON c.user_id = u.user_id
INNER JOIN posts p ON c.post_id = p.post_id
WHERE c.status = 'approved'
ORDER BY c.created_at DESC
LIMIT 10;

/*
 * 【查询8：搜索文章】
 */

SELECT
    p.post_id,
    p.title,
    p.summary,
    u.nickname AS author_name
FROM posts p
INNER JOIN users_blog u ON p.author_id = u.user_id
WHERE p.status = 'published'
  AND (p.title LIKE '%SQL%' OR p.content LIKE '%SQL%')
ORDER BY p.published_at DESC;

/*
 * 【查询9：获取某个标签下的所有文章】
 */

SELECT
    p.post_id,
    p.title,
    p.published_at,
    u.nickname AS author_name
FROM posts p
INNER JOIN users_blog u ON p.author_id = u.user_id
INNER JOIN post_tags pt ON p.post_id = pt.post_id
INNER JOIN tags t ON pt.tag_id = t.tag_id
WHERE t.tag_name = 'SQL' AND p.status = 'published'
ORDER BY p.published_at DESC;

/*
 * 【查询10：获取用户的文章列表】
 */

SELECT
    p.post_id,
    p.title,
    p.status,
    p.published_at,
    p.view_count,
    p.like_count
FROM posts p
WHERE p.author_id = 2
ORDER BY p.created_at DESC;

-- =============================================
-- 第五节：视图设计
-- =============================================

/*
 * 【创建视图】
 *
 * 为了简化常用查询，创建一些视图
 */

-- 已发布文章视图
CREATE VIEW v_published_posts AS
SELECT
    p.post_id,
    p.title,
    p.summary,
    p.published_at,
    p.view_count,
    p.like_count,
    p.comment_count,
    p.is_top,
    u.nickname AS author_name,
    u.avatar_url AS author_avatar,
    c.category_name
FROM posts p
INNER JOIN users_blog u ON p.author_id = u.user_id
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE p.status = 'published';

-- 文章统计视图
CREATE VIEW v_post_stats AS
SELECT
    u.nickname AS author_name,
    COUNT(p.post_id) AS total_posts,
    SUM(CASE WHEN p.status = 'published' THEN 1 ELSE 0 END) AS published_posts,
    SUM(p.view_count) AS total_views,
    SUM(p.like_count) AS total_likes,
    SUM(p.comment_count) AS total_comments
FROM users_blog u
LEFT JOIN posts p ON u.user_id = p.author_id
WHERE u.role IN ('author', 'admin')
GROUP BY u.user_id, u.nickname;

-- 使用视图
SELECT * FROM v_published_posts ORDER BY published_at DESC;
SELECT * FROM v_post_stats ORDER BY total_views DESC;

-- =============================================
-- 第六节：数据完整性约束
-- =============================================

/*
 * 【触发器示例】
 *
 * 创建触发器自动更新文章的评论数量
 */

-- MySQL 触发器语法
-- DELIMITER //
-- CREATE TRIGGER trg_comment_count_insert
-- AFTER INSERT ON comments
-- FOR EACH ROW
-- BEGIN
--     IF NEW.status = 'approved' THEN
--         UPDATE posts
--         SET comment_count = comment_count + 1
--         WHERE post_id = NEW.post_id;
--     END IF;
-- END //
-- DELIMITER ;

-- DELIMITER //
-- CREATE TRIGGER trg_comment_count_delete
-- AFTER DELETE ON comments
-- FOR EACH ROW
-- BEGIN
--     IF OLD.status = 'approved' THEN
--         UPDATE posts
--         SET comment_count = comment_count - 1
--         WHERE post_id = OLD.post_id;
--     END IF;
-- END //
-- DELIMITER ;

-- =============================================
-- 第七节：性能优化建议
-- =============================================

/*
 * 【性能优化建议】
 *
 * 1. 索引优化
 *    - 在常用查询条件上创建索引
 *    - 在外键列上创建索引
 *    - 避免过多索引
 *
 * 2. 查询优化
 *    - 避免 SELECT *，只查需要的列
 *    - 使用 LIMIT 限制结果集
 *    - 避免在 WHERE 中使用函数
 *
 * 3. 表设计优化
 *    - 选择合适的数据类型
 *    - 适当反范式（如冗余评论数量）
 *    - 大文本字段考虑分表
 *
 * 4. 缓存策略
 *    - 使用 Redis 缓存热门文章
 *    - 缓存分类和标签数据
 *    - 设置合理的缓存过期时间
 *
 * 5. 分库分表
 *    - 当数据量很大时，考虑分库分表
 *    - 按时间分表（如每月一个评论表）
 */

-- =============================================
-- 练习题
-- =============================================

/*
 * 练习1：扩展设计
 * Q: 为博客系统添加"点赞"功能
 *    需要记录哪个用户给哪篇文章点了赞
 *    设计表结构
 */

CREATE TABLE IF NOT EXISTS likes (
    like_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id   INTEGER NOT NULL,
    post_id   INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users_blog(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    UNIQUE (user_id, post_id)  -- 一个用户只能给一篇文章点一次赞
);

/*
 * 练习2：查询练习
 * Q: 查询每篇文章的点赞数
 */

SELECT
    p.post_id,
    p.title,
    COUNT(l.like_id) AS like_count
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
GROUP BY p.post_id, p.title
ORDER BY like_count DESC;

/*
 * 练习3：统计查询
 * Q: 统计每个用户的点赞数和被点赞数
 */

-- 用户的点赞数
SELECT
    u.nickname,
    COUNT(l.like_id) AS 给别人点赞数
FROM users_blog u
LEFT JOIN likes l ON u.user_id = l.user_id
GROUP BY u.user_id, u.nickname;

-- 用户被点赞数
SELECT
    u.nickname,
    COUNT(l.like_id) AS 被点赞数
FROM users_blog u
INNER JOIN posts p ON u.user_id = p.author_id
LEFT JOIN likes l ON p.post_id = l.post_id
GROUP BY u.user_id, u.nickname;

/*
 * 练习4：设计扩展
 * Q: 为博客系统添加"收藏"功能
 *    设计表结构，并写出常用查询
 */

CREATE TABLE IF NOT EXISTS favorites (
    favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL,
    post_id     INTEGER NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users_blog(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    UNIQUE (user_id, post_id)
);

-- 查询用户收藏的文章
SELECT
    p.post_id,
    p.title,
    p.summary,
    u.nickname AS author_name,
    f.created_at AS 收藏时间
FROM favorites f
INNER JOIN posts p ON f.post_id = p.post_id
INNER JOIN users_blog u ON p.author_id = u.user_id
WHERE f.user_id = 4
ORDER BY f.created_at DESC;

/*
 * 练习5：完整项目
 * Q: 基于上面的设计，完成以下任务：
 *    1. 创建所有必要的表
 *    2. 插入测试数据
 *    3. 写出10个常用查询
 *    4. 创建必要的视图
 *    5. 设计索引策略
 */

-- 这个练习需要你独立完成！
-- 参考上面的代码，设计你自己的博客系统

-- =============================================
-- 清理（可选）
-- =============================================
-- 如果你想清理所有表，取消下面的注释
-- DROP TABLE IF EXISTS favorites;
-- DROP TABLE IF EXISTS likes;
-- DROP VIEW IF EXISTS v_published_posts;
-- DROP VIEW IF EXISTS v_post_stats;
-- DROP TABLE IF EXISTS comments;
-- DROP TABLE IF EXISTS post_tags;
-- DROP TABLE IF EXISTS posts;
-- DROP TABLE IF EXISTS tags;
-- DROP TABLE IF EXISTS categories;
-- DROP TABLE IF EXISTS users_blog;

-- =============================================
-- 教授的话
-- =============================================

/*
 * 【核心收获】
 *
 * 1. 需求分析先行 —— 先画ER图，再设计表结构
 * 2. 博客系统设计 —— 用户、文章、分类、标签、评论五大模块
 * 3. 多对多关系用关联表（如 post_tags 连接文章和标签）
 * 4. 索引策略 —— 外键列、常用查询条件、排序字段加索引
 * 5. 视图简化常用查询（如 v_published_posts）
 * 6. 级联删除(ON DELETE CASCADE)保证数据一致性
 *
 * 【常见陷阱】
 *
 * 1. 不要一上来就写SQL，先画图理清表之间的关系
 * 2. 密码字段必须用哈希存储（bcrypt），绝不明文
 * 3. 软删除(status='deleted')比硬删除更安全，数据可恢复
 * 4. 大文本字段(如文章content)考虑是否需要分表
 * 5. 创建时间/更新时间字段几乎是每个表的标配
 *
 * 【课程回顾与展望】
 *
 * 15课SQL之旅结束！你已掌握：CRUD、条件查询、聚合分组、
 * 多表连接、子查询、索引优化、视图存储过程、事务并发、
 * 数据库设计、安全防护、项目实战。
 *
 * 接下来的建议：
 * - LeetCode数据库题刷起来（SQLZoo、HackerRank也可以）
 * - 用MySQL或PostgreSQL搭建真实项目
 * - 学习ORM框架（如SQLAlchemy、MyBatis）提升开发效率
 */

-- =============================================
-- 生活类比
-- =============================================
-- 项目实战就像盖一座房子：
-- 先画图纸（数据库设计）
-- 再打地基（建表）
-- 然后砌墙（插入数据）
-- 最后装修（查询和展示）

-- =============================================
-- 恭喜完成
-- =============================================
-- 恭喜你完成了第14课：项目实战！
-- 你已完成全部 SQL 课程，继续加油！
