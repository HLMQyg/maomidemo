<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.model.ForumThread" %>
<%@ page import="com.example.maomi.model.ForumComment" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    ForumThread thread = (ForumThread) request.getAttribute("thread");
    List<ForumComment> comments = (List<ForumComment>) request.getAttribute("comments");
    Boolean liked = (Boolean) request.getAttribute("liked");
    if (liked == null) liked = false;
    if (thread == null) {
        response.sendRedirect(request.getContextPath() + "/forumList");
        return;
    }
    boolean hasImage = thread.getImagePath() != null && !thread.getImagePath().isEmpty();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= thread.getTitle() %> - 论坛 - 校园流浪猫管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #f7f3ed;
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            position: relative; min-height: 100vh;
        }
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: url('../images/login-bg.jpg') center/cover no-repeat;
            opacity: 0.06; z-index: -1; pointer-events: none;
        }
        .navbar {
            background: rgba(255,250,240,0.94); backdrop-filter: blur(14px);
            box-shadow: 0 2px 20px rgba(0,0,0,0.05); padding: 12px 30px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
        }
        .nav-logo { font-size: 22px; font-weight: 700; color: #b87c2c; letter-spacing: 1px; }
        .nav-links { display: flex; gap: 24px; }
        .nav-links a {
            text-decoration: none; color: #a66a1a; font-weight: 600;
            padding: 6px 14px; border-radius: 20px; transition: 0.2s; font-size: 15px;
        }
        .nav-links a:hover, .nav-links a.active { background: #ffeed9; color: #8b5a10; }
        .user-badge { display: flex; align-items: center; gap: 8px; color: #8b5a10; font-weight: 600; }
        .logout-btn {
            background: none; border: 1px solid #e6a14c; color: #e6a14c;
            padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600;
            transition: 0.2s; margin-left: 15px;
        }
        .logout-btn:hover { background: #e6a14c; color: white; }

        .hero-image {
            width: 100%; max-height: 70vh; overflow: hidden;
            background: linear-gradient(135deg, #fef6ed, #f5e6d0);
            display: flex; align-items: center; justify-content: center;
        }
        .hero-image img {
            width: 100%; max-height: 70vh; object-fit: contain; display: block;
        }
        .hero-placeholder {
            width: 100%; height: 240px;
            background: linear-gradient(160deg, #fef6ed, #f5e6d0);
            display: flex; align-items: center; justify-content: center;
            font-size: 64px; color: #d4b896;
        }

        .container {
            max-width: 780px; margin: 0 auto; padding: 0 20px 130px;
        }

        .back-link {
            display: inline-flex; align-items: center; gap: 6px;
            color: #b3904f; text-decoration: none; font-size: 15px; font-weight: 600;
            padding: 16px 0 8px; transition: 0.2s;
        }
        .back-link:hover { color: #e6a14c; }

        .content-card {
            background: white; border-radius: 18px; padding: 28px 30px;
            margin-bottom: 16px; box-shadow: 0 3px 12px rgba(0,0,0,0.04);
        }
        .content-card h1 {
            font-size: 24px; color: #3d3226; font-weight: 800;
            line-height: 1.4; margin-bottom: 14px;
        }
        .meta-row {
            display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
            font-size: 14px; color: #a69780; margin-bottom: 18px;
            padding-bottom: 16px; border-bottom: 1px solid #f2ede3;
        }
        .meta-row .author {
            display: flex; align-items: center; gap: 8px; font-weight: 700; color: #6b5e4a;
        }
        .meta-row .avatar {
            width: 32px; height: 32px; border-radius: 50%;
            background: #fef3e6; display: flex; align-items: center; justify-content: center;
            font-size: 14px; color: #e6a14c; font-weight: 700;
        }
        .tag {
            display: inline-block; padding: 2px 12px; border-radius: 12px;
            font-size: 12px; font-weight: 600; background: #fef3e6; color: #c48a3c;
        }

        .thread-content {
            font-size: 16px; color: #4a3f32; line-height: 1.9;
            white-space: pre-wrap; word-break: break-word;
        }

        .stats-row {
            display: flex; gap: 28px; padding-top: 18px; margin-top: 16px;
            border-top: 1px solid #f2ede3; font-size: 14px; color: #a69780;
        }
        .stat-item { display: flex; align-items: center; gap: 6px; }
        .stat-item svg { width: 18px; height: 18px; }

        .comment-card {
            background: white; border-radius: 18px; padding: 24px 30px;
            box-shadow: 0 3px 12px rgba(0,0,0,0.04);
        }
        .comment-card h3 {
            font-size: 18px; color: #3d3226; font-weight: 700; margin-bottom: 18px;
        }
        .comment-item {
            padding: 14px 0; border-bottom: 1px solid #f2ede3;
        }
        .comment-item:last-child { border-bottom: none; }
        .comment-author { font-weight: 700; color: #b87c2c; font-size: 14px; margin-bottom: 4px; }
        .comment-text { font-size: 15px; color: #4a3f32; line-height: 1.6; }
        .comment-time { font-size: 12px; color: #c4b4a0; margin-top: 4px; }
        .comment-empty { text-align: center; color: #c4b4a0; padding: 30px; font-size: 15px; }

        .comment-input-wrap { display: flex; gap: 10px; margin-top: 18px; }
        .comment-input-wrap textarea {
            flex: 1; padding: 12px 16px; border: 1.5px solid #e0d8cc;
            border-radius: 14px; font-size: 14px; font-family: "Microsoft YaHei", sans-serif;
            outline: none; resize: vertical; transition: 0.2s; background: #fdfaf5;
        }
        .comment-input-wrap textarea:focus {
            border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.1);
        }
        .btn {
            display: inline-block; padding: 10px 22px; border: none; border-radius: 14px;
            font-size: 14px; font-weight: 700; cursor: pointer; transition: 0.2s;
            font-family: "Microsoft YaHei", sans-serif; text-decoration: none;
        }
        .btn-primary { background: #e6a14c; color: white; }
        .btn-primary:hover { background: #d48a2e; }
        .btn-outline {
            background: white; border: 1.5px solid #e0d8cc; color: #6b5e4a;
        }
        .btn-outline:hover { background: #faf7f2; }

        .bottom-bar {
            position: fixed; bottom: 0; left: 0; right: 0;
            background: white; border-top: 1px solid #ede6da;
            padding: 12px 20px;
            display: flex; align-items: center; gap: 14px;
            z-index: 99; box-shadow: 0 -2px 12px rgba(0,0,0,0.04);
        }
        .bottom-bar .comment-hint {
            flex: 1; padding: 10px 16px;
            background: #f7f3ed; border-radius: 24px;
            font-size: 14px; color: #b4a68e; cursor: pointer;
            transition: 0.2s;
        }
        .bottom-bar .comment-hint:hover { background: #ede6da; }
        .action-btn {
            display: flex; align-items: center; gap: 5px;
            padding: 8px 14px; border-radius: 20px; border: none;
            background: transparent; cursor: pointer; font-size: 14px;
            color: #6b5e4a; font-family: "Microsoft YaHei", sans-serif;
            transition: 0.2s;
        }
        .action-btn:hover { background: #faf5ec; }
        .action-btn.liked { color: #e6a14c; }
        .action-btn svg { width: 20px; height: 20px; }

        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.45); display: none; justify-content: center;
            align-items: center; z-index: 200;
        }
        .modal-overlay.show { display: flex; }
        .modal-box {
            background: white; border-radius: 16px; padding: 28px; width: 420px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }
        .modal-box h3 { color: #3d3226; margin-bottom: 16px; font-size: 18px; }
        .modal-box textarea {
            width: 100%; padding: 12px; border: 1.5px solid #e0d8cc; border-radius: 10px;
            font-family: "Microsoft YaHei", sans-serif; resize: vertical; font-size: 14px;
        }
        .modal-actions { display: flex; gap: 10px; margin-top: 14px; justify-content: flex-end; }
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

<% if (hasImage) { %>
<div class="hero-image">
    <img src="<%= request.getContextPath() %>/<%= thread.getImagePath() %>" alt="<%= thread.getTitle() %>" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
    <div class="hero-placeholder" style="display:none;">&#x1f431;</div>
</div>
<% } else { %>
<div class="hero-placeholder">&#x1f431;</div>
<% } %>

<div class="container">
    <a href="<%= request.getContextPath() %>/forumList" class="back-link">&#x2190; 返回论坛</a>

    <div class="content-card">
        <h1><%= thread.getTitle() %></h1>
        <div class="meta-row">
            <span class="author">
                <span class="avatar"><%= thread.getUserId().substring(0, 1) %></span>
                <%= thread.getUserId() %>
            </span>
            <% if (thread.getCatName() != null && !thread.getCatName().isEmpty()) { %>
            <span class="tag"><%= thread.getCatName() %></span>
            <% } %>
            <span class="tag"><%= thread.getCategory() != null ? thread.getCategory() : "" %></span>
            <span><%= thread.getCreatedAt() != null ? thread.getCreatedAt().toString().substring(0, 16) : "" %></span>
        </div>
        <div class="thread-content"><%= thread.getContent() %></div>
        <div class="stats-row">
            <span class="stat-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                <span id="likeCount"><%= thread.getLikeCount() %></span> 赞
            </span>
            <span class="stat-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                <%= comments != null ? comments.size() : 0 %> 评论
            </span>
            <span class="stat-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                <%= thread.getViewCount() %> 浏览
            </span>
        </div>
    </div>

    <div class="comment-card" id="commentSection">
        <h3>评论 (<%= comments != null ? comments.size() : 0 %>)</h3>
        <% if (comments != null && !comments.isEmpty()) {
            for (ForumComment c : comments) { %>
        <div class="comment-item">
            <div class="comment-author"><%= c.getUserId() %></div>
            <div class="comment-text"><%= c.getContent() %></div>
            <div class="comment-time"><%= c.getCreatedAt() != null ? c.getCreatedAt().toString().substring(0, 16) : "" %></div>
        </div>
        <% }} else { %>
        <div class="comment-empty">还没有评论，来说两句吧</div>
        <% } %>
        <div class="comment-input-wrap">
            <textarea id="commentInput" rows="2" placeholder="写下你的评论..."></textarea>
            <button class="btn btn-primary" onclick="submitComment()">发送</button>
        </div>
    </div>
</div>

<div class="bottom-bar">
    <div class="comment-hint" onclick="focusComment()">说点什么...</div>
    <button class="action-btn <%= liked ? "liked" : "" %>" id="likeBtn" onclick="toggleLike()">
        <svg viewBox="0 0 24 24" fill="<%= liked ? "#e6a14c" : "none" %>" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
        <span id="bottomLikeCount"><%= thread.getLikeCount() %></span>
    </button>
    <button class="action-btn" onclick="focusComment()">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
    </button>
    <button class="action-btn" onclick="showReport()">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    </button>
</div>

<div class="modal-overlay" id="reportModal">
    <div class="modal-box">
        <h3>举报帖子</h3>
        <textarea id="reportReason" rows="3" placeholder="请描述举报理由..."></textarea>
        <div class="modal-actions">
            <button class="btn btn-outline" onclick="closeReport()">取消</button>
            <button class="btn btn-primary" onclick="submitReport()">提交举报</button>
        </div>
    </div>
</div>

<script>
    var ctx ='<%= request.getContextPath() %>';
    var threadId = <%= thread.getId() %>;
    var liking = false;

    function toggleLike() {
        if (liking) return;
        liking = true;
        fetch(ctx + '/forumLike', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + threadId
        }).then(function(r) { return r.json(); })
          .then(function(d) {
              document.getElementById('likeCount').textContent = d.count;
              document.getElementById('bottomLikeCount').textContent = d.count;
              var btn = document.getElementById('likeBtn');
              var svg = btn.querySelector('svg');
              if (btn.classList.contains('liked')) {
                  btn.classList.remove('liked');
                  if (svg) svg.setAttribute('fill', 'none');
              } else {
                  btn.classList.add('liked');
                  if (svg) svg.setAttribute('fill', '#e6a14c');
              }
              liking = false;
          }).catch(function() {
              liking = false;
          });
    }

    function submitComment() {
        var input = document.getElementById('commentInput');
        var txt = input.value.trim();
        if (!txt) return;
        var btn = document.querySelector('.comment-input-wrap .btn');
        btn.disabled = true;
        btn.textContent = '发送中...';
        fetch(ctx + '/forumComment', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + threadId + '&content=' + encodeURIComponent(txt)
        }).then(function(r) { return r.text(); })
          .then(function(msg) {
              if (msg === 'ok') location.reload();
              else { alert(msg); btn.disabled = false; btn.textContent = '发送'; }
          }).catch(function() {
              btn.disabled = false;
              btn.textContent = '发送';
          });
    }

    function focusComment() {
        var el = document.getElementById('commentInput');
        el.focus();
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    document.getElementById('commentInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
            e.preventDefault();
            submitComment();
        }
    });

    function showReport() {
        document.getElementById('reportModal').classList.add('show');
    }
    function closeReport() {
        document.getElementById('reportModal').classList.remove('show');
    }
    function submitReport() {
        var reason = document.getElementById('reportReason').value.trim();
        if (!reason) { alert('请填写举报理由'); return; }
        var btn = document.querySelector('#reportModal .btn-primary');
        btn.disabled = true;
        fetch(ctx + '/forumReport', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + threadId + '&reason=' + encodeURIComponent(reason)
        }).then(function(r) { return r.text(); })
          .then(function(msg) {
              if (msg === 'ok') { alert('举报已提交'); closeReport(); }
              else alert(msg);
              btn.disabled = false;
          }).catch(function() {
              btn.disabled = false;
          });
    }

    function logout() {
        if (confirm('确定要退出登录吗？')) window.location.href = ctx + '/logout';
    }
</script>
</body>
</html>