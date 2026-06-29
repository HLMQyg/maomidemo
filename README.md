# 校园流浪猫管理系统 (maomi)

一个基于 Java Servlet + JSP 的校园流浪猫综合管理平台，提供猫咪信息展示、领养申请、在线喂养、论坛交流、知识科普和后台管理等功能。

## 功能概览

**用户端**
- 欢迎页与登录注册（含短信验证码）
- 首页猫咪轮播图、搜索、卡片展示
- 猫咪详情弹窗与领养申请
- 收藏猫咪
- 我的领养 — 查看申请进度，支持聊天沟通
- 论坛 — 发帖、评论、点赞、举报、分类筛选、排序
- 知识科普 — 养猫知识文章分类浏览
- 在线喂养 — 选择猫咪使用背包道具进行模拟喂养
- 猫粮商城 — 商品浏览、购物车、结算
- 个人中心 — 修改资料、修改密码、头像上传、收藏管理

**管理后台**
- 控制台概览
- 猫咪管理 — 增删改查
- 领养审核 — 审批领养申请、留言沟通
- 论坛管理 — 置顶、删帖、处理举报
- 评论管理
- 商品管理
- 喂养记录管理
- 用户管理
- 统计报表

## 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Java 8, Servlet 4.0, JSP, JSTL 1.2 |
| 数据库 | MySQL, c3p0 连接池, commons-dbutils |
| 构建 | Maven, WAR 打包 |
| 前端 | JSP 内联 CSS, 原生 JavaScript |
| 文件处理 | commons-fileupload, commons-io |
| 工具库 | commons-beanutils, 自定义 JSON 工具 |

## 项目结构

`
maomidemo/
├── pom.xml                          # Maven 配置
├── src/main/java/com/example/maomi/
│   ├── dao/                         # 数据访问层 (AdminDAO, CatDAO, ForumDAO 等)
│   ├── filter/                      # 编码过滤器 (EncodingFilter)
│   ├── model/                       # 数据模型 (Cat, User, ForumThread 等)
│   ├── service/                     # 业务服务层
│   ├── servlet/                     # Servlet 控制器 (40+)
│   └── utils/                       # 工具类 (DBUtil, JsonUtil, CodeUtil)
├── src/main/webapp/
│   ├── index.jsp                    # 登录/注册页
│   ├── splash.jsp                   # 欢迎启动页
│   ├── admin/dashboard.jsp          # 管理后台
│   ├── pages/                       # 用户页面
│   │   ├── home.jsp                 # 首页 - 猫咪展示
│   │   ├── cart.jsp                 # 猫粮商城
│   │   ├── feeding.jsp              # 在线喂养
│   │   ├── forum.jsp                # 论坛列表
│   │   ├── forum_detail.jsp         # 帖子详情
│   │   ├── forum_post.jsp           # 发帖
│   │   ├── knowledge.jsp            # 知识科普
│   │   ├── knowledge_detail.jsp     # 文章详情
│   │   ├── my_adoptions.jsp         # 我的领养
│   │   └── user_center.jsp          # 个人中心
│   ├── images/                      # 图片资源 (猫咪/商品/背景)
│   ├── uploads/                     # 上传文件 (头像/论坛图片)
│   └── WEB-INF/
│       ├── web.xml                  # 部署描述符
│       └── lib/                     # 第三方依赖 JAR
└── target/                          # 构建输出
`

## 环境要求

- JDK 1.8+
- Maven 3.x
- MySQL 5.7+ (使用 c3p0 连接池，驱动兼容 5.x 和 8.x)
- Servlet 容器 (Tomcat 9 / Jetty 等)

## 快速开始

1. 克隆项目
`ash
git clone <repo-url> maomidemo
cd maomidemo
`

2. 配置数据库
   - 创建 MySQL 数据库
   - 修改 DBUtil.java 中的数据库连接参数（URL、用户名、密码）

3. 构建项目
`ash
mvn clean package
`

4. 部署到 Tomcat
   - 将 	arget/maomi-1.0-SNAPSHOT.war 复制到 Tomcat 的 webapps/ 目录
   - 启动 Tomcat，访问 http://localhost:8080/maomi-1.0-SNAPSHOT

5. 初始管理员账号
   - 在数据库中手动插入管理员记录（角色为 dmin）

## 关键技术点

- **编码过滤器** — EncodingFilter 统一处理 UTF-8 编码，解决中文乱码
- **文件上传** — 使用 commons-fileupload 处理头像和论坛图片上传
- **Session 管理** — 基于 Session 的用户认证，区分普通用户和管理员角色
- **前后端分离** — 部分交互（收藏、领养申请、喂养等）通过 Fetch API 异步调用 Servlet，返回文本/JSON 响应
- **连接池** — c3p0 管理数据库连接，配置在 DBUtil.java 中
