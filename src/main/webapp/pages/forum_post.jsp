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
    <title>发布帖子 - 论坛 - 校园流浪猫管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #f7f3ed;
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            position: relative; min-height: 100vh;
        }
        body::before {
            content: "";
            position: fixed; top: 0; left: 0;
            width: 100%; height: 100%;
            background: url('../images/login-bg.jpg') center/cover no-repeat;
            opacity: 0.08; z-index: -1; pointer-events: none;
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
        .nav-links a:hover { background: #ffeed9; color: #8b5a10; }
        .user-badge { display: flex; align-items: center; gap: 8px; color: #8b5a10; font-weight: 600; }
        .logout-btn {
            background: none; border: 1px solid #e6a14c; color: #e6a14c;
            padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600;
            transition: 0.2s; margin-left: 15px;
        }
        .logout-btn:hover { background: #e6a14c; color: white; }

        .container { max-width: 720px; margin: 0 auto; padding: 20px 20px 60px; }
        .card {
            background: white; border-radius: 18px; padding: 28px 30px;
            box-shadow: 0 3px 12px rgba(0,0,0,0.04);
        }
        .card h1 { font-size: 22px; color: #6f4518; font-weight: 800; margin-bottom: 22px; }
        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block; font-size: 14px; color: #6b5e4a; font-weight: 600; margin-bottom: 6px;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 11px 16px; border: 1.5px solid #e0d8cc;
            border-radius: 12px; font-size: 14px; font-family: "Microsoft YaHei", sans-serif;
            outline: none; transition: 0.2s; resize: vertical; background: #fdfaf5;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.1);
            background: white;
        }
        .btn {
            display: inline-block; padding: 11px 28px; border: none; border-radius: 14px;
            font-size: 15px; font-weight: 700; cursor: pointer; transition: 0.2s;
            font-family: "Microsoft YaHei", sans-serif; text-decoration: none;
        }
        .btn-primary { background: #e6a14c; color: white; box-shadow: 0 4px 12px rgba(230,161,76,0.2); }
        .btn-primary:hover { background: #d48a2e; }
        .btn-outline {
            background: white; border: 1.5px solid #e0d8cc; color: #6b5e4a;
        }
        .btn-outline:hover { background: #faf7f2; }
        .cat-tags { display: flex; flex-wrap: wrap; gap: 8px; }
        .cat-chip {
            padding: 7px 16px; border-radius: 20px; border: 1.5px solid #e8d8b8;
            cursor: pointer; font-size: 14px; transition: 0.2s; background: white; color: #b3904f;
            font-weight: 600;
        }
        .cat-chip:hover { background: #fff8ee; border-color: #e6a14c; }
        .cat-chip.selected { background: #e6a14c; color: white; border-color: #e6a14c; }
        .image-upload-area {
            border: 2px dashed #e0d8cc; border-radius: 14px; padding: 20px;
            text-align: center; cursor: pointer; transition: 0.2s; background: #fdfaf5;
        }
        .image-upload-area:hover { border-color: #e6a14c; background: #fff8ee; }
        .image-upload-area .upload-hint { color: #b4a68e; font-size: 14px; }
        .image-upload-area input[type=file] { display: none; }
        .image-preview { margin-top: 12px; }
        .image-preview img { max-width: 100%; max-height: 300px; border-radius: 12px; display: block; }
        .image-preview .preview-actions { margin-top: 8px; display: flex; gap: 8px; }
        .back-link {
            display: inline-flex; align-items: center; gap: 6px;
            color: #b3904f; text-decoration: none; font-size: 15px; font-weight: 600;
            margin-bottom: 14px; transition: 0.2s;
        }
        .back-link:hover { color: #e6a14c; }
        .error-msg { color: #c1121f; text-align: center; margin-top: 12px; font-size: 14px; }
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
    <a href="<%= request.getContextPath() %>/forumList" class="back-link">&#x2190; 返回论坛</a>

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
                <textarea name="content" rows="10" required placeholder="写下你想说的..."></textarea>
            </div>

            <div class="form-group">
                <label>图片（可选）</label>
                <label class="image-upload-area" id="uploadArea">
                    <input type="file" name="image" accept="image/*" onchange="previewImage(this)" id="fileInput">
                    <span class="upload-hint" id="uploadHint">点击选择图片，或拖拽到此处</span>
                </label>
                <div class="image-preview" id="imagePreview"></div>
            </div>

            <% if (request.getAttribute("msg") != null) { %>
            <div class="error-msg"><%= request.getAttribute("msg") %></div>
            <% } %>

            <button type="submit" class="btn btn-primary" id="submitBtn" style="width:100%;margin-top:8px;padding:14px;">发布</button>
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
        if (input.files && input.files[0]) {
            if (input.files[0].size > 10 * 1024 * 1024) {
                alert('图片大小不能超过10MB');
                input.value = '';
                return;
            }
            var reader = new FileReader();
            reader.onload = function(e) {
                preview.innerHTML = ''
                  + '<img src="' + e.target.result + '" alt="">'
                  + '<div class="preview-actions">'
                  + '<button type="button" class="btn btn-outline" style="font-size:13px;padding:6px 14px;" onclick="clearImage()">移除图片</button>'
                  + '</div>';
                document.getElementById('uploadHint').textContent = '点击更换图片';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    function clearImage() {
        document.getElementById('fileInput').value = '';
        document.getElementById('imagePreview').innerHTML = '';
        document.getElementById('uploadHint').textContent = '点击选择图片，或拖拽到此处';
    }

    // Drag and drop support
    var uploadArea = document.getElementById('uploadArea');
    ['dragenter','dragover','dragleave','drop'].forEach(function(name) {
        uploadArea.addEventListener(name, function(e) { e.preventDefault(); e.stopPropagation(); });
    });
    ['dragenter','dragover'].forEach(function(name) {
        uploadArea.addEventListener(name, function() { uploadArea.style.borderColor = '#e6a14c'; });
    });
    ['dragleave','drop'].forEach(function(name) {
        uploadArea.addEventListener(name, function() { uploadArea.style.borderColor = '#e0d8cc'; });
    });
    uploadArea.addEventListener('drop', function(e) {
        var files = e.dataTransfer.files;
        if (files.length > 0) {
            document.getElementById('fileInput').files = files;
            previewImage(document.getElementById('fileInput'));
        }
    });

    // Form submit loading state
    document.querySelector('form').addEventListener('submit', function() {
        var btn = document.getElementById('submitBtn');
        btn.disabled = true;
        btn.textContent = '发布中...';
        btn.style.opacity = '0.7';
    });

    // Character counter for title
    var titleInput = document.querySelector('input[name="title"]');
    titleInput.setAttribute('maxlength', '100');

    function logout() {
        if (confirm('确定要退出登录吗？')) window.location.href = '<%= request.getContextPath() %>/logout';
    }
</script>
</body>
</html>