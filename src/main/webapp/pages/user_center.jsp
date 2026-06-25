<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.dao.FavoriteDAO" %>
<%@ page import="com.example.maomi.dao.CatDAO" %>
<%@ page import="com.example.maomi.model.Cat" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    FavoriteDAO favDAO = new FavoriteDAO();
    CatDAO catDAO = new CatDAO();
    Set<Integer> favIds = favDAO.getFavoriteCatIds(sessionUser.getUsername());
    List<Cat> favoriteCats = catDAO.getCatsByIds(favIds);

    // 获取猫咪统计数据
    List<Cat> allCats = catDAO.getAllCats();
    int totalCats = allCats.size();
    int adoptedCount = 0;
    for (Cat c : allCats) {
        if ("已领养".equals(c.getState())) adoptedCount++;
    }
    int availableCount = totalCats - adoptedCount;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>个人中心 - 校园流浪猫管理</title>
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
            background: url('../images/login-bg.jpg') center/cover no-repeat;
            opacity: 0.08;
            z-index: -1;
            pointer-events: none;
        }
        .navbar {
            background: rgba(255, 250, 240, 0.92);
            backdrop-filter: blur(12px);
            box-shadow: 0 2px 15px rgba(0,0,0,0.06);
            padding: 12px 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
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

        /* 统计卡片 */
        .stats-row {
            display: flex; justify-content: center; gap: 30px;
            padding: 20px 20px 10px;
        }
        .stat-card {
            background: white; border-radius: 20px; padding: 20px 30px;
            text-align: center; box-shadow: 0 8px 20px rgba(0,0,0,0.04);
            min-width: 140px; transition: 0.3s;
        }
        .stat-card:hover { transform: translateY(-3px); }
        .stat-number { font-size: 32px; font-weight: 700; color: #e6a14c; }
        .stat-label { color: #b3904f; font-size: 14px; margin-top: 4px; }

        .card {
            background: white; border-radius: 24px; padding: 25px; margin-bottom: 25px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.06);
        }
        h2 { color: #6f4518; margin-top: 0; }
        label { color: #b3904f; font-weight: 600; font-size: 14px; display: block; margin: 10px 0 4px; }
        input[type="text"], input[type="password"], textarea {
            width: 100%; padding: 10px 14px; border: 1.5px solid #f0d9b5;
            border-radius: 12px; font-size: 14px; background: #fffef9; outline: none; transition: 0.3s;
        }
        input:focus, textarea:focus { border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.12); }
        .btn {
            background: #e6a14c; color: white; border: none; border-radius: 14px;
            padding: 10px 24px; font-weight: 700; cursor: pointer; transition: 0.3s; margin-top: 10px;
        }
        .btn:hover { background: #c97d2a; transform: translateY(-1px); }
        .avatar-section { display: flex; align-items: center; gap: 20px; }
        .avatar-img { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; border: 3px solid #f0d9b5; }
        .fav-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 15px; }
        .fav-cat-card {
            background: #fefaf5; border-radius: 18px; padding: 15px; text-align: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.04); cursor: pointer; transition: 0.3s;
        }
        .fav-cat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
        .fav-cat-card img { width: 80px; height: 80px; border-radius: 50%; object-fit: cover; margin-bottom: 8px; }
        .msg { color: #2d6a2d; background: #e6f7e6; padding: 8px 15px; border-radius: 10px; display: inline-block; margin-bottom: 15px; }
        .error { color: #c1121f; background: #ffeaea; padding: 8px 15px; border-radius: 10px; }

        /* 模态框（与首页一致） */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: none; justify-content: center; align-items: center; z-index: 200;
        }
        .modal-content {
            background: #fffef9; width: 500px; max-height: 80vh; border-radius: 24px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2); padding: 30px; overflow-y: auto;
            position: relative; animation: modalSlide 0.3s ease;
        }
        @keyframes modalSlide {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .modal-close { position: absolute; top: 15px; right: 20px; font-size: 28px; cursor: pointer; color: #b3904f; }
        .modal-cat-image { width: 100%; height: 250px; object-fit: cover; border-radius: 16px; margin-bottom: 15px; }
        .modal-field { margin-bottom: 10px; font-size: 14px; color: #6f4518; }
        .modal-field strong { color: #b87c2c; }
        .modal-comments {
            max-height: 200px; overflow-y: auto; margin: 15px 0;
            border-top: 1px solid #f0d9b5; border-bottom: 1px solid #f0d9b5; padding: 10px 0;
        }
        .comment-item { padding: 4px 0; color: #6f4518; border-bottom: 1px dashed #f0d9b5; }
        .comment-item strong { color: #e6a14c; }
        .adopt-btn, .disabled-btn {
            width: 100%; padding: 12px; border-radius: 12px; border: none; font-weight: 700; margin-top: 10px; cursor: pointer;
        }
        .adopt-btn { background: #e6a14c; color: white; }
        .adopt-btn:hover { background: #c97d2a; }
        .disabled-btn { background: #f0d9b5; color: #8b5a10; cursor: not-allowed; }
        #adoptFormArea {
            background: #fef9f2; border-radius: 18px; padding: 20px; margin-top: 15px; border: 1px solid #f5e0c4;
        }
        #adoptFormArea h4 { margin: 0 0 15px 0; color: #b87c2c; font-size: 17px; }
        #adoptFormArea label { display: block; font-size: 13px; color: #b3904f; margin: 12px 0 4px; font-weight: 600; }
        #adoptFormArea input, #adoptFormArea textarea {
            width: 100%; padding: 10px 14px; border: 1.5px solid #f0d9b5;
            border-radius: 12px; font-size: 14px; background: #fffef9; transition: 0.3s; outline: none; resize: vertical;
        }
        #adoptFormArea input:focus, #adoptFormArea textarea:focus {
            border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.12); background: #fff;
        }
        #adoptFormArea .adopt-btn {
            margin-top: 18px; background: linear-gradient(135deg, #f4b26a, #e6a14c);
            box-shadow: 0 6px 16px rgba(230,161,76,0.25); border-radius: 14px; font-size: 15px; transition: 0.3s;
        }
        #adoptFormArea .adopt-btn:hover {
            background: linear-gradient(135deg, #e6a14c, #c97d2a); transform: translateY(-1px); box-shadow: 0 8px 20px rgba(230,161,76,0.35);
        }
        .fav-icon { font-size: 22px; color: #f4b26a; cursor: pointer; margin-left: 10px; vertical-align: middle; transition: 0.2s; display: inline-block; }
        .fav-icon.favorited { color: #e6a14c; }
        .fav-icon:hover { transform: scale(1.2); }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="nav-logo">🐾 校园流浪猫</div>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/pages/home.jsp">🏠 首页</a>
        <a href="<%= request.getContextPath() %>/myAdoptions">📋 我的领养</a>
        <a href="<%= request.getContextPath() %>/forumList">💬 论坛</a>
        <a href="<%= request.getContextPath() %>/knowledgeList">📖 知识科普</a>
        <a href="<%= request.getContextPath() %>/pages/feeding.jsp">🍼 在线喂养</a>
        <a href="<%= request.getContextPath() %>/pages/user_center.jsp">👤 个人中心</a>
    </div>
    <div class="user-badge">
        🐱 <%= sessionUser.getUsername() %>
        <button class="logout-btn" onclick="logout()">退出登录</button>
    </div>
</nav>

<div class="container">
    <%-- 统计卡片 --%>
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-number"><%= totalCats %></div>
            <div class="stat-label">🐾 猫咪总数</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= adoptedCount %></div>
            <div class="stat-label">🏠 已领养</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= availableCount %></div>
            <div class="stat-label">💛 等待领养</div>
        </div>
    </div>

    <%-- 操作结果提示 --%>
    <% if (request.getParameter("msg") != null) { %>
    <% if ("pwd_ok".equals(request.getParameter("msg"))) { %>
    <div class="msg">✅ 密码修改成功</div>
    <% } else if ("profile_ok".equals(request.getParameter("msg"))) { %>
    <div class="msg">✅ 个人信息更新成功</div>
    <% } else if ("avatar_ok".equals(request.getParameter("msg"))) { %>
    <div class="msg">✅ 头像上传成功</div>
    <% } else if ("pwd_fail".equals(request.getParameter("msg"))) { %>
    <div class="error">❌ <%= request.getParameter("error") %></div>
    <% } %>
    <% } %>

    <!-- 头像与基本资料 -->
    <div class="card">
        <div class="avatar-section">
            <img class="avatar-img"
                 src="<%= request.getContextPath() %>/avatar?name=<%= sessionUser.getProfileImage() != null ? sessionUser.getProfileImage() : "default.png" %>"
                 alt="头像">
            <div>
                <h2><%= sessionUser.getUsername() %></h2>
                <form action="<%= request.getContextPath() %>/uploadAvatar" method="post" enctype="multipart/form-data">
                    <input type="file" name="avatar" accept="image/*" required>
                    <button type="submit" class="btn">上传新头像</button>
                </form>
            </div>
        </div>
    </div>

    <!-- 完善个人信息 -->
    <div class="card">
        <h2>📝 个人信息</h2>
        <form action="<%= request.getContextPath() %>/updateProfile" method="post">
            <label>手机号</label>
            <input type="text" name="phone" value="<%= sessionUser.getPhone() != null ? sessionUser.getPhone() : "" %>">
            <label>电子邮箱</label>
            <input type="text" name="email" value="<%= sessionUser.getEmail() != null ? sessionUser.getEmail() : "" %>">
            <label>地址</label>
            <input type="text" name="address" value="<%= sessionUser.getAddress() != null ? sessionUser.getAddress() : "" %>">
            <button type="submit" class="btn">保存修改</button>
        </form>
    </div>

    <!-- 修改密码 -->
    <div class="card">
        <h2>🔒 修改密码</h2>
        <form action="<%= request.getContextPath() %>/updatePassword" method="post">
            <label>旧密码</label>
            <input type="password" name="oldPassword" required>
            <label>新密码</label>
            <input type="password" name="newPassword" required>
            <button type="submit" class="btn">确认修改</button>
        </form>
    </div>

    <!-- 我的收藏 -->
    <div class="card">
        <h2>⭐ 我的收藏</h2>
        <% if (favoriteCats == null || favoriteCats.isEmpty()) { %>
        <p style="color:#a68a64;">还没有收藏猫咪哦，去首页看看吧～</p>
        <% } else { %>
        <div class="fav-grid">
            <% for (Cat cat : favoriteCats) { %>
            <div class="fav-cat-card" data-catid="<%= cat.getId() %>" onclick="openCatModal(<%= cat.getId() %>)">
                <img src="<%= request.getContextPath() + "/" + cat.getImagePath() %>" alt="<%= cat.getName() %>">
                <p style="font-weight: 700; color: #6f4518;"><%= cat.getName() %></p>
                <p style="font-size: 13px; color: #b3904f;"><%= cat.getState() %></p>
                <span class="fav-icon favorited" onclick="event.stopPropagation(); toggleFavorite(<%= cat.getId() %>)" title="取消收藏">★</span>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<!-- 猫咪详情模态框 -->
<div id="catModal" class="modal-overlay">
    <div class="modal-content">
        <span class="modal-close" onclick="closeModal()">&times;</span>
        <img id="modalImage" class="modal-cat-image" src="" alt="">
        <h2 id="modalName" style="color:#6f4518;"></h2>
        <div class="modal-field"><strong>毛色：</strong><span id="modalColor"></span></div>
        <div class="modal-field"><strong>年龄：</strong><span id="modalAge"></span> 个月</div>
        <div class="modal-field"><strong>性别：</strong><span id="modalGender"></span></div>
        <div class="modal-field"><strong>健康状况：</strong><span id="modalHealth"></span></div>
        <div class="modal-field"><strong>描述：</strong><span id="modalDesc"></span></div>
        <div class="modal-field"><strong>发现地点：</strong><span id="modalLocation"></span></div>
        <div class="modal-field"><strong>发现日期：</strong><span id="modalDate"></span></div>

        <h4 style="margin-top:15px;">💬 大家对它的留言</h4>
        <div class="modal-comments" id="modalCommentsList">加载中...</div>

        <div id="modalBtnArea"></div>

        <div id="adoptFormArea" style="display:none;">
            <h4>📋 填写领养申请</h4>
            <label>您的姓名</label>
            <input type="text" id="appName" placeholder="请输入姓名" required>
            <label>手机号码</label>
            <input type="text" id="appPhone" placeholder="请输入手机号" required>
            <label>家庭地址</label>
            <input type="text" id="appAddress" placeholder="请输入地址" required>
            <label>申请理由</label>
            <textarea id="appReason" rows="3" placeholder="请说明养猫经验、家庭环境等" required></textarea>
            <button class="adopt-btn" onclick="submitAdoption()">✨ 提交申请</button>
        </div>
    </div>
</div>

<script>
    var currentCatId = null;
    var currentCatState = null;

    function openCatModal(catId) {
        currentCatId = catId;
        fetch('<%= request.getContextPath() %>/getCatDetail?id=' + catId)
            .then(res => res.json())
            .then(cat => {
                document.getElementById('modalImage').src = '<%= request.getContextPath() %>/' + cat.imagePath;
                document.getElementById('modalName').innerText = cat.name;
                document.getElementById('modalColor').innerText = cat.color;
                document.getElementById('modalAge').innerText = cat.age;
                document.getElementById('modalGender').innerText = cat.gender;
                document.getElementById('modalHealth').innerText = cat.healthStatus;
                document.getElementById('modalDesc').innerText = cat.description;
                document.getElementById('modalLocation').innerText = cat.foundLocation;
                document.getElementById('modalDate').innerText = cat.foundDate;
                currentCatState = cat.state;

                loadModalComments(catId);

                var btnArea = document.getElementById('modalBtnArea');
                if (cat.state === '已领养') {
                    btnArea.innerHTML = '<button class="disabled-btn" disabled>🏠 已被领养</button>';
                    document.getElementById('adoptFormArea').style.display = 'none';
                } else {
                    btnArea.innerHTML = '<button class="adopt-btn" onclick="showAdoptForm()">💌 申请领养</button>';
                    document.getElementById('adoptFormArea').style.display = 'none';
                }
                document.getElementById('catModal').style.display = 'flex';
            });
    }

    function loadModalComments(catId) {
        fetch('<%= request.getContextPath() %>/getComments?catId=' + catId)
            .then(res => res.json())
            .then(data => {
                var container = document.getElementById('modalCommentsList');
                if (data.length === 0) {
                    container.innerHTML = '<div style="color:#aaa;">暂无留言</div>';
                } else {
                    container.innerHTML = data.map(c => '<div class="comment-item"><strong>' + c.username + '：</strong>' + c.comment + '</div>').join('');
                }
            });
    }

    function closeModal() {
        document.getElementById('catModal').style.display = 'none';
        document.getElementById('adoptFormArea').style.display = 'none';
        document.getElementById('modalBtnArea').style.display = 'block';
    }

    function showAdoptForm() {
        document.getElementById('adoptFormArea').style.display = 'block';
        document.getElementById('modalBtnArea').style.display = 'none';
    }

    function submitAdoption() {
        var name = document.getElementById('appName').value.trim();
        var phone = document.getElementById('appPhone').value.trim();
        var address = document.getElementById('appAddress').value.trim();
        var reason = document.getElementById('appReason').value.trim();
        if (!name || !phone || !address || !reason) {
            alert('请填写完整信息');
            return;
        }
        fetch('<%= request.getContextPath() %>/submitAdoption', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'catId=' + currentCatId +
                '&catName=' + encodeURIComponent(document.getElementById('modalName').innerText) +
                '&applicantName=' + encodeURIComponent(name) +
                '&applicantPhone=' + encodeURIComponent(phone) +
                '&applicantAddress=' + encodeURIComponent(address) +
                '&reason=' + encodeURIComponent(reason)
        }).then(res => res.text())
            .then(msg => {
                if (msg === 'success') {
                    alert('申请已提交，等待管理员审核！');
                    closeModal();
                } else {
                    alert('提交失败：' + msg);
                }
            });
    }

    function toggleFavorite(catId) {
        fetch('<%= request.getContextPath() %>/toggleFavorite', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'catId=' + catId
        }).then(res => res.text())
            .then(result => {
                if (result === 'removed') {
                    location.reload();
                }
            });
    }

    function logout() {
        if (confirm('确定要退出登录吗？')) {
            window.location.href = '<%= request.getContextPath() %>/logout';
        }
    }
</script>
</body>
</html>