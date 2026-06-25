<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.model.Adoption" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    List<Adoption> adoptions = (List<Adoption>) request.getAttribute("adoptions");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>我的领养 - 校园流浪猫管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #fffaf3;
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            position: relative;
        }
        /* 背景柔光图案（与首页、登录页相同） */
        body::before {
            content: "";
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: url('${pageContext.request.contextPath}/images/login-bg.jpg') center/cover no-repeat;
            opacity: 0.08;
            z-index: -1;
            pointer-events: none;
        }
        /* 导航栏 */
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
        .nav-logo { font-size: 22px; font-weight: 700; color: #b87c2c; letter-spacing: 1px; }
        .nav-links { display: flex; gap: 25px; }
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

        /* 内容区 */
        .container { max-width: 900px; margin: 30px auto; padding: 20px; }
        .card {
            background: white; border-radius: 24px; padding: 25px; margin-bottom: 25px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.06);
        }
        h2 { color: #6f4518; margin-bottom: 15px; }
        .adopt-item {
            border: 1px solid #f5e0c4; border-radius: 16px; padding: 18px;
            margin-bottom: 15px; background: #fefaf5;
        }
        .adopt-item h3 { color: #b87c2c; margin-bottom: 8px; }
        .adopt-item p { color: #6f4518; margin: 4px 0; font-size: 14px; }
        .status-badge {
            display: inline-block; padding: 4px 14px; border-radius: 20px;
            font-weight: 700; font-size: 14px;
        }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d4edda; color: #155724; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        .status-cancelled { background: #e2e3e5; color: #383d41; }

        /* 对话区域 */
        .chat-box {
            background: #fffef9; border: 1px solid #f0d9b5; border-radius: 12px;
            padding: 15px; margin-top: 15px; max-height: 300px; overflow-y: auto;
        }
        .chat-message { margin-bottom: 12px; }
        .chat-message .sender { font-weight: 700; color: #b87c2c; }
        .chat-message .time { font-size: 12px; color: #aaa; margin-left: 8px; }
        .chat-message .content { margin-top: 4px; color: #6f4518; word-break: break-all; }
        .chat-input { display: flex; gap: 10px; margin-top: 15px; }
        .chat-input input {
            flex: 1; padding: 10px 14px; border: 1.5px solid #f0d9b5;
            border-radius: 12px; font-size: 14px; background: #fffef9; outline: none;
            transition: 0.3s;
        }
        .chat-input input:focus { border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.12); }
        .btn {
            background: #e6a14c; color: white; border: none; border-radius: 12px;
            padding: 10px 20px; font-weight: 700; cursor: pointer; transition: 0.3s;
        }
        .btn:hover { background: #c97d2a; }
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
    <h2>📋 我的领养申请</h2>
    <% if (adoptions == null || adoptions.isEmpty()) { %>
    <div class="card" style="text-align:center; color:#a68a64;">暂无领养申请，去首页看看猫咪吧~</div>
    <% } else {
        for (Adoption ad : adoptions) {
            String status = ad.getStatus();
            String badgeClass = "status-pending";
            if ("已通过".equals(status)) badgeClass = "status-approved";
            else if ("已拒绝".equals(status)) badgeClass = "status-rejected";
            else if ("已取消".equals(status)) badgeClass = "status-cancelled";
    %>
    <div class="adopt-item">
        <h3>🐱 猫咪：<%= ad.getCatName() %></h3>
        <p>申请人：<%= ad.getApplicantName() %> | 电话：<%= ad.getApplicantPhone() %> | 地址：<%= ad.getApplicantAddress() %></p>
        <p>申请理由：<%= ad.getReason() %></p>
        <p>状态：<span class="status-badge <%= badgeClass %>"><%= status %></span></p>
        <% if (ad.getReviewNotes() != null && !ad.getReviewNotes().isEmpty()) { %>
        <p><strong>管理员回复：</strong><%= ad.getReviewNotes() %></p>
        <% } %>
        <p style="font-size:12px; color:#aaa;">申请时间：<%= ad.getApplyDate() != null ? ad.getApplyDate().toString().substring(0, 19) : "" %></p>

        <!-- 对话区域 -->
        <div class="chat-box" id="chat-<%= ad.getId() %>">
            <!-- 动态加载消息 -->
        </div>
        <div class="chat-input">
            <input type="text" id="msgInput-<%= ad.getId() %>" placeholder="输入消息...">
            <button class="btn" onclick="sendMsg(<%= ad.getId() %>)">发送</button>
        </div>
    </div>
    <%  }
    } %>
</div>

<script>
    // 页面加载时，加载每个申请的对话
    window.onload = function() {
        <% if (adoptions != null) {
            for (Adoption ad : adoptions) { %>
        loadMessages(<%= ad.getId() %>);
        <%  }
        } %>
    };

    function loadMessages(adoptionId) {
        fetch('<%= request.getContextPath() %>/getAdoptionMessages?adoptionId=' + adoptionId)
            .then(res => res.json())
            .then(data => {
                var container = document.getElementById('chat-' + adoptionId);
                container.innerHTML = '';
                if (data.length === 0) {
                    container.innerHTML = '<div style="color:#aaa;">暂无对话</div>';
                } else {
                    data.forEach(msg => {
                        container.innerHTML +=
                            '<div class="chat-message">' +
                            '<span class="sender">' + msg.sender + '</span>' +
                            '<span class="time">' + msg.time + '</span>' +
                            '<div class="content">' + msg.message + '</div>' +
                            '</div>';
                    });
                }
            });
    }

    function sendMsg(adoptionId) {
        var input = document.getElementById('msgInput-' + adoptionId);
        var text = input.value.trim();
        if (!text) return;
        fetch('<%= request.getContextPath() %>/sendAdoptionMessage', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'adoptionId=' + adoptionId + '&message=' + encodeURIComponent(text)
        })
            .then(res => res.text())
            .then(resp => {
                if (resp === 'ok') {
                    input.value = '';
                    loadMessages(adoptionId);
                } else {
                    alert('发送失败：' + resp);
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