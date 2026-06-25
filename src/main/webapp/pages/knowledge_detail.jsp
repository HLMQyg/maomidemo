<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.model.KnowledgeArticle" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
  User sessionUser = (User) session.getAttribute("user");
  if (sessionUser == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
  }
  KnowledgeArticle article = (KnowledgeArticle) request.getAttribute("article");
  if (article == null) {
    response.sendRedirect(request.getContextPath() + "/pages/knowledge.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title><%= article.getTitle() %> - 校园流浪猫管理</title>
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

    .container { max-width: 800px; margin: 30px auto; padding: 20px; }
    .article-full {
      background: white; border-radius: 24px; padding: 30px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.06);
    }
    .article-full h1 { color: #b87c2c; margin-bottom: 10px; }
    .meta { color: #aaa; font-size: 14px; margin-bottom: 20px; }
    .content { color: #6f4518; line-height: 1.8; font-size: 15px; white-space: pre-wrap; }
    .back-btn {
      display: inline-block; margin-top: 20px; background: #e6a14c; color: white;
      padding: 10px 22px; border-radius: 30px; text-decoration: none; font-weight: 600;
    }
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
  <div class="article-full">
    <h1><%= article.getTitle() %></h1>
    <div class="meta">
      🏷️ <%= article.getCategory() %> | 🖊️ <%= article.getAuthor() != null ? article.getAuthor() : "管理员" %> | 👁️ <%= article.getReadCount() + 1 %> 阅读 | <%= article.getCreatedAt().toString().substring(0, 19) %>
    </div>
    <div class="content"><%= article.getContent() %></div>
    <a href="<%= request.getContextPath() %>/knowledgeList" class="back-btn">← 返回列表</a>
  </div>
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