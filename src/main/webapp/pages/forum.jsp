<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.model.ForumThread" %>
<%@ page import="com.example.maomi.model.Cat" %>
<%@ page import="com.example.maomi.dao.CatDAO" %>
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
    CatDAO catDAO = new CatDAO();
    List<Cat> cats = catDAO.getAllCats();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>论坛 - 校园流浪猫管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #fffaf3;
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            height: 100vh; overflow: hidden;
            position: relative;
            display: flex; flex-direction: column;
        }
        body::before {
            content: "";
            position: fixed; top: 0; left: 0;
            width: 100%; height: 100%;
            background: url('../images/login-bg.jpg') center/cover no-repeat;
            opacity: 0.08; z-index: -1; pointer-events: none;
        }

        /* ========== Navbar ========== */
        .navbar {
            background: rgba(255, 250, 240, 0.92);
            backdrop-filter: blur(12px);
            box-shadow: 0 2px 15px rgba(0,0,0,0.06);
            padding: 12px 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-shrink: 0;
            z-index: 100;
        }
        .nav-logo { font-size: 22px; font-weight: 700; color: #b87c2c; letter-spacing: 1px; }
        .nav-links { display: flex; gap: 25px; }
        .nav-links a {
            text-decoration: none; color: #a66a1a; font-weight: 600;
            padding: 6px 14px; border-radius: 20px; transition: 0.2s; font-size: 15px;
        }
        .nav-links a:hover { background: #ffeed9; color: #8b5a10; }
        .nav-links a.active { background: #ffeed9; color: #8b5a10; }
        .user-badge { display: flex; align-items: center; gap: 8px; color: #8b5a10; font-weight: 600; }
        .logout-btn {
            background: none; border: 1px solid #e6a14c; color: #e6a14c;
            padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600;
            transition: 0.2s; margin-left: 15px;
        }
        .logout-btn:hover { background: #e6a14c; color: white; }

        /* ========== Main Layout ========== */
        .main-layout {
            display: flex; flex: 1; min-height: 0;
        }

        /* ========== Left Sidebar ========== */
        .sidebar {
            flex: 1; min-width: 240px; max-width: 400px; background: rgba(255,250,243,0.55);
            border-right: 1px solid #f0e8d8;
            display: flex; flex-direction: column;
            overflow: hidden; min-height: 0;
        }
        .sidebar-nav {
            padding: 20px 16px 12px;
            display: flex; flex-direction: column; gap: 8px;
            border-bottom: 1px solid #eee;
            flex-shrink: 0;
        }
        .sidebar-btn {
            display: flex; align-items: center; gap: 12px;
            width: 100%; padding: 12px 16px; border: none; border-radius: 10px;
            background: transparent; cursor: pointer;
            font-size: 15px; font-weight: 600; color: #555;
            transition: 0.15s; text-decoration: none; font-family: inherit;
        }
        .sidebar-btn:hover { background: #f0ece6; color: #e6a14c; }
        .sidebar-btn .btn-icon {
            width: 22px; height: 22px; display: flex; align-items: center;
            justify-content: center; font-size: 18px; flex-shrink: 0;
        }
        .sidebar-btn.primary {
            background: #e6a14c; color: #fff; justify-content: center;
        }
        .sidebar-btn.primary:hover { background: #d48a2e; }

        /* Cat list */
        .sidebar-cats {
            flex: 1; overflow-y: auto; padding: 8px 16px 16px;
        }
        .sidebar-cats::-webkit-scrollbar { width: 4px; }
        .sidebar-cats::-webkit-scrollbar-thumb { background: #ddd; border-radius: 2px; }
        .sidebar-label {
            font-size: 12px; color: #aaa; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1px;
            padding: 12px 0 8px;
        }
        .cat-btn {
            display: flex; align-items: center; gap: 10px;
            width: 100%; padding: 10px 14px; border: none; border-radius: 10px;
            background: transparent; cursor: pointer;
            font-size: 14px; font-weight: 600; color: #555;
            transition: 0.15s; text-decoration: none; font-family: inherit;
        }
        .cat-btn:hover { background: #f0ece6; color: #e6a14c; }
        .cat-btn.active { background: #fef6ec; color: #e6a14c; }
        .cat-avatar {
            width: 36px; height: 36px; border-radius: 50%; flex-shrink: 0;
            background: #eee center/cover no-repeat;
        }
        .cat-btn .cat-name { flex: 1; text-align: left; }

        /* ========== Right Panel ========== */
        .right-panel {
            flex: 2; display: flex; flex-direction: column;
            overflow: hidden; background: transparent;
            min-height: 0;
        }

        /* Search + Filter (fixed) */
        .search-area {
            flex-shrink: 0; padding: 20px 24px 20px;
            background: rgba(255,255,255,0.85);
            backdrop-filter: blur(8px);
        }
        .search-row {
            display: flex; gap: 10px; margin-bottom: 14px;
        }
        .search-input {
            flex: 1; padding: 10px 18px; border: 1.5px solid #e8e8e8;
            border-radius: 24px; font-size: 14px; outline: none;
            background: #f9f9f9; font-family: inherit; transition: 0.15s;
        }
        .search-input:focus { border-color: #e6a14c; background: #fff; }
        .search-btn {
            padding: 10px 24px; background: #e6a14c; color: #fff;
            border: none; border-radius: 24px; cursor: pointer;
            font-size: 14px; font-weight: 700; transition: 0.15s; font-family: inherit;
        }
        .search-btn:hover { background: #d48a2e; }
        .filter-row {
            display: flex; gap: 8px; flex-wrap: wrap;
        }
        .filter-chip {
            padding: 6px 16px; border: 1.5px solid #e8e8e8;
            border-radius: 20px; font-size: 13px; font-weight: 600;
            cursor: pointer; background: #fff; color: #888;
            transition: 0.15s; text-decoration: none;
        }
        .filter-chip:hover { border-color: #e6a14c; color: #e6a14c; }
        .filter-chip.active { background: #e6a14c; color: #fff; border-color: #e6a14c; }
        .filter-sep {
            width: 1px; background: #e8e8e8; margin: 0 4px; align-self: stretch;
        }

        /* Post List (scrollable) */
        .post-list {
            flex: 1; overflow-y: auto; padding: 0 24px 20px;
            min-height: 0;
        }
        .post-list .post-card {
            margin-bottom: 20px;
        }
        .post-list .post-card:last-child {
            margin-bottom: 0;
        }
        .post-list::-webkit-scrollbar { width: 6px; }
        .post-list::-webkit-scrollbar-thumb { background: #ddd; border-radius: 3px; }

        /* ========== Post Card ========== */
        .post-card {
            background: #fff; border-radius: 14px; overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            transition: box-shadow 0.2s; cursor: pointer;
        }
        .post-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.08); }

        .post-header {
            display: flex; align-items: flex-start; padding: 16px 20px 0;
            gap: 12px;
        }
        .post-avatar {
            width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0;
            background: #fef3e6; display: flex; align-items: center;
            justify-content: center; font-size: 16px; font-weight: 800;
            color: #e6a14c;
        }
        .post-header-info { flex: 1; min-width: 0; }
        .post-username { font-size: 14px; font-weight: 700; color: #333; }
        .post-meta {
            font-size: 12px; color: #aaa; margin-top: 3px;
            display: flex; gap: 14px; align-items: center;
        }
        .post-meta span { display: flex; align-items: center; gap: 4px; }
        .post-report-btn {
            background: none; border: none; color: #ccc; cursor: pointer;
            font-size: 12px; padding: 2px 6px; transition: 0.15s;
        }
        .post-report-btn:hover { color: #e6a14c; }

        .post-body { padding: 12px 20px; }
        .post-title {
            font-size: 17px; font-weight: 800; color: #222;
            margin-bottom: 8px; line-height: 1.4;
        }
        .post-text {
            font-size: 14px; color: #555; line-height: 1.7;
            white-space: pre-wrap; word-break: break-word;
        }
        .post-image {
            margin-top: 10px; border-radius: 10px; overflow: hidden;
        }
        .post-image img {
            width: 100%; max-height: 400px; object-fit: scale-down;
            display: block; cursor: pointer; transition: 0.2s;
            background: #fafafa;
        }
        .post-image img:hover { opacity: 0.92; }

        .post-footer {
            display: flex; align-items: center; padding: 10px 20px 14px;
            gap: 20px; border-top: 1px solid #f5f5f5; margin: 0 20px;
        }
        .post-action {
            display: flex; align-items: center; gap: 5px;
            background: none; border: none; cursor: pointer;
            font-size: 13px; color: #999; padding: 4px 8px; border-radius: 6px;
            transition: 0.15s; font-family: inherit;
        }
        .post-action:hover { background: #f5f5f5; color: #e6a14c; }
        .post-action svg { width: 18px; height: 18px; }
        .post-footer-right { margin-left: auto; }

        .empty-state {
            text-align: center; padding: 60px 20px; color: #bbb;
            font-size: 15px;
        }

        /* ========== Detail View (overlays right-panel scroll area) ========== */
        .detail-view {
            display: none; flex: 1; overflow-y: auto; padding: 0 24px 20px;
            flex-direction: column;
            min-height: 0;
        }
        #detailContent {
            display: flex; flex-direction: column; gap: 20px;
        }
        .detail-view.active { display: flex; }
        .detail-view::-webkit-scrollbar { width: 6px; }
        .detail-view::-webkit-scrollbar-thumb { background: #ddd; border-radius: 3px; }

        .detail-back {
            display: inline-flex; align-items: center; gap: 6px;
            color: #999; font-size: 14px; font-weight: 600;
            cursor: pointer; border: none; background: none; padding: 0 0 12px 0;
            font-family: inherit; transition: 0.15s; flex-shrink: 0;
        }
        .detail-back:hover { color: #e6a14c; }

        .detail-card {
            background: #fff; border-radius: 14px; padding: 24px 28px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .detail-author {
            display: flex; align-items: center; gap: 12px; margin-bottom: 16px;
        }
        .detail-avatar {
            width: 44px; height: 44px; border-radius: 50%;
            background: #fef3e6; display: flex; align-items: center;
            justify-content: center; font-size: 18px; font-weight: 800;
            color: #e6a14c; flex-shrink: 0;
        }
        .detail-author-name { font-size: 15px; font-weight: 700; color: #333; }
        .detail-author-time { font-size: 12px; color: #aaa; margin-top: 2px; }
        .detail-title {
            font-size: 22px; font-weight: 800; color: #222;
            margin-bottom: 14px; line-height: 1.4;
        }
        .detail-content {
            font-size: 15px; color: #444; line-height: 1.9;
            white-space: pre-wrap; word-break: break-word; margin-bottom: 16px;
        }
        .detail-image {
            margin-bottom: 16px; border-radius: 10px; overflow: hidden;
            cursor: pointer;
        }
        .detail-image img {
            width: 100%; max-height: 500px; object-fit: contain;
            display: block; background: #fafafa; transition: 0.2s;
        }
        .detail-image img:hover { opacity: 0.9; }
        .detail-stats {
            display: flex; gap: 24px; padding-top: 16px;
            border-top: 1px solid #f0f0f0;
            font-size: 14px; color: #999;
        }
        .detail-stats span { display: flex; align-items: center; gap: 5px; }
        .detail-stats svg { width: 18px; height: 18px; }

        /* Comments */
        .comment-section {
            background: #fff; border-radius: 14px; padding: 20px 28px 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .comment-section h3 { font-size: 16px; font-weight: 700; color: #333; margin-bottom: 14px; }
        .comment-input-row {
            display: flex; gap: 10px; margin-bottom: 16px;
        }
        .comment-input-row textarea {
            flex: 1; padding: 10px 14px; border: 1.5px solid #e8e8e8;
            border-radius: 10px; font-size: 14px; outline: none; resize: vertical;
            font-family: inherit; background: #fafafa; min-height: 38px;
            transition: 0.15s;
        }
        .comment-input-row textarea:focus { border-color: #e6a14c; background: #fff; }
        .comment-send {
            padding: 10px 20px; background: #e6a14c; color: #fff;
            border: none; border-radius: 10px; cursor: pointer;
            font-size: 14px; font-weight: 700; font-family: inherit; transition: 0.15s;
            white-space: nowrap;
        }
        .comment-send:hover { background: #d48a2e; }
        .comment-sort {
            display: flex; gap: 8px; margin-bottom: 14px;
        }
        .comment-sort-btn {
            padding: 4px 14px; border-radius: 14px; font-size: 12px;
            font-weight: 600; cursor: pointer; border: 1.5px solid #e8e8e8;
            background: #fff; color: #999; font-family: inherit; transition: 0.15s;
        }
        .comment-sort-btn.active { background: #fef6ec; color: #e6a14c; border-color: #e6a14c; }
        .comment-sort-btn:hover:not(.active) { border-color: #ccc; }

        .comment-item {
            padding: 14px 0; border-bottom: 1px solid #f5f5f5;
        }
        .comment-item:last-child { border-bottom: none; }
        .comment-top {
            display: flex; align-items: center; gap: 10px; margin-bottom: 6px;
        }
        .comment-avatar {
            width: 32px; height: 32px; border-radius: 50%;
            background: #fef3e6; display: flex; align-items: center;
            justify-content: center; font-size: 13px; font-weight: 800;
            color: #e6a14c; flex-shrink: 0;
        }
        .comment-user { font-size: 13px; font-weight: 700; color: #333; }
        .comment-time { font-size: 11px; color: #bbb; margin-left: auto; }
        .comment-content { font-size: 14px; color: #444; line-height: 1.6; }
        .comment-actions {
            display: flex; gap: 14px; margin-top: 6px;
        }
        .comment-action {
            background: none; border: none; cursor: pointer;
            font-size: 12px; color: #bbb; padding: 2px 6px;
            display: flex; align-items: center; gap: 4px;
            font-family: inherit; transition: 0.15s;
        }
        .comment-action:hover { color: #e6a14c; }
        .comment-replies {
            margin-left: 24px; padding-left: 16px;
            border-left: 2px solid #f0f0f0;
            display: none;
        }
        .comment-replies.open { display: block; }
        .toggle-replies {
            background: none; border: none; cursor: pointer;
            font-size: 12px; color: #e6a14c; padding: 4px 0;
            font-family: inherit; font-weight: 600; transition: 0.15s;
        }
        .toggle-replies:hover { text-decoration: underline; }

        .comment-empty {
            text-align: center; color: #bbb; padding: 30px; font-size: 14px;
        }

        /* ========== Lightbox ========== */
        .lightbox {
            display: none; position: fixed; top: 0; left: 0;
            width: 100%; height: 100%; background: rgba(0,0,0,0.85);
            z-index: 999; justify-content: center; align-items: center;
            cursor: pointer;
        }
        .lightbox.show { display: flex; }
        .lightbox img {
            max-width: 90vw; max-height: 90vh; object-fit: contain;
            border-radius: 6px; box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }

        /* ========== Responsive ========== */
        @media (max-width: 900px) {
            .sidebar { flex: 1; min-width: 160px; max-width: 300px; background: rgba(255,250,243,0.7); }
            .post-list, .detail-view { padding: 16px; }
            .detail-card, .comment-section { padding: 16px 18px; }
        }
        @media (max-width: 680px) {
            .main-layout { flex-direction: column; }
            .sidebar {
                width: 100%; min-width: 100%; max-height: 180px;
                flex-shrink: 0; border-right: none; border-bottom: 1px solid #eee;
            }
            .sidebar-nav { flex-direction: row; flex-wrap: wrap; padding: 10px; gap: 6px; }
            .sidebar-btn { width: auto; padding: 8px 14px; font-size: 13px; }
            .sidebar-cats { display: none; }
            .right-panel { height: 0; flex: 1; }
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <div class="nav-logo">&#x1f43e; 校园流浪猫</div>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/pages/home.jsp">&#x1f3e0; 首页</a>
        <a href="<%= request.getContextPath() %>/myAdoptions">&#x1f4cb; 我的领养</a>
        <a href="<%= request.getContextPath() %>/forumList" class="active">&#x1f4ac; 论坛</a>
        <a href="<%= request.getContextPath() %>/knowledgeList">&#x1f4d6; 知识科普</a>
        <a href="<%= request.getContextPath() %>/pages/feeding.jsp">&#x1f37c; 在线喂养</a>
        <a href="<%= request.getContextPath() %>/pages/user_center.jsp">&#x1f464; 个人中心</a>
    </div>
    <div class="user-badge">
        &#x1f431; <%= sessionUser.getUsername() %>
        <button class="logout-btn" onclick="logout()">退出登录</button>
    </div>
</nav>

<!-- Main Layout -->
<div class="main-layout">

    <!-- ====== Left Sidebar ====== -->
    <aside class="sidebar">
        <div class="sidebar-nav">
            <a href="?my=1" class="sidebar-btn">
                <span class="btn-icon">&#x1f464;</span> 我的
            </a>
            <a href="<%= request.getContextPath() %>/forumPost" class="sidebar-btn primary">&#x2795; 发布帖子</a>
        </div>

        <div class="sidebar-cats">
            <div class="sidebar-label">校园猫咪</div>
            <% if (cats != null) {
                for (Cat cat : cats) {
                    String catImg = cat.getImagePath();
                    if (catImg == null || catImg.isEmpty()) catImg = "images/cats/cat1.jpg";
            %>
            <a href="?catId=<%= cat.getId() %>&sort=<%= currentSort %>" class="cat-btn">
                <div class="cat-avatar" style="background-image:url('<%= request.getContextPath() %>/<%= catImg %>')"></div>
                <span class="cat-name"><%= cat.getName() %>家</span>
            </a>
            <% }} %>
        </div>
    </aside>

    <!-- ====== Right Panel ====== -->
    <div class="right-panel" id="rightPanel">

        <!-- Search + Filter (fixed) -->
        <form class="search-area" action="<%= request.getContextPath() %>/forumList" method="get" onsubmit="return doSearchForm(this)">
            <div class="search-row">
                <input type="hidden" name="category" value="<%= request.getAttribute("currentCategory") != null ? request.getAttribute("currentCategory") : "" %>"><input type="hidden" name="sort" value="<%= request.getAttribute("currentSort") != null ? request.getAttribute("currentSort") : "latest" %>"><input type="text" class="search-input" id="searchInput" name="keyword" placeholder="搜索帖子..." value="<%= request.getAttribute("currentKeyword") != null ? request.getAttribute("currentKeyword") : "" %>" onkeydown="if(event.key==='Enter')this.form.submit()">
                <button class="search-btn" type="submit">搜索</button>
            </div>
            <div class="filter-row">
                <a href="?sort=<%= currentSort %>" class="filter-chip <%= "".equals(currentCategory) ? "active" : "" %>">全部</a>
                <a href="?category=猫咪日常&sort=<%= currentSort %>" class="filter-chip <%= "猫咪日常".equals(currentCategory) ? "active" : "" %>">猫咪日常</a>
                <a href="?category=救助求助&sort=<%= currentSort %>" class="filter-chip <%= "救助求助".equals(currentCategory) ? "active" : "" %>">救助求助</a>
                <a href="?category=领养分享&sort=<%= currentSort %>" class="filter-chip <%= "领养分享".equals(currentCategory) ? "active" : "" %>">领养分享</a>
                <a href="?category=闲聊交流&sort=<%= currentSort %>" class="filter-chip <%= "闲聊交流".equals(currentCategory) ? "active" : "" %>">闲聊交流</a>
                <span class="filter-sep"></span>
                <a href="?category=<%= currentCategory %>&sort=latest" class="filter-chip <%= "latest".equals(currentSort) ? "active" : "" %>">最新</a>
                <a href="?category=<%= currentCategory %>&sort=hot" class="filter-chip <%= "hot".equals(currentSort) ? "active" : "" %>">最热</a>
            </div>
        </form>

        <!-- Post List (scrollable) -->
        <div class="post-list" id="postList">
            <% if (threads == null || threads.isEmpty()) { %>
            <div class="empty-state">还没有帖子，快来发布第一个吧</div>
            <% } else {
                for (ForumThread t : threads) {
                    boolean hasImg = t.getImagePath() != null && !t.getImagePath().isEmpty();
            %>
            <div class="post-card" data-id="<%= t.getId() %>" onclick="openDetail(<%= t.getId() %>)">
                <div class="post-header">
                    <div class="post-avatar"><%= t.getUserId() != null && t.getUserId().length() > 0 ? t.getUserId().substring(0, 1) : "?" %></div>
                    <div class="post-header-info">
                        <div class="post-username"><%= t.getUserId() %></div>
                        <div class="post-meta">
                            <span>&#x2764; <%= t.getLikeCount() %></span>
                            <span>&#x1f4ac; <%= t.getCommentCount() %></span>
                            <button class="post-report-btn" onclick="event.stopPropagation();reportPost(<%= t.getId() %>)">&#x26a0; 举报</button>
                        </div>
                    </div>
                </div>
                <div class="post-body">
                    <div class="post-title"><%= t.getTitle() %></div>
                    <div class="post-text"><%= t.getContent() %></div>
                    <% if (hasImg) { %>
                    <div class="post-image" onclick="event.stopPropagation();openLightbox('<%= request.getContextPath() %>/<%= t.getImagePath() %>')">
                        <img src="<%= request.getContextPath() %>/<%= t.getImagePath() %>" alt="<%= t.getTitle() %>" loading="lazy" onerror="this.parentElement.style.display='none'">
                    </div>
                    <% } %>
                </div>
                <div class="post-footer">
                    <button class="post-action" onclick="event.stopPropagation();openDetail(<%= t.getId() %>);focusComment()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                        <%= t.getCommentCount() %>
                    </button>
                    <button class="post-action" onclick="event.stopPropagation();toggleLikeCard(this, <%= t.getId() %>)">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                        <span><%= t.getLikeCount() %></span>
                    </button>
                    <button class="post-action post-footer-right" onclick="event.stopPropagation();reportPost(<%= t.getId() %>)">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        举报
                    </button>
                </div>
            </div>
            <% }} %>
        </div>

        <!-- Detail View (hidden, overlays post list) -->
        <div class="detail-view" id="detailView">
            <button class="detail-back" onclick="closeDetail()">&#x2190; 返回列表</button>
            <div id="detailContent">
                <!-- Populated by JS via AJAX -->
                <div style="text-align:center;padding:40px;color:#ccc;">加载中...</div>
            </div>
        </div>

    </div>
</div>

<!-- Lightbox for image zoom -->
<div class="lightbox" id="lightbox" onclick="closeLightbox()">
    <img src="" alt="" id="lightboxImg">
</div>

<script>
    var ctx = '<%= request.getContextPath() %>';
    var currentThreadId = null;
    var replyToId = null;
    var currentCommentSort = 'latest';

    // ========== Search ==========
    function doSearchForm(form) {
        var kw = form.querySelector('input[name="keyword"]').value.trim();
        if (!kw) {
            // Remove keyword param, submit normally
            form.querySelector('input[name="keyword"]').name = '';
        }
        return true;
    }

    // ========== Detail View ==========
    function openDetail(id) {
        currentThreadId = id;
        replyToId = null;
        currentCommentSort = 'latest';
        document.getElementById('postList').style.display = 'none';
        document.getElementById('detailView').classList.add('active');
        document.getElementById('detailView').scrollTop = 0;
        loadDetail(id, 'latest');
    }

    function closeDetail() {
        document.getElementById('postList').style.display = '';
        document.getElementById('detailView').classList.remove('active');
        currentThreadId = null;
        replyToId = null;
    }

    function loadDetail(id, commentSort) {
        currentCommentSort = commentSort || 'latest';
        var dv = document.getElementById('detailView');
        var scrollTop = dv ? dv.scrollTop : 0;
        document.getElementById('detailContent').innerHTML = '<div style="text-align:center;padding:40px;color:#ccc;">加载中...</div>';
        fetch(ctx + '/forumDetail?id=' + id + '&ajax=1&commentSort=' + currentCommentSort)
            .then(function(r) { return r.text(); })
            .then(function(html) {
                document.getElementById('detailContent').innerHTML = html;
                detailLoaded();
                if (dv) dv.scrollTop = scrollTop;
            })
            .catch(function() {
                document.getElementById('detailContent').innerHTML = '<div style="text-align:center;padding:40px;color:#e6a14c;">加载失败</div>';
            });
    }

    function detailLoaded() {
        // Re-bind comment input Enter key
        var ci = document.getElementById('commentInput');
        if (ci) {
            ci.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
                    e.preventDefault();
                    submitComment();
                }
            });
            // Focus if requested
            if (window._focusComment) {
                ci.focus();
                window._focusComment = false;
            }
        }
    }

    function focusComment() {
        window._focusComment = true;
        setTimeout(function() {
            var el = document.getElementById('commentInput');
            if (el) el.focus();
        }, 300);
    }

    // ========== Like Post ==========
    function toggleLikeCard(btn, id) {
        fetch(ctx + '/forumLike', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + id
        }).then(function(r) { return r.json(); })
          .then(function(d) {
              var sp = btn.querySelector('span');
              if (sp) sp.textContent = d.count;
              var svg = btn.querySelector('svg');
              if (svg) {
                  svg.setAttribute('fill', svg.getAttribute('fill') === 'none' ? '#e6a14c' : 'none');
              }
          });
    }

    // ========== Like Post (Detail) ==========
    function toggleDetailLike(threadId) {
        var btn = document.getElementById("detailLikeBtn");
        if (!btn) return;
        btn.disabled = true;
        fetch(ctx + "/forumLike", {
            method: "POST",
            headers: {"Content-Type":"application/x-www-form-urlencoded"},
            body: "threadId=" + threadId
        }).then(function(r) { return r.json(); })
          .then(function(d) {
              var sp = document.getElementById("detailLikeCount");
              if (sp) sp.textContent = d.count;
              var svg = btn.querySelector("svg");
              if (svg) {
                  svg.setAttribute("fill", svg.getAttribute("fill") === "none" ? "#e6a14c" : "none");
              }
              btn.disabled = false;
          }).catch(function() { btn.disabled = false; });
    }

    // ========== Comment ==========
    function submitComment() {
        var input = document.getElementById('commentInput');
        if (!input || !input.value.trim() || !currentThreadId) return;
        var btn = document.querySelector('.comment-send');
        btn.disabled = true; btn.textContent = '发送中...';

        var body = 'threadId=' + currentThreadId + '&content=' + encodeURIComponent(input.value.trim());
        if (replyToId) body += '&parentId=' + replyToId;

        fetch(ctx + '/forumComment', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: body
        }).then(function(r) { return r.text(); })
          .then(function(msg) {
              if (msg === 'ok') {
                  input.value = '';
                  replyToId = null;
                  if (input.placeholder) input.placeholder = '写下你的评论...';
                  loadDetail(currentThreadId, currentCommentSort);
              } else {
                  alert(msg);
                  btn.disabled = false; btn.textContent = '发送';
              }
          }).catch(function() {
              btn.disabled = false; btn.textContent = '发送';
          });
    }

    function replyTo(commentId, username) {
        replyToId = commentId;
        var input = document.getElementById('commentInput');
        if (input) {
            input.placeholder = '回复 @' + username + '：';
            input.focus();
            input.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function toggleCommentLike(btn, commentId) {
        fetch(ctx + '/commentLike', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'commentId=' + commentId
        }).then(function(r) { return r.json(); })
          .then(function(d) {
              var sp = btn.querySelector('span');
              if (sp) sp.textContent = d.count;
          });
    }

    function toggleReplies(btn) {
        var replies = btn.nextElementSibling;
        if (replies && replies.classList.contains('comment-replies')) {
            var isOpen = replies.classList.toggle('open');
            var count = replies.querySelectorAll('.comment-item').length;
            btn.textContent = isOpen ? '收起回复' : '展开 ' + count + ' 条回复';
        }
    }

    // ========== Lightbox ==========
    function openLightbox(src) {
        document.getElementById('lightboxImg').src = src;
        document.getElementById('lightbox').classList.add('show');
        document.body.style.overflow = 'hidden';
    }
    function closeLightbox() {
        document.getElementById('lightbox').classList.remove('show');
        document.body.style.overflow = '';
    }

    // ========== Report ==========
    function reportPost(id) {
        var reason = prompt('请输入举报理由：');
        if (!reason || !reason.trim()) return;
        fetch(ctx + '/forumReport', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + id + '&reason=' + encodeURIComponent(reason.trim())
        }).then(function(r) { return r.text(); })
          .then(function(msg) {
              alert(msg === 'ok' ? '举报已提交' : msg);
          });
    }

    // ========== Utility ==========
    function logout() {
        if (confirm('确定要退出登录吗？')) window.location.href = ctx + '/logout';
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            if (document.getElementById('lightbox').classList.contains('show')) {
                closeLightbox();
            } else if (document.getElementById('detailView').classList.contains('active')) {
                closeDetail();
            }
        }
    });
</script>
</body>
</html>