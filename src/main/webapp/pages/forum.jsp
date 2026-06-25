
<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.model.ForumThread" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    List<ForumThread> threads = (List<ForumThread>) request.getAttribute("threads");
    String currentCategory = (String) request.getAttribute("currentCategory");
    if (currentCategory == null) currentCategory = "";
    String currentSort = (String) request.getAttribute("currentSort");
    if (currentSort == null) currentSort = "latest";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>论坛 - 校园流浪猫管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #fffaf3; font-family: "Microsoft YaHei", "PingFang SC", sans-serif; position: relative; }
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: url(''<%= request.getContextPath() %>/images/login-bg.jpg'') center/cover no-repeat;
            opacity: 0.08; z-index: -1; pointer-events: none;
        }
        .navbar { background: rgba(255,250,240,0.92); backdrop-filter: blur(12px); box-shadow: 0 2px 15px rgba(0,0,0,0.06); padding: 12px 30px; display: flex; align-items: center; justify-content: space-between; position: sticky; top: 0; z-index: 100; }
        .nav-logo { font-size: 22px; font-weight: 700; color: #b87c2c; letter-spacing: 1px; }
        .nav-links { display: flex; gap: 25px; }
        .nav-links a { text-decoration: none; color: #a66a1a; font-weight: 600; padding: 6px 14px; border-radius: 20px; transition: 0.2s; font-size: 15px; }
        .nav-links a:hover, .nav-links a.active { background: #ffeed9; color: #8b5a10; }
        .user-badge { display: flex; align-items: center; gap: 8px; color: #8b5a10; font-weight: 600; }
        .logout-btn { background: none; border: 1px solid #e6a14c; color: #e6a14c; padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600; transition: 0.2s; margin-left: 15px; }
        .logout-btn:hover { background: #e6a14c; color: white; }
        .container { max-width: 900px; margin: 0 auto; padding: 20px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .page-header h1 { font-size: 24px; color: #6f4518; }
        .btn { display: inline-block; padding: 10px 22px; border: none; border-radius: 14px; font-size: 14px; font-weight: 700; cursor: pointer; transition: 0.2s; text-decoration: none; font-family: "Microsoft YaHei", sans-serif; }
        .btn-primary { background: #e6a14c; color: white; }
        .btn-primary:hover { background: #c97d2a; }
        .tabs { display: flex; gap: 8px; margin-bottom: 20px; flex-wrap: wrap; }
        .tab { padding: 8px 18px; border-radius: 20px; font-size: 13px; font-weight: 600; cursor: pointer; transition: 0.2s; border: 1.5px solid #f0d9b5; background: white; color: #b3904f; text-decoration: none; }
        .tab:hover, .tab.active { background: #e6a14c; color: white; border-color: #e6a14c; }
        .sort-bar { display: flex; gap: 8px; margin-bottom: 20px; }
        .sort-btn { padding: 6px 16px; border-radius: 16px; font-size: 13px; cursor: pointer; border: 1px solid #e0d8cc; background: white; color: #8b6914; text-decoration: none; }
        .sort-btn.active { background: #6f4518; color: white; border-color: #6f4518; }
        .thread-card { background: white; border-radius: 18px; padding: 20px 24px; margin-bottom: 14px; box-shadow: 0 4px 12px rgba(0,0,0,0.04); transition: 0.2s; cursor: pointer; display: flex; gap: 16px; }
        .thread-card:hover { box-shadow: 0 6px 20px rgba(0,0,0,0.08); transform: translateY(-1px); }
        .thread-card.pinned { border-left: 4px solid #e6a14c; }
        .thread-avatar { width: 44px; height: 44px; border-radius: 50%; background: #fef3e6; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; color: #e6a14c; font-weight: 700; }
        .thread-body { flex: 1; min-width: 0; }
        .thread-title { font-size: 16px; font-weight: 700; color: #3d3226; margin-bottom: 6px; }
        .thread-title .pin-tag { font-size: 12px; color: #e6a14c; margin-right: 6px; }
        .thread-meta { font-size: 12px; color: #a69780; display: flex; gap: 16px; flex-wrap: wrap; margin-top: 6px; }
        .thread-meta span { white-space: nowrap; }
        .cat-tag { display: inline-block; padding: 2px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; background: #fef3e6; color: #e6a14c; margin-left: 8px; }
        .category-tag { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; margin-left: 6px; }
        .cat-talking { background: #e8f5e9; color: #2e7d32; }
        .cat-rescue { background: #fdecea; color: #c62828; }
        .cat-adopt { background: #e3f2fd; color: #1565c0; }
        .cat-chat { background: #f3e5f5; color: #6a1b9a; }
        .empty { text-align: center; padding: 60px 20px; color: #bbb; }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="nav-logo">校园流浪猫</div>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/pages/home.jsp">首页</a>
        <a href="<%= request.getContextPath() %>/myAdoptions">我的领养</a>
        <a href="<%= request.getContextPath() %>/forumList" class="active">论坛</a>
        <a href="<%= request.getContextPath() %>/knowledgeList">知识科普</a>
        <a href="<%= request.getContextPath() %>/pages/feeding.jsp">在线喂养</a>
        <a href="<%= request.getContextPath() %>/pages/user_center.jsp">个人中心</a>
    </div>
    <div class="user-badge">
        <%= sessionUser.getUsername() %>
        <button class="logout-btn" onclick="logout()">退出登录</button>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h1>论坛</h1>
        <a href="<%= request.getContextPath() %>/forumPost" class="btn btn-primary">+ 发布帖子</a>
    </div>

    <div class="tabs">
        <a href="?sort=<%= currentSort %>" class="tab <%= "".equals(currentCategory) ? "active" : "" %>">全部</a>
        <a href="?category=猫咪日常&sort=<%= currentSort %>" class="tab <%= "猫咪日常".equals(currentCategory) ? "active" : "" %>">猫咪日常</a>
        <a href="?category=救助求助&sort=<%= currentSort %>" class="tab <%= "救助求助".equals(currentCategory) ? "active" : "" %>">救助求助</a>
        <a href="?category=领养分享&sort=<%= currentSort %>" class="tab <%= "领养分享".equals(currentCategory) ? "active" : "" %>">领养分享</a>
        <a href="?category=闲聊交流&sort=<%= currentSort %>" class="tab <%= "闲聊交流".equals(currentCategory) ? "active" : "" %>">闲聊交流</a>
    </div>

    <div class="sort-bar">
        <a href="?category=<%= currentCategory %>&sort=latest" class="sort-btn <%= "latest".equals(currentSort) ? "active" : "" %>">最新</a>
        <a href="?category=<%= currentCategory %>&sort=hot" class="sort-btn <%= "hot".equals(currentSort) ? "active" : "" %>">最热</a>
    </div>

    <% if (threads == null || threads.isEmpty()) { %>
    <div class="empty">还没有帖子，快来发布第一个吧</div>
    <% } else {
        for (ForumThread t : threads) {
            String catCls = "";
            if ("猫咪日常".equals(t.getCategory())) catCls = "cat-talking";
            else if ("救助求助".equals(t.getCategory())) catCls = "cat-rescue";
            else if ("领养分享".equals(t.getCategory())) catCls = "cat-adopt";
            else catCls = "cat-chat";
    %>
    <div class="thread-card <%= t.getIsPinned() == 1 ? "pinned" : "" %>" onclick="location.href='<%= request.getContextPath() %>/forumDetail?id=<%= t.getId() %>'">
        <div class="thread-avatar"><%= t.getUserId().substring(0, 1) %></div>
        <div class="thread-body">
            <div class="thread-title">
                <% if (t.getIsPinned() == 1) { %><span class="pin-tag">[置顶]</span><% } %>
                <%= t.getTitle() %>
                <% if (t.getCatName() != null && !t.getCatName().isEmpty()) { %>
                <span class="cat-tag"><%= t.getCatName() %></span>
                <% } %>
                <span class="category-tag <%= catCls %>"><%= t.getCategory() %></span>
            </div>
            <div class="thread-meta">
                <span><%= t.getUserId() %></span>
                <span><%= t.getViewCount() %> 浏览</span>
                <span><%= t.getLikeCount() %> 赞</span>
                <span><%= t.getCommentCount() %> 评论</span>
                <span><%= t.getCreatedAt() != null ? t.getCreatedAt().toString().substring(0, 16) : "" %></span>
            </div>
        </div>
    </div>
    <% }} %>
</div>

<script>
    function logout() {
        if (confirm('确定要退出登录吗？')) window.location.href = '<%= request.getContextPath() %>/logout';
    }
</script>
</body>
</html>