
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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= thread.getTitle() %> - 论坛</title>
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
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        .card { background: white; border-radius: 20px; padding: 28px; margin-bottom: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.04); }
        .thread-header { margin-bottom: 18px; }
        .thread-header h1 { font-size: 22px; color: #3d3226; margin-bottom: 10px; }
        .thread-header .meta { font-size: 13px; color: #a69780; display: flex; gap: 18px; flex-wrap: wrap; }
        .cat-tag, .category-tag { display: inline-block; padding: 2px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .cat-tag { background: #fef3e6; color: #e6a14c; }
        .category-tag { background: #e8f5e9; color: #2e7d32; margin-left: 6px; }
        .thread-content { font-size: 15px; color: #4a3f32; line-height: 1.8; white-space: pre-wrap; word-break: break-all; margin-bottom: 20px; }
        .thread-image { max-width: 100%; border-radius: 12px; margin-bottom: 16px; }
        .thread-actions { display: flex; gap: 16px; align-items: center; padding-top: 16px; border-top: 1px solid #f0ebe0; }
        .action-btn { padding: 8px 18px; border-radius: 20px; border: 1.5px solid #e0d8cc; background: white; cursor: pointer; font-size: 14px; transition: 0.2s; color: #6b5e4a; font-family: "Microsoft YaHei", sans-serif; }
        .action-btn:hover { background: #faf7f2; }
        .action-btn.liked { border-color: #e6a14c; color: #e6a14c; background: #fef8f0; }
        .comments-section { margin-top: 10px; }
        .comments-section h3 { font-size: 17px; color: #3d3226; margin-bottom: 16px; }
        .comment-item { padding: 14px 0; border-bottom: 1px solid #f0ebe0; }
        .comment-item .comment-user { font-weight: 700; color: #b87c2c; font-size: 14px; margin-bottom: 4px; }
        .comment-item .comment-text { font-size: 14px; color: #4a3f32; }
        .comment-item .comment-time { font-size: 12px; color: #ccc; margin-top: 4px; }
        .comment-input-area { display: flex; gap: 10px; margin-top: 16px; }
        .comment-input-area textarea { flex: 1; padding: 10px 14px; border: 1.5px solid #e0d8cc; border-radius: 12px; font-size: 14px; font-family: "Microsoft YaHei", sans-serif; outline: none; resize: vertical; transition: 0.2s; }
        .comment-input-area textarea:focus { border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.1); }
        .btn { display: inline-block; padding: 10px 22px; border: none; border-radius: 14px; font-size: 14px; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: "Microsoft YaHei", sans-serif; }
        .btn-primary { background: #e6a14c; color: white; }
        .btn-primary:hover { background: #c97d2a; }
        .back-link { display: inline-block; margin-bottom: 16px; color: #b3904f; text-decoration: none; font-size: 14px; }
        .back-link:hover { color: #e6a14c; }
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.45); display: none; justify-content: center; align-items: center; z-index: 200; }
        .modal-overlay.show { display: flex; }
        .modal-box { background: white; border-radius: 16px; padding: 28px; width: 420px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); }
        .modal-box h3 { color: #3d3226; margin-bottom: 16px; }
        .modal-box textarea { width: 100%; padding: 10px; border: 1.5px solid #e0d8cc; border-radius: 10px; font-family: "Microsoft YaHei", sans-serif; resize: vertical; }
        .modal-box .modal-actions { display: flex; gap: 10px; margin-top: 14px; justify-content: flex-end; }
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
    <a href="<%= request.getContextPath() %>/forumList" class="back-link">返回论坛</a>

    <div class="card">
        <div class="thread-header">
            <h1><%= thread.getTitle() %></h1>
            <div class="meta">
                <span><strong><%= thread.getUserId() %></strong></span>
                <% if (thread.getCatName() != null && !thread.getCatName().isEmpty()) { %>
                <span class="cat-tag"><%= thread.getCatName() %></span>
                <% } %>
                <span class="category-tag"><%= thread.getCategory() %></span>
                <span><%= thread.getCreatedAt() != null ? thread.getCreatedAt().toString().substring(0, 16) : "" %></span>
                <span><%= thread.getViewCount() %> 浏览</span>
            </div>
        </div>

        <% if (thread.getImagePath() != null && !thread.getImagePath().isEmpty()) { %>
        <img src="<%= request.getContextPath() %>/<%= thread.getImagePath() %>" class="thread-image" alt="图片">
        <% } %>

        <div class="thread-content"><%= thread.getContent() %></div>

        <div class="thread-actions">
            <button class="action-btn <%= liked ? "liked" : "" %>" id="likeBtn" onclick="toggleLike()">
                <%= liked ? "已赞" : "点赞" %> (<span id="likeCount"><%= thread.getLikeCount() %></span>)
            </button>
            <button class="action-btn" onclick="showReport()">举报</button>
        </div>
    </div>

    <div class="card comments-section">
        <h3>评论 (<%= comments != null ? comments.size() : 0 %>)</h3>
        <% if (comments != null && !comments.isEmpty()) {
            for (ForumComment c : comments) { %>
        <div class="comment-item">
            <div class="comment-user"><%= c.getUserId() %></div>
            <div class="comment-text"><%= c.getContent() %></div>
            <div class="comment-time"><%= c.getCreatedAt() != null ? c.getCreatedAt().toString().substring(0, 16) : "" %></div>
        </div>
        <% }} else { %>
        <div style="color:#ccc;text-align:center;padding:30px;">暂无评论，来说两句吧</div>
        <% } %>

        <div class="comment-input-area">
            <textarea id="commentInput" rows="2" placeholder="写下你的评论..."></textarea>
            <button class="btn btn-primary" onclick="submitComment()">发送</button>
        </div>
    </div>
</div>

<div class="modal-overlay" id="reportModal">
    <div class="modal-box">
        <h3>举报帖子</h3>
        <textarea id="reportReason" rows="3" placeholder="请描述举报理由..."></textarea>
        <div class="modal-actions">
            <button class="action-btn" onclick="closeReport()">取消</button>
            <button class="btn btn-primary" onclick="submitReport()">提交举报</button>
        </div>
    </div>
</div>

<script>
    var ctx = '<%= request.getContextPath() %>';
    var threadId = <%= thread.getId() %>;

    function toggleLike() {
        fetch(ctx + '/forumLike', {
            method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + threadId
        }).then(function(r) { return r.json(); })
          .then(function(d) {
              document.getElementById('likeCount').textContent = d.count;
              var btn = document.getElementById('likeBtn');
              if (btn.classList.contains('liked')) {
                  btn.classList.remove('liked');
                  btn.innerHTML = '点赞 (' + d.count + ')';
              } else {
                  btn.classList.add('liked');
                  btn.innerHTML = '已赞 (' + d.count + ')';
              }
          });
    }

    function submitComment() {
        var input = document.getElementById('commentInput');
        var txt = input.value.trim();
        if (!txt) return;
        fetch(ctx + '/forumComment', {
            method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + threadId + '&content=' + encodeURIComponent(txt)
        }).then(function(r) { return r.text(); })
          .then(function(msg) {
              if (msg === 'ok') location.reload();
              else alert(msg);
          });
    }

    function showReport() {
        document.getElementById('reportModal').classList.add('show');
    }
    function closeReport() {
        document.getElementById('reportModal').classList.remove('show');
    }
    function submitReport() {
        var reason = document.getElementById('reportReason').value.trim();
        if (!reason) { alert('请填写举报理由'); return; }
        fetch(ctx + '/forumReport', {
            method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'threadId=' + threadId + '&reason=' + encodeURIComponent(reason)
        }).then(function(r) { return r.text(); })
          .then(function(msg) {
              if (msg === 'ok') { alert('举报已提交'); closeReport(); }
              else alert(msg);
          });
    }

    function logout() {
        if (confirm('确定要退出登录吗？')) window.location.href = ctx + '/logout';
    }
</script>
</body>
</html>