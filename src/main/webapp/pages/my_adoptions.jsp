
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
        .btn {
            background: #e6a14c; color: white; border: none; border-radius: 12px;
            padding: 10px 20px; font-weight: 700; cursor: pointer; transition: 0.3s;
        }
        .btn:hover { background: #c97d2a; }
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
    <h2>我的领养申请</h2>
    <% if (adoptions == null || adoptions.isEmpty()) { %>
    <div class="card" style="text-align:center; color:#a68a64;">暂无领养申请，去首页看看猫咪吧</div>
    <% } else {
        for (Adoption ad : adoptions) {
            String status = ad.getStatus();
            String badgeClass = "status-pending";
            if ("已通过".equals(status)) badgeClass = "status-approved";
            else if ("已拒绝".equals(status)) badgeClass = "status-rejected";
            else if ("已取消".equals(status)) badgeClass = "status-cancelled";
    %>
    <div class="adopt-item">
        <h3>猫咪：<%= ad.getCatName() %></h3>
        <p>申请人：<%= ad.getApplicantName() %> | 电话：<%= ad.getApplicantPhone() %> | 地址：<%= ad.getApplicantAddress() %></p>
        <p>申请理由：<%= ad.getReason() %></p>
        <p>状态：<span class="status-badge <%= badgeClass %>"><%= status %></span></p>
        <% if (ad.getReviewNotes() != null && !ad.getReviewNotes().isEmpty()) { %>
        <p><strong>审核意见：</strong><%= ad.getReviewNotes() %></p>
        <% } %>
        <p style="font-size:12px; color:#aaa;">申请时间：<%= ad.getApplyDate() != null ? ad.getApplyDate().toString().substring(0, 19) : "" %></p>
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