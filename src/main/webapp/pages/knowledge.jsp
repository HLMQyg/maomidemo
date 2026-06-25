<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.model.KnowledgeArticle" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
  User sessionUser = (User) session.getAttribute("user");
  if (sessionUser == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
  }
  List<KnowledgeArticle> articles = (List<KnowledgeArticle>) request.getAttribute("articles");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>知识科普 - 校园流浪猫管理</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: #fffaf3;
      font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
      position: relative;
    }
    body::before {
      content: "";
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background: url('<%= request.getContextPath() %>/images/login-bg.jpg') center/cover no-repeat;
      opacity: 0.08;
      z-index: -1;
      pointer-events: none;
    }
    .navbar {
      background: rgba(255, 250, 240, 0.92);
      backdrop-filter: blur(12px);
      padding: 12px 30px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      box-shadow: 0 2px 15px rgba(0,0,0,0.06);
      position: sticky;
      top: 0;
      z-index: 100;
    }
    .nav-logo { font-size: 22px; font-weight: 700; color: #b87c2c; }
    .nav-links a {
      text-decoration: none; color: #a66a1a; font-weight: 600;
      padding: 6px 14px; border-radius: 20px; transition: 0.2s; font-size: 15px;
    }
    .nav-links a:hover { background: #ffeed9; color: #8b5a10; }
    .user-badge { display: flex; align-items: center; gap: 8px; color: #8b5a10; font-weight: 600; }
    .logout-btn {
      background: none; border: 1px solid #e6a14c; color: #e6a14c;
      padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600; margin-left: 15px;
    }
    .logout-btn:hover { background: #e6a14c; color: white; }

    .container { max-width: 900px; margin: 30px auto; padding: 20px; }
    .search-bar {
      display: flex; gap: 10px; margin-bottom: 25px;
    }
    .search-bar input {
      flex: 1; padding: 12px 16px; border: 1.5px solid #f0d9b5;
      border-radius: 30px; background: white; font-size: 15px; outline: none;
    }
    .search-bar input:focus { border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.12); }
    .search-bar button {
      background: #e6a14c; color: white; border: none; border-radius: 30px;
      padding: 0 25px; font-weight: 700; cursor: pointer; transition: 0.3s;
    }
    .search-bar button:hover { background: #c97d2a; }
    .category-tabs {
      display: flex; gap: 10px; margin-bottom: 25px; flex-wrap: wrap;
    }
    .category-tabs a {
      text-decoration: none; padding: 6px 16px; border-radius: 20px;
      background: white; color: #b3904f; font-weight: 600; transition: 0.2s;
      border: 1px solid #f0d9b5;
    }
    .category-tabs a.active, .category-tabs a:hover {
      background: #e6a14c; color: white; border-color: #e6a14c;
    }
    .article-card {
      background: white; border-radius: 18px; padding: 20px; margin-bottom: 15px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.04); transition: 0.3s;
      cursor: pointer;
    }
    .article-card:hover { transform: translateY(-2px); box-shadow: 0 10px 25px rgba(0,0,0,0.08); }
    .article-card h3 { color: #b87c2c; margin-bottom: 8px; }
    .article-card p { color: #6f4518; margin: 5px 0; font-size: 14px; }
    .article-meta { font-size: 13px; color: #aaa; margin-top: 10px; }
  </style>
</head>
<body>
<nav class="navbar">
  <div class="nav-logo">🐾 校园流浪猫</div>
  <div class="nav-links">
    <div class="nav-links">
      <a href="<%= request.getContextPath() %>/pages/home.jsp">🏠 首页</a>
      <a href="<%= request.getContextPath() %>/myAdoptions">📋 我的领养</a>
      <a href="<%= request.getContextPath() %>/pages/forum.jsp">💬 论坛</a>
      <a href="<%= request.getContextPath() %>/knowledgeList">📖 知识科普</a>
      <a href="<%= request.getContextPath() %>/pages/feeding.jsp">🍼 在线喂养</a>
      <a href="<%= request.getContextPath() %>/pages/user_center.jsp">👤 个人中心</a>
    </div>
  </div>
  <div class="user-badge">
    🐱 <%= sessionUser.getUsername() %>
    <button class="logout-btn" onclick="logout()">退出登录</button>
  </div>
</nav>

<div class="container">
  <h2 style="color:#6f4518; margin-bottom:20px;">📖 知识科普</h2>

  <!-- 搜索栏 -->
  <form action="<%= request.getContextPath() %>/knowledgeList" method="get" class="search-bar">
    <input type="text" name="keyword" placeholder="搜索文章...">
    <button type="submit">🔍 搜索</button>
  </form>

  <!-- 分类标签 -->
  <div class="category-tabs">
    <a href="<%= request.getContextPath() %>/knowledgeList" class="active">全部</a>
    <a href="<%= request.getContextPath() %>/knowledgeList?category=习性">🐾 猫咪习性</a>
    <a href="<%= request.getContextPath() %>/knowledgeList?category=饲养">🍽️ 饲养指南</a>
    <a href="<%= request.getContextPath() %>/knowledgeList?category=健康">🏥 健康护理</a>
    <a href="<%= request.getContextPath() %>/knowledgeList?category=其他">📌 其他</a>
  </div>

  <!-- 文章列表 -->
  <% if (articles == null || articles.isEmpty()) { %>
  <div style="text-align:center; color:#a68a64; padding:40px;">暂无文章</div>
  <% } else {
    for (KnowledgeArticle article : articles) { %>
  <div class="article-card" onclick="location.href='<%= request.getContextPath() %>/knowledgeDetail?id=<%= article.getId() %>'">
    <h3><%= article.getTitle() %></h3>
    <p><%= article.getContent() != null && article.getContent().length() > 80 ? article.getContent().substring(0, 80) + "..." : article.getContent() %></p>
    <div class="article-meta">
      🏷️ <%= article.getCategory() %> | 👁️ <%= article.getReadCount() %> 阅读 | <%= article.getCreatedAt().toString().substring(0, 19) %>
    </div>
  </div>
  <%  }
  } %>
</div>

<script>
  function logout() {
    if (confirm('确定要退出登录吗？')) {
      window.location.href = '<%= request.getContextPath() %>/logout';
    }
  }
</script>
</body>
</html>