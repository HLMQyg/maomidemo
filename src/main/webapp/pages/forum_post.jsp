
<%@ page import="com.example.maomi.model.User" %>
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
    CatDAO catDAO = new CatDAO();
    List<Cat> cats = catDAO.getAllCats();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>发布帖子 - 论坛</title>
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
        .nav-links a:hover { background: #ffeed9; color: #8b5a10; }
        .user-badge { display: flex; align-items: center; gap: 8px; color: #8b5a10; font-weight: 600; }
        .logout-btn { background: none; border: 1px solid #e6a14c; color: #e6a14c; padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600; transition: 0.2s; margin-left: 15px; }
        .logout-btn:hover { background: #e6a14c; color: white; }
        .container { max-width: 750px; margin: 0 auto; padding: 20px; }
        .card { background: white; border-radius: 20px; padding: 28px; box-shadow: 0 4px 12px rgba(0,0,0,0.04); }
        .card h1 { font-size: 22px; color: #6f4518; margin-bottom: 22px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-size: 14px; color: #6b5e4a; font-weight: 600; margin-bottom: 6px; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 10px 14px; border: 1.5px solid #e0d8cc;
            border-radius: 10px; font-size: 14px; font-family: "Microsoft YaHei", sans-serif;
            outline: none; transition: 0.2s; resize: vertical;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.1);
        }
        .btn { display: inline-block; padding: 10px 28px; border: none; border-radius: 14px; font-size: 14px; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: "Microsoft YaHei", sans-serif; }
        .btn-primary { background: #e6a14c; color: white; }
        .btn-primary:hover { background: #c97d2a; }
        .cat-tags { display: flex; flex-wrap: wrap; gap: 8px; }
        .cat-chip {
            padding: 6px 14px; border-radius: 20px; border: 1.5px solid #f0d9b5;
            cursor: pointer; font-size: 13px; transition: 0.2s; background: white; color: #b3904f;
        }
        .cat-chip:hover { background: #fff3dc; }
        .cat-chip.selected { background: #e6a14c; color: white; border-color: #e6a14c; }
        .image-preview { margin-top: 10px; }
        .image-preview img { max-width: 200px; max-height: 150px; border-radius: 10px; }
        .back-link { display: inline-block; margin-bottom: 16px; color: #b3904f; text-decoration: none; font-size: 14px; }
        .back-link:hover { color: #e6a14c; }
        .error-msg { color: #c1121f; text-align: center; margin-top: 10px; }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="nav-logo">校园流浪猫</div>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/pages/home.jsp">首页</a>
        <a href="<%= request.getContextPath() %>/myAdoptions">我的领养</a>
        <a href="<%= request.getContextPath() %>/forumList">论坛</a>
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
        <h1>发布帖子</h1>
        <form action="<%= request.getContextPath() %>/forumPost" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label>标题</label>
                <input type="text" name="title" required placeholder="输入帖子标题">
            </div>

            <div class="form-group">
                <label>分类</label>
                <select name="category">
                    <option value="猫咪日常">猫咪日常</option>
                    <option value="救助求助">救助求助</option>
                    <option value="领养分享">领养分享</option>
                    <option value="闲聊交流">闲聊交流</option>
                </select>
            </div>

            <div class="form-group">
                <label>关联猫咪（可选，点击选中）</label>
                <div class="cat-tags">
                    <% for (Cat cat : cats) { %>
                    <span class="cat-chip" data-catid="<%= cat.getId() %>" onclick="selectCat(this)"><%= cat.getName() %></span>
                    <% } %>
                </div>
                <input type="hidden" name="catId" id="catIdInput" value="">
            </div>

            <div class="form-group">
                <label>内容</label>
                <textarea name="content" rows="8" required placeholder="写下你想说的..."></textarea>
            </div>

            <div class="form-group">
                <label>图片（可选）</label>
                <input type="file" name="image" accept="image/*" onchange="previewImage(this)">
                <div class="image-preview" id="imagePreview"></div>
            </div>

            <% if (request.getAttribute("msg") != null) { %>
            <div class="error-msg"><%= request.getAttribute("msg") %></div>
            <% } %>

            <button type="submit" class="btn btn-primary" style="width:100%;margin-top:8px;">发布</button>
        </form>
    </div>
</div>

<script>
    function selectCat(el) {
        var selected = el.classList.contains('selected');
        document.querySelectorAll('.cat-chip').forEach(function(c) { c.classList.remove('selected'); });
        if (selected) {
            document.getElementById('catIdInput').value = '';
        } else {
            el.classList.add('selected');
            document.getElementById('catIdInput').value = el.getAttribute('data-catid');
        }
    }
    function previewImage(input) {
        var preview = document.getElementById('imagePreview');
        preview.innerHTML = '';
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                preview.innerHTML = '<img src="' + e.target.result + '" alt="">';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }
    function logout() {
        if (confirm('确定要退出登录吗？')) window.location.href = '<%= request.getContextPath() %>/logout';
    }
</script>
</body>
</html>