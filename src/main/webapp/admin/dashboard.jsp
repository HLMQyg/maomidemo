<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    String adminName = (String) session.getAttribute("adminName");
    String role = (String) session.getAttribute("role");
    if (adminName == null || !"admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理后台 - 校园流浪猫管理系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: #f0f2f5;
            display: flex;
        }
        .sidebar {
            width: 220px;
            min-height: 100vh;
            background: linear-gradient(180deg, #3d3226 0%, #2c241b 100%);
            color: #c4b9a8;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            position: fixed;
            top: 0; left: 0; bottom: 0;
            z-index: 100;
            box-shadow: 2px 0 12px rgba(0,0,0,0.15);
        }
        .sidebar-brand {
            padding: 24px 20px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .sidebar-brand h1 {
            font-size: 17px;
            font-weight: 700;
            color: #fff;
            letter-spacing: 1px;
        }
        .sidebar-brand .sub {
            font-size: 12px;
            color: #a69780;
            margin-top: 4px;
        }
        .sidebar-nav { flex: 1; padding: 12px 0; }
        .sidebar-nav a {
            display: flex; align-items: center; gap: 10px;
            padding: 13px 24px; color: #bfb09b;
            text-decoration: none; font-size: 14px; font-weight: 500;
            border-left: 3px solid transparent; transition: all 0.2s;
        }
        .sidebar-nav a:hover { background: rgba(255,255,255,0.06); color: #e8d5b7; }
        .sidebar-nav a.active {
            background: rgba(230,161,76,0.15); color: #e6a14c;
            border-left-color: #e6a14c; font-weight: 600;
        }
        .sidebar-nav a .nav-icon { width: 20px; text-align: center; font-size: 15px; }
        .sidebar-footer {
            padding: 16px 24px;
            border-top: 1px solid rgba(255,255,255,0.08);
            font-size: 13px;
        }
        .sidebar-footer .admin-info { color: #a69780; margin-bottom: 10px; }
        .sidebar-footer .admin-info strong { color: #d4c4a8; }
        .sidebar-footer .logout-link { color: #bfb09b; text-decoration: none; cursor: pointer; font-size: 13px; transition: 0.2s; }
        .sidebar-footer .logout-link:hover { color: #e6a14c; }
        .main-content { margin-left: 220px; flex: 1; padding: 28px 30px; min-height: 100vh; }
        .page-header { margin-bottom: 24px; }
        .page-header h2 { font-size: 22px; color: #2c241b; font-weight: 700; }
        .page-header .breadcrumb { font-size: 13px; color: #999; margin-top: 4px; }
        .stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 28px; }
        .stat-card {
            background: #fff; border-radius: 14px; padding: 22px 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04); display: flex;
            align-items: center; gap: 16px; transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
        .stat-icon-wrap {
            width: 50px; height: 50px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px; flex-shrink: 0;
        }
        .stat-icon-wrap.orange { background: #fef3e6; }
        .stat-icon-wrap.green { background: #e8f5e9; }
        .stat-icon-wrap.blue { background: #e3f2fd; }
        .stat-icon-wrap.purple { background: #f3e5f5; }
        .stat-icon-wrap.red { background: #fdecea; }
        .stat-body .stat-num { font-size: 26px; font-weight: 700; color: #2c241b; line-height: 1.2; }
        .stat-body .stat-desc { font-size: 13px; color: #a69780; }
        .content-card {
            background: #fff; border-radius: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04); padding: 22px 24px; margin-bottom: 20px;
        }
        .card-toolbar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 18px; flex-wrap: wrap; gap: 12px;
        }
        .card-toolbar h3 { font-size: 16px; color: #2c241b; font-weight: 600; }
        .search-input {
            padding: 8px 16px; border: 1.5px solid #e0d8cc; border-radius: 8px;
            font-size: 13px; width: 220px; outline: none; transition: 0.2s;
            font-family: "Microsoft YaHei", sans-serif;
        }
        .search-input:focus { border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.1); }
        .filter-select {
            padding: 8px 14px; border: 1.5px solid #e0d8cc; border-radius: 8px;
            font-size: 13px; outline: none; background: #fff;
            font-family: "Microsoft YaHei", sans-serif;
        }
        .btn {
            display: inline-block; padding: 8px 18px; border: none;
            border-radius: 8px; font-size: 13px; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
            font-family: "Microsoft YaHei", sans-serif; text-decoration: none;
        }
        .btn-primary { background: #e6a14c; color: #fff; }
        .btn-primary:hover { background: #d4923a; }
        .btn-outline { background: #fff; color: #e6a14c; border: 1.5px solid #e6a14c; }
        .btn-outline:hover { background: #fef8f0; }
        .btn-danger { background: #d32f2f; color: #fff; }
        .btn-danger:hover { background: #b71c1c; }
        .btn-success { background: #388e3c; color: #fff; }
        .btn-success:hover { background: #2e7d32; }
        .btn-sm { padding: 5px 12px; font-size: 12px; border-radius: 6px; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        th {
            background: #faf7f2; color: #6b5e4a; padding: 11px 14px;
            text-align: left; font-weight: 600; border-bottom: 2px solid #e8ded0;
            white-space: nowrap;
        }
        td {
            padding: 10px 14px; border-bottom: 1px solid #f0ebe0;
            color: #4a3f32; vertical-align: middle;
        }
        tr:hover td { background: #fefcf8; }
        .cell-actions { white-space: nowrap; }
        .cell-actions .btn + .btn { margin-left: 6px; }
        .empty-row td { text-align: center; color: #bbb; padding: 36px; }
        .tag { display: inline-block; padding: 2px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; }
        .tag-pending { background: #fff8e1; color: #e65100; }
        .tag-ok { background: #e8f5e9; color: #1b5e20; }
        .tag-no { background: #fdecea; color: #b71c1c; }
        .tag-info { background: #e3f2fd; color: #0d47a1; }
        .recent-list .recent-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 11px 0; border-bottom: 1px solid #f0ebe0;
        }
        .recent-list .recent-item:last-child { border-bottom: none; }
        .recent-item .recent-info { font-size: 14px; color: #4a3f32; }
        .recent-item .recent-time { font-size: 12px; color: #aaa; }
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: none;
            justify-content: center; align-items: center; z-index: 500;
        }
        .modal-overlay.show { display: flex; }
        .modal-box {
            background: #fff; border-radius: 16px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.25); padding: 28px;
            width: 500px; max-height: 85vh; overflow-y: auto;
            animation: modalIn 0.25s ease;
        }
        @keyframes modalIn {
            from { opacity: 0; transform: translateY(15px) scale(0.97); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .modal-box h3 { color: #2c241b; margin-bottom: 18px; font-size: 17px; }
        .modal-close {
            float: right; background: none; border: none;
            font-size: 22px; cursor: pointer; color: #999; line-height: 1;
        }
        .modal-close:hover { color: #333; }
        .form-group { margin-bottom: 15px; }
        .form-group label {
            display: block; font-size: 13px; color: #6b5e4a;
            font-weight: 600; margin-bottom: 5px;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 9px 12px; border: 1.5px solid #e0d8cc;
            border-radius: 8px; font-size: 13px;
            font-family: "Microsoft YaHei", sans-serif; outline: none;
            transition: 0.2s; resize: vertical;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.1);
        }
        .form-row { display: flex; gap: 14px; }
        .form-row .form-group { flex: 1; }
        .toast {
            position: fixed; top: 24px; left: 50%; transform: translateX(-50%);
            padding: 11px 28px; border-radius: 10px; font-weight: 600; font-size: 14px;
            z-index: 600; display: none; animation: toastIn 0.3s ease;
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
        }
        .toast.ok { background: #e8f5e9; color: #1b5e20; }
        .toast.err { background: #fdecea; color: #b71c1c; }
        @keyframes toastIn {
            from { opacity: 0; transform: translateX(-50%) translateY(-10px); }
            to { opacity: 1; transform: translateX(-50%) translateY(0); }
        }
        @media (max-width: 768px) {
            .sidebar { width: 60px; }
            .sidebar-brand h1, .sidebar-brand .sub,
            .sidebar-nav a span:not(.nav-icon),
            .sidebar-footer .admin-info,
            .sidebar-footer .logout-link { display: none; }
            .sidebar-nav a { padding: 14px; justify-content: center; }
            .main-content { margin-left: 60px; padding: 16px; }
            .stats-row { grid-template-columns: repeat(2, 1fr); }
        }
    </style>
</head>
<body>

<aside class="sidebar">
    <div class="sidebar-brand">
        <h1>管理后台</h1>
        <div class="sub">校园流浪猫管理系统</div>
    </div>
    <nav class="sidebar-nav">
        <a href="#" class="active" data-panel="overview">
            <span class="nav-icon">&#x1F4CA;</span> 数据概览
        </a>
        <a href="#" data-panel="cats">
            <span class="nav-icon">&#x1F431;</span> 猫咪管理
        </a>
        <a href="#" data-panel="adoptions">
            <span class="nav-icon">&#x1F4CB;</span> 领养审核
        </a>
        <a href="#" data-panel="users">
            <span class="nav-icon">&#x1F464;</span> 用户管理
        </a>
        <a href="#" data-panel="comments">
            <span class="nav-icon">&#x1F4AC;</span> 评论管理
        </a>
        <a href="#" data-panel="forum">
            <span class="nav-icon">&#x1F4DD;</span> 论坛管理
        </a>
        <a href="#" data-panel="feeding">
            <span class="nav-icon">&#x1F36C;</span> 在线喂养
        </a>
        <a href="#" data-panel="items">
            <span class="nav-icon">&#x1F6D2;</span> 商品管理
        </a>
    </nav>
    <div class="sidebar-footer">
        <div class="admin-info"><%= adminName %></div>
        <a class="logout-link" onclick="doLogout()">退出登录</a>
    </div>
</aside>

<div class="main-content">

    <div id="panel-overview" class="panel-wrap">
        <div class="page-header">
            <h2>数据概览</h2>
            <div class="breadcrumb">首页 / 数据概览</div>
        </div>
        <div class="stats-row" id="statsRow"></div>
        <div class="content-card">
            <h3 style="margin-bottom:14px;">最近领养申请</h3>
            <div class="recent-list" id="recentList"></div>
        </div>
    </div>

    <div id="panel-cats" class="panel-wrap" style="display:none;">
        <div class="page-header">
            <h2>猫咪管理</h2>
            <div class="breadcrumb">首页 / 猫咪管理</div>
        </div>
        <div class="content-card">
            <div class="card-toolbar">
                <h3>猫咪列表</h3>
                <div style="display:flex; gap:10px; align-items:center;">
                    <input type="text" class="search-input" id="catSearch" placeholder="搜索猫咪名称..." oninput="renderCatTable()">
                    <button class="btn btn-primary" onclick="openCatForm()">+ 添加猫咪</button>
                </div>
            </div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr><th>ID</th><th>图片</th><th>名称</th><th>毛色</th><th>年龄</th><th>性别</th><th>状态</th><th>发现地点</th><th>操作</th></tr>
                    </thead>
                    <tbody id="catTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="panel-adoptions" class="panel-wrap" style="display:none;">
        <div class="page-header">
            <h2>领养审核</h2>
            <div class="breadcrumb">首页 / 领养审核</div>
        </div>
        <div class="content-card">
            <div class="card-toolbar">
                <h3>申请列表</h3>
                <select class="filter-select" id="adoptFilter" onchange="renderAdoptionTable()">
                    <option value="all">全部状态</option>
                    <option value="待审核">待审核</option>
                    <option value="已通过">已通过</option>
                    <option value="已拒绝">已拒绝</option>
                </select>
            </div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr><th>ID</th><th>猫咪</th><th>申请人</th><th>电话</th><th>申请时间</th><th>状态</th><th>操作</th></tr>
                    </thead>
                    <tbody id="adoptionTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="panel-users" class="panel-wrap" style="display:none;">
        <div class="page-header">
            <h2>用户管理</h2>
            <div class="breadcrumb">首页 / 用户管理</div>
        </div>
        <div class="content-card">
            <div class="card-toolbar">
                <h3>用户列表</h3>
                <input type="text" class="search-input" id="userSearch" placeholder="搜索用户名..." oninput="renderUserTable()">
            </div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr><th>用户名</th><th>手机号</th><th>邮箱</th><th>地址</th><th>注册时间</th><th>最后登录</th><th>操作</th></tr>
                    </thead>
                    <tbody id="userTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="panel-comments" class="panel-wrap" style="display:none;">
        <div class="page-header">
            <h2>评论管理</h2>
            <div class="breadcrumb">首页 / 评论管理</div>
        </div>
        <div class="content-card">
            <div class="card-toolbar"><h3>评论列表</h3></div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr><th>ID</th><th>猫咪ID</th><th>用户</th><th>内容</th><th>时间</th><th>操作</th></tr>
                    </thead>
                    <tbody id="commentTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="panel-forum" class="panel-wrap" style="display:none;">
        <div class="page-header">
            <h2>论坛管理</h2>
            <div class="breadcrumb">首页 / 论坛管理</div>
        </div>
        <div class="content-card">
            <div class="card-toolbar">
                <h3>帖子列表</h3>
                <button class="btn btn-primary btn-sm" onclick="openAdminPostForm()">+ 管理员发帖</button>
            </div>
            <div class="table-wrap">
                <table>
                    <thead><tr><th>ID</th><th>标题</th><th>作者</th><th>分类</th><th>置顶</th><th>隐藏</th><th>赞/评/阅</th><th>时间</th><th>操作</th></tr></thead>
                    <tbody id="forumTbody"></tbody>
                </table>
            </div>
        </div>
        <div class="content-card">
            <div class="card-toolbar"><h3>举报列表</h3></div>
            <div class="table-wrap">
                <table>
                    <thead><tr><th>ID</th><th>帖子</th><th>举报人</th><th>理由</th><th>状态</th><th>时间</th><th>操作</th></tr></thead>
                    <tbody id="reportTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="panel-feeding" class="panel-wrap" style="display:none;">
        <div class="page-header">
            <h2>在线喂养管理</h2>
            <div class="breadcrumb">首页 / 在线喂养</div>
        </div>
        <div class="content-card">
            <div class="card-toolbar"><h3>喂养中的猫咪</h3></div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr><th>猫咪</th><th>喂养人</th><th>最近喂养时间</th><th>操作</th></tr>
                    </thead>
                    <tbody id="feedingTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="panel-items" class="panel-wrap" style="display:none;">
        <div class="page-header">
            <h2>商品管理</h2>
            <div class="breadcrumb">首页 / 商品管理</div>
        </div>
        <div class="content-card">
            <div class="card-toolbar">
                <h3>商品列表</h3>
                <button class="btn btn-primary" onclick="openItemForm()">+ 添加商品</button>
            </div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr><th>图片</th><th>名称</th><th>描述</th><th>价格</th><th>分类</th><th>状态</th><th>操作</th></tr>
                    </thead>
                    <tbody id="itemTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<div class="modal-overlay" id="adminPostModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeAdminPostForm()">&times;</button>
        <h3>管理员发帖</h3>
        <form onsubmit="submitAdminPost(event)">
            <div class="form-group"><label>标题</label><input type="text" id="adminPostTitle" required></div>
            <div class="form-group"><label>分类</label><select id="adminPostCat"><option>猫咪日常</option><option>救助求助</option><option>领养分享</option><option>闲聊交流</option></select></div>
            <div class="form-group"><label>内容</label><textarea id="adminPostContent" rows="5" required></textarea></div>
            <button type="submit" class="btn btn-primary" style="width:100%;">发布</button>
        </form>
    </div>
</div>

<div class="modal-overlay" id="reportHandleModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeReportHandle()">&times;</button>
        <h3>处理举报</h3>
        <input type="hidden" id="reportHandleId">
        <input type="hidden" id="reportThreadId">
        <div class="form-group"><label>处理意见</label><textarea id="reportHandleNotes" rows="3" placeholder="输入处理意见..."></textarea></div>
        <div style="display:flex; gap:12px; margin-top:12px;">
            <button class="btn btn-danger" style="flex:1;" onclick="handleReport('已处理')">通过（下架帖子）</button>
            <button class="btn btn-outline" style="flex:1;" onclick="handleReport('已驳回')">驳回举报</button>
        </div>
    </div>
</div>

<div class="modal-overlay" id="catModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeCatForm()">&times;</button>
        <h3 id="catModalTitle">添加猫咪</h3>
        <form id="catForm" onsubmit="submitCat(event)">
            <input type="hidden" name="id" id="catId">
            <input type="hidden" name="action" id="catAction" value="add">
            <div class="form-row">
                <div class="form-group"><label>名称</label><input type="text" name="name" id="catName" required></div>
                <div class="form-group"><label>毛色</label><input type="text" name="color" id="catColor" required></div>
            </div>
            <div class="form-row">
                <div class="form-group"><label>年龄（月）</label><input type="number" name="age" id="catAge" required></div>
                <div class="form-group"><label>性别</label><select name="gender" id="catGender"><option>公</option><option>母</option></select></div>
            </div>
            <div class="form-group"><label>健康状况</label><input type="text" name="healthStatus" id="catHealth" required></div>
            <div class="form-group"><label>描述</label><textarea name="description" id="catDesc" rows="2"></textarea></div>
            <div class="form-row">
                <div class="form-group"><label>发现地点</label><input type="text" name="foundLocation" id="catLoc" required></div>
                <div class="form-group"><label>发现日期</label><input type="date" name="foundDate" id="catDate" required></div>
            </div>
            <div class="form-group"><label>图片路径</label><input type="text" name="imagePath" id="catImg" placeholder="例: images/cats/cat1.jpg"></div>
            <button type="submit" class="btn btn-primary" style="width:100%;margin-top:8px;">保存</button>
        </form>
    </div>
</div>

<div class="modal-overlay" id="reviewModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeReview()">&times;</button>
        <h3>审核领养申请</h3>
        <input type="hidden" id="reviewId">
        <div class="form-group"><label>审核意见</label><textarea id="reviewNotes" rows="3" placeholder="输入审核意见..."></textarea></div>
        <div style="display:flex; gap:12px; margin-top:12px;">
            <button class="btn btn-success" style="flex:1;" onclick="doReview('已通过')">通过申请</button>
            <button class="btn btn-danger" style="flex:1;" onclick="doReview('已拒绝')">拒绝申请</button>
        </div>
    </div>
</div>

<div class="modal-overlay" id="feedingCompleteModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeFeedingComplete()">&times;</button>
        <h3>喂养完成确认</h3>
        <p style="margin-bottom:12px;">将猫咪状态改为在校，并可给喂养人留言。</p>
        <input type="hidden" id="completeCatId">
        <input type="hidden" id="completeFeeder">
        <div class="form-group">
            <label>给喂养人的回复</label>
            <textarea id="completeMessage" rows="3" placeholder="例如：感谢投喂~"></textarea>
        </div>
        <div class="form-group">
            <label>上传图片（可选）</label>
            <input type="file" id="completeImage" accept="image/*">
        </div>
        <button class="btn btn-primary" onclick="submitFeedingComplete()" style="width:100%;">确认完成</button>
    </div>
</div>

<div class="modal-overlay" id="itemModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeItemForm()">&times;</button>
        <h3 id="itemModalTitle">添加商品</h3>
        <form id="itemForm" onsubmit="submitItem(event)">
            <input type="hidden" id="itemId">
            <input type="hidden" id="itemAction" value="add">
            <div class="form-group"><label>名称</label><input type="text" id="itemName" required></div>
            <div class="form-group"><label>描述</label><textarea id="itemDesc" rows="2"></textarea></div>
            <div class="form-group"><label>价格</label><input type="number" step="0.01" id="itemPrice" required></div>
            <div class="form-group"><label>图片路径</label><input type="text" id="itemImagePath" placeholder="例: images/items/cat_food.jpg"></div>
            <div class="form-group"><label>分类</label>
                <select id="itemCategory">
                    <option>猫粮</option>
                    <option>猫罐头</option>
                    <option>猫零食</option>
                    <option>营养品</option>
                    <option>猫玩具</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;">保存</button>
        </form>
    </div>
</div>

<div class="toast" id="toast"></div>

<script>
    var ctx = '<%= request.getContextPath() %>';

    var navLinks = document.querySelectorAll('.sidebar-nav a');
    navLinks.forEach(function(a) {
        a.onclick = function(e) {
            e.preventDefault();
            navLinks.forEach(function(l) { l.classList.remove('active'); });
            this.classList.add('active');
            var panel = this.getAttribute('data-panel');
            document.querySelectorAll('.panel-wrap').forEach(function(p) { p.style.display = 'none'; });
            document.getElementById('panel-' + panel).style.display = 'block';
            if (panel === 'overview') { loadOverview(); }
            else if (panel === 'cats') { loadCats(); }
            else if (panel === 'adoptions') { loadAdoptions(); }
            else if (panel === 'users') { loadUsers(); }
            else if (panel === 'comments') { loadComments(); }
            else if (panel === 'forum') { loadForumData(); }
            else if (panel === 'feeding') { loadFeedingList(); }
            else if (panel === 'items') { loadItems(); }
        };
    });

    function toast(msg, type) {
        var t = document.getElementById('toast');
        t.textContent = msg;
        t.className = 'toast ' + (type || 'ok');
        t.style.display = 'block';
        clearTimeout(t._timer);
        t._timer = setTimeout(function() { t.style.display = 'none'; }, 2500);
    }

    function loadOverview() {
        fetch(ctx + '/adminStats')
            .then(function(r) { return r.json(); })
            .then(function(d) {
                var icons = [
                    { n: d.totalCats||0,     t: '猫咪总数',   c: 'orange', e: '\u{1F431}' },
                    { n: d.schoolCats||0,    t: '在校猫咪',   c: 'green',  e: '\u{1F3EB}' },
                    { n: d.adoptedCats||0,   t: '已领养',     c: 'blue',   e: '\u{1F3E0}' },
                    { n: d.feedingCats||0,   t: '喂养中',     c: 'orange', e: '\u{1F36C}' },  // 新增
                    { n: d.totalUsers||0,    t: '用户总数',   c: 'purple', e: '\u{1F464}' },
                    { n: d.pendingAdoptions||0, t: '待审核申请', c: 'orange', e: '\u{23F3}' },
                    { n: d.approvedAdoptions||0, t: '已通过',  c: 'green',  e: '\u{2705}' },
                    { n: d.rejectedAdoptions||0, t: '已拒绝',  c: 'red',    e: '\u{274C}' },
                    { n: d.totalComments||0, t: '评论总数',   c: 'blue',   e: '\u{1F4AC}' }
                ];
                var h = '';
                icons.forEach(function(item) {
                    h += '<div class="stat-card">' +
                        '<div class="stat-icon-wrap ' + item.c + '">' + item.e + '</div>' +
                        '<div class="stat-body"><div class="stat-num">' + item.n + '</div><div class="stat-desc">' + item.t + '</div></div>' +
                        '</div>';
                });
                document.getElementById('statsRow').innerHTML = h;
            })
            .catch(function() { document.getElementById('statsRow').innerHTML = '<div style="color:#999;padding:20px;">数据加载失败</div>'; });

        fetch(ctx + '/adminAdoption')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var recent = data.slice(0, 5);
                var h = '';
                if (recent.length === 0) {
                    h = '<div style="color:#bbb;text-align:center;padding:20px;">暂无申请</div>';
                } else {
                    recent.forEach(function(a) {
                        var tag = '';
                        if (a.status === '\u5F85\u5BA1\u6838') tag = '<span class="tag tag-pending">\u5F85\u5BA1\u6838</span>';
                        else if (a.status === '\u5DF2\u901A\u8FC7') tag = '<span class="tag tag-ok">\u5DF2\u901A\u8FC7</span>';
                        else if (a.status === '\u5DF2\u62D2\u7EDD') tag = '<span class="tag tag-no">\u5DF2\u62D2\u7EDD</span>';
                        else tag = a.status;
                        h += '<div class="recent-item">' +
                            '<div class="recent-info"><strong>' + (a.catName||'') + '</strong> \u2014 ' + (a.applicantName||'') + '</div>' +
                            '<div>' + tag + ' <span class="recent-time">' + (a.applyDate?a.applyDate.substring(0,10):'') + '</span></div>' +
                            '</div>';
                    });
                }
                document.getElementById('recentList').innerHTML = h;
            })
            .catch(function() { document.getElementById('recentList').innerHTML = '<div style="color:#999;">加载失败</div>'; });
    }

    var _cats = [];
    function loadCats() {
        fetch(ctx + '/adminCat')
            .then(function(r) { return r.json(); })
            .then(function(d) { _cats = d; renderCatTable(); })
            .catch(function() { document.getElementById('catTbody').innerHTML = '<tr class="empty-row"><td colspan="9">加载失败</td></tr>'; });
    }
    function renderCatTable() {
        var kw = (document.getElementById('catSearch').value || '').toLowerCase();
        var list = _cats.filter(function(c) { return !kw || (c.name||'').toLowerCase().indexOf(kw) > -1; });
        var h = '';
        if (list.length === 0) {
            h = '<tr class="empty-row"><td colspan="9">暂无数据</td></tr>';
        } else {
            list.forEach(function(c) {
                var tag = c.state === '\u5728\u6821' ? '<span class="tag tag-ok">\u5728\u6821</span>' : '<span class="tag tag-info">\u5DF2\u9886\u517B</span>';
                var img = c.imagePath ? (ctx + '/' + c.imagePath) : '';
                h += '<tr>' +
                    '<td>' + c.id + '</td>' +
                    '<td>' + (img ? '<img src="' + img + '" style="width:40px;height:40px;border-radius:6px;object-fit:cover;" onerror="this.style.display=\'none\'">' : '') + '</td>' +
                    '<td><strong>' + (c.name||'') + '</strong></td>' +
                    '<td>' + (c.color||'') + '</td>' +
                    '<td>' + (c.age||0) + '\u6708</td>' +
                    '<td>' + (c.gender||'') + '</td>' +
                    '<td>' + tag + '</td>' +
                    '<td>' + (c.foundLocation||'') + '</td>' +
                    '<td class="cell-actions">' +
                    '<button class="btn btn-outline btn-sm" onclick="editCat(' + c.id + ')">\u7F16\u8F91</button>' +
                    '<button class="btn btn-danger btn-sm" onclick="deleteCat(' + c.id + ')">\u5220\u9664</button>' +
                    '</td></tr>';
            });
        }
        document.getElementById('catTbody').innerHTML = h;
    }
    function openCatForm() {
        document.getElementById('catModalTitle').textContent = '\u6DFB\u52A0\u732B\u5496';
        document.getElementById('catAction').value = 'add';
        document.getElementById('catId').value = '';
        document.getElementById('catForm').reset();
        document.getElementById('catModal').classList.add('show');
    }
    function editCat(id) {
        var c = _cats.find(function(x) { return x.id === id; });
        if (!c) return;
        document.getElementById('catModalTitle').textContent = '\u7F16\u8F91\u732B\u5496';
        document.getElementById('catAction').value = 'update';
        document.getElementById('catId').value = c.id;
        document.getElementById('catName').value = c.name || '';
        document.getElementById('catColor').value = c.color || '';
        document.getElementById('catAge').value = c.age || 0;
        document.getElementById('catGender').value = c.gender || '\u516C';
        document.getElementById('catHealth').value = c.healthStatus || '';
        document.getElementById('catDesc').value = c.description || '';
        document.getElementById('catLoc').value = c.foundLocation || '';
        document.getElementById('catDate').value = c.foundDate ? c.foundDate.substring(0,10) : '';
        document.getElementById('catImg').value = c.imagePath || '';
        document.getElementById('catModal').classList.add('show');
    }
    function closeCatForm() { document.getElementById('catModal').classList.remove('show'); }
    function submitCat(e) {
        e.preventDefault();
        var fd = new FormData(document.getElementById('catForm'));
        var body = new URLSearchParams(fd).toString();
        fetch(ctx + '/adminCat', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: body })
            .then(function(r) { return r.text(); })
            .then(function(msg) {
                if (msg === 'ok') { toast('\u64CD\u4F5C\u6210\u529F'); closeCatForm(); loadCats(); }
                else toast(msg, 'err');
            });
    }
    function deleteCat(id) {
        if (!confirm('\u786E\u5B9A\u8981\u5220\u9664\u8FD9\u53EA\u732B\u5496\u5417\uFF1F')) return;
        fetch(ctx + '/adminCat', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: 'action=delete&id=' + id })
            .then(function(r) { return r.text(); })
            .then(function(msg) {
                if (msg === 'ok') { toast('\u5DF2\u5220\u9664'); loadCats(); }
                else toast(msg, 'err');
            });
    }

    var _adoptions = [];
    function loadAdoptions() {
        fetch(ctx + '/adminAdoption')
            .then(function(r) { return r.json(); })
            .then(function(d) { _adoptions = d; renderAdoptionTable(); })
            .catch(function() { document.getElementById('adoptionTbody').innerHTML = '<tr class="empty-row"><td colspan="7">加载失败</td></tr>'; });
    }
    function renderAdoptionTable() {
        var filter = document.getElementById('adoptFilter').value;
        var list = _adoptions.filter(function(a) { return filter === 'all' || a.status === filter; });
        var h = '';
        if (list.length === 0) {
            h = '<tr class="empty-row"><td colspan="7">暂无数据</td></tr>';
        } else {
            list.forEach(function(a) {
                var tag = '';
                if (a.status === '\u5F85\u5BA1\u6838') tag = '<span class="tag tag-pending">\u5F85\u5BA1\u6838</span>';
                else if (a.status === '\u5DF2\u901A\u8FC7') tag = '<span class="tag tag-ok">\u5DF2\u901A\u8FC7</span>';
                else if (a.status === '\u5DF2\u62D2\u7EDD') tag = '<span class="tag tag-no">\u5DF2\u62D2\u7EDD</span>';
                else tag = a.status;
                var act = a.status === '\u5F85\u5BA1\u6838'
                    ? '<button class="btn btn-primary btn-sm" onclick="openReview(' + a.id + ')">\u5BA1\u6838</button>'
                    : '<span style="color:#bbb;font-size:12px;">\u5DF2\u5904\u7406</span>';
                h += '<tr>' +
                    '<td>' + a.id + '</td><td>' + (a.catName||'') + '</td><td>' + (a.applicantName||'') + '</td>' +
                    '<td>' + (a.applicantPhone||'') + '</td>' +
                    '<td style="font-size:12px;">' + (a.applyDate?a.applyDate.substring(0,10):'') + '</td>' +
                    '<td>' + tag + '</td><td class="cell-actions">' + act + '</td></tr>';
            });
        }
        document.getElementById('adoptionTbody').innerHTML = h;
    }
    function openReview(id) {
        document.getElementById('reviewId').value = id;
        document.getElementById('reviewNotes').value = '';
        document.getElementById('reviewModal').classList.add('show');
    }
    function closeReview() { document.getElementById('reviewModal').classList.remove('show'); }
    function doReview(status) {
        var id = document.getElementById('reviewId').value;
        var notes = document.getElementById('reviewNotes').value;
        var body = 'action=review&id=' + id + '&status=' + encodeURIComponent(status) + '&notes=' + encodeURIComponent(notes);
        fetch(ctx + '/adminAdoption', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: body })
            .then(function(r) { return r.text(); })
            .then(function(msg) {
                if (msg === 'ok') { toast('\u5BA1\u6838\u5B8C\u6210'); closeReview(); loadAdoptions(); loadOverview(); }
                else toast(msg, 'err');
            });
    }

    var _users = [];
    function loadUsers() {
        fetch(ctx + '/adminUser')
            .then(function(r) { return r.json(); })
            .then(function(d) { _users = d; renderUserTable(); })
            .catch(function() { document.getElementById('userTbody').innerHTML = '<tr class="empty-row"><td colspan="7">加载失败</td></tr>'; });
    }
    function renderUserTable() {
        var kw = (document.getElementById('userSearch').value || '').toLowerCase();
        var list = _users.filter(function(u) { return !kw || (u.username||'').toLowerCase().indexOf(kw) > -1; });
        var h = '';
        if (list.length === 0) {
            h = '<tr class="empty-row"><td colspan="7">暂无数据</td></tr>';
        } else {
            list.forEach(function(u) {
                h += '<tr>' +
                    '<td><strong>' + (u.username||'') + '</strong></td>' +
                    '<td>' + (u.phone||'-') + '</td><td>' + (u.email||'-') + '</td>' +
                    '<td>' + (u.address||'-') + '</td>' +
                    '<td style="font-size:12px;">' + (u.registerDate?u.registerDate.substring(0,10):'-') + '</td>' +
                    '<td style="font-size:12px;">' + (u.lastLogin?u.lastLogin.substring(0,10):'-') + '</td>' +
                    '<td class="cell-actions"><button class="btn btn-danger btn-sm" onclick="deleteUser(\'' + (u.username||'') + '\')">\u5220\u9664</button></td></tr>';
            });
        }
        document.getElementById('userTbody').innerHTML = h;
    }
    function deleteUser(uname) {
        if (!confirm('\u786E\u5B9A\u8981\u5220\u9664\u7528\u6237 \u201C' + uname + '\u201D \u5417\uFF1F\u6B64\u64CD\u4F5C\u4E0D\u53EF\u64A4\u9500\u3002')) return;
        fetch(ctx + '/adminUser', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: 'action=delete&username=' + encodeURIComponent(uname) })
            .then(function(r) { return r.text(); })
            .then(function(msg) {
                if (msg === 'ok') { toast('\u7528\u6237\u5DF2\u5220\u9664'); loadUsers(); loadOverview(); }
                else toast(msg, 'err');
            });
    }

    var _comments = [];
    function loadComments() {
        fetch(ctx + '/adminComment')
            .then(function(r) { return r.json(); })
            .then(function(d) { _comments = d; renderCommentTable(); })
            .catch(function() { document.getElementById('commentTbody').innerHTML = '<tr class="empty-row"><td colspan="6">加载失败</td></tr>'; });
    }
    function renderCommentTable() {
        var h = '';
        if (_comments.length === 0) {
            h = '<tr class="empty-row"><td colspan="6">暂无数据</td></tr>';
        } else {
            _comments.forEach(function(c) {
                h += '<tr>' +
                    '<td>' + c.id + '</td><td>' + c.catId + '</td><td>' + (c.username||'') + '</td>' +
                    '<td style="max-width:280px;">' + (c.comment||'') + '</td>' +
                    '<td style="font-size:12px;">' + (c.commentTime?c.commentTime.substring(0,16):'') + '</td>' +
                    '<td class="cell-actions"><button class="btn btn-danger btn-sm" onclick="deleteComment(' + c.id + ')">\u5220\u9664</button></td></tr>';
            });
        }
        document.getElementById('commentTbody').innerHTML = h;
    }
    function deleteComment(id) {
        if (!confirm('\u786E\u5B9A\u8981\u5220\u9664\u8FD9\u6761\u8BC4\u8BBA\u5417\uFF1F')) return;
        fetch(ctx + '/adminComment', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: 'action=delete&id=' + id })
            .then(function(r) { return r.text(); })
            .then(function(msg) {
                if (msg === 'ok') { toast('\u5DF2\u5220\u9664'); loadComments(); loadOverview(); }
                else toast(msg, 'err');
            });
    }

    function doLogout() {
        if (confirm('\u786E\u5B9A\u8981\u9000\u51FA\u767B\u5F55\u5417\uFF1F')) {
            window.location.href = ctx + '/logout';
        }
    }

    var _forumThreads = [];
    var _reports = [];
    function loadForumData() {
        fetch(ctx + '/adminForum').then(function(r){return r.json()}).then(function(d){_forumThreads=d;renderForumTable()});
        fetch(ctx + '/adminForum?type=reports').then(function(r){return r.json()}).then(function(d){_reports=d;renderReportTable()});
    }
    function renderForumTable() {
        var h='';
        if(_forumThreads.length===0){h='<tr class="empty-row"><td colspan="9">暂无帖子</td></tr>'}
        else{_forumThreads.forEach(function(t){
            h+='<tr><td>'+t.id+'</td><td><strong>'+(t.title||'')+'</strong></td><td>'+(t.userId||'')+'</td><td>'+(t.category||'')+'</td>'+
                '<td>'+(t.isPinned==1?'<span class="tag tag-ok">是</span>':'<span class="tag tag-no">否</span>')+'</td>'+
                '<td>'+(t.isHidden==1?'<span class="tag tag-pending">已隐藏</span>':'<span class="tag tag-ok">显示</span>')+'</td>'+
                '<td>'+t.likeCount+'/'+t.commentCount+'/'+t.viewCount+'</td>'+
                '<td style="font-size:12px;">'+(t.createdAt?t.createdAt.substring(0,10):'')+'</td>'+
                '<td class="cell-actions">'+
                '<button class="btn btn-sm '+(t.isPinned==1?'btn-outline':'btn-primary')+'" onclick="togglePin('+t.id+','+(t.isPinned==1?0:1)+')">'+(t.isPinned==1?'取消置顶':'置顶')+'</button>'+
                '<button class="btn btn-sm '+(t.isHidden==1?'btn-primary':'btn-outline')+'" onclick="toggleHide('+t.id+','+(t.isHidden==1?0:1)+')">'+(t.isHidden==1?'上架':'下架')+'</button>'+
                '<button class="btn btn-sm btn-danger" onclick="deleteForumThread('+t.id+')">删除</button>'+
                '</td></tr>';
        })}
        document.getElementById('forumTbody').innerHTML=h;
    }
    function togglePin(id,pinned){
        fetch(ctx+'/adminForum',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=pin&id='+id+'&pinned='+pinned})
            .then(function(r){return r.text()}).then(function(m){if(m==='ok')loadForumData()});
    }
    function toggleHide(id,hidden){
        fetch(ctx+'/adminForum',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=hide&id='+id+'&hidden='+hidden})
            .then(function(r){return r.text()}).then(function(m){if(m==='ok')loadForumData()});
    }
    function deleteForumThread(id){
        if(!confirm('确定删除此帖子？'))return;
        fetch(ctx+'/adminForum',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=delete&id='+id})
            .then(function(r){return r.text()}).then(function(m){if(m==='ok'){toast('已删除');loadForumData()}else toast(m,'err')});
    }
    function renderReportTable(){
        var h='';
        if(_reports.length===0){h='<tr class="empty-row"><td colspan="7">暂无举报</td></tr>'}
        else{_reports.forEach(function(r){
            var tag=r.status==='待处理'?'<span class="tag tag-pending">待处理</span>':(r.status==='已处理'?'<span class="tag tag-ok">已处理</span>':'<span class="tag tag-no">已驳回</span>');
            var act=r.status==='待处理'?'<button class="btn btn-primary btn-sm" onclick="openReportHandle('+r.id+','+r.threadId+')">处理</button>':'<span style="color:#bbb;font-size:12px;">已处理</span>';
            h+='<tr><td>'+r.id+'</td><td>'+(r.threadTitle||'')+'</td><td>'+(r.userId||'')+'</td><td>'+(r.reason||'')+'</td><td>'+tag+'</td><td style="font-size:12px;">'+(r.createdAt?r.createdAt.substring(0,10):'')+'</td><td class="cell-actions">'+act+'</td></tr>';
        })}
        document.getElementById('reportTbody').innerHTML=h;
    }
    function openReportHandle(id,threadId){
        document.getElementById('reportHandleId').value=id;
        document.getElementById('reportThreadId').value=threadId;
        document.getElementById('reportHandleNotes').value='';
        document.getElementById('reportHandleModal').classList.add('show');
    }
    function closeReportHandle(){document.getElementById('reportHandleModal').classList.remove('show');}
    function handleReport(status){
        var id=document.getElementById('reportHandleId').value;
        var threadId=document.getElementById('reportThreadId').value;
        var notes=document.getElementById('reportHandleNotes').value;
        fetch(ctx+'/adminForum',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=handleReport&id='+id+'&threadId='+threadId+'&status='+encodeURIComponent(status)+'&notes='+encodeURIComponent(notes)})
            .then(function(r){return r.text()}).then(function(m){if(m==='ok'){toast('处理完成');closeReportHandle();loadForumData()}else toast(m,'err')});
    }
    function openAdminPostForm(){document.getElementById('adminPostModal').classList.add('show')}
    function closeAdminPostForm(){document.getElementById('adminPostModal').classList.remove('show')}
    function submitAdminPost(e){
        e.preventDefault();
        var title=document.getElementById('adminPostTitle').value;
        var content=document.getElementById('adminPostContent').value;
        var category=document.getElementById('adminPostCat').value;
        fetch(ctx+'/adminForum',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=post&title='+encodeURIComponent(title)+'&content='+encodeURIComponent(content)+'&category='+encodeURIComponent(category)})
            .then(function(r){return r.text()}).then(function(m){if(m==='ok'){toast('发帖成功');closeAdminPostForm();loadForumData();document.getElementById('adminPostTitle').value='';document.getElementById('adminPostContent').value=''}else toast(m,'err')});
    }

    /* ========== 在线喂养管理 ========== */
    function loadFeedingList() {
        fetch(ctx + '/adminFeeding?action=list')
            .then(r => r.json())
            .then(data => {
                var tbody = document.getElementById('feedingTbody');
                if (data.length === 0) {
                    tbody.innerHTML = '<tr class="empty-row"><td colspan="4">暂无喂养中的猫咪</td></tr>';
                    return;
                }
                var html = '';
                data.forEach(function(row) {
                    var img = row.catImage ? (ctx + '/' + row.catImage) : '';
                    html += '<tr>' +
                        '<td style="display:flex;align-items:center;gap:8px;">' +
                        (img ? '<img src="' + img + '" style="width:36px;height:36px;border-radius:50%;object-fit:cover;">' : '') +
                        '<strong>' + (row.catName || '') + '</strong>' +
                        '</td>' +
                        '<td>' + (row.feeder || '') + '</td>' +
                        '<td style="font-size:12px;">' + (row.feedTime ? row.feedTime.substring(0,16) : '') + '</td>' +
                        '<td><button class="btn btn-success btn-sm" onclick="openFeedingComplete(' + row.catId + ',\'' + (row.feeder || '') + '\')">完成喂养</button></td>' +
                        '</tr>';
                });
                tbody.innerHTML = html;
            });
    }
    function openFeedingComplete(catId, feeder) {
        document.getElementById('completeCatId').value = catId;
        document.getElementById('completeFeeder').value = feeder;
        document.getElementById('completeMessage').value = '';
        document.getElementById('feedingCompleteModal').classList.add('show');
    }
    function closeFeedingComplete() {
        document.getElementById('feedingCompleteModal').classList.remove('show');
    }
    function submitFeedingComplete() {
        var catId = document.getElementById('completeCatId').value;
        var feeder = document.getElementById('completeFeeder').value;
        var message = document.getElementById('completeMessage').value;
        var imageFile = document.getElementById('completeImage').files[0];

        var formData = new FormData();
        formData.append('action', 'complete');
        formData.append('catId', catId);
        formData.append('feeder', feeder);
        formData.append('message', message);
        if (imageFile) {
            formData.append('image', imageFile);
        }

        fetch(ctx + '/adminFeeding', {
            method: 'POST',
            body: formData
        }).then(r => r.text()).then(msg => {
            if (msg === 'ok') {
                toast('喂养已完成并回复');
                closeFeedingComplete();
                loadFeedingList();
                loadOverview();
            } else {
                toast(msg, 'err');
            }
        });
    }

    /* ========== 商品管理 ========== */
    var _items = [];
    function loadItems() {
        fetch(ctx + '/adminItem')
            .then(r => r.json())
            .then(d => { _items = d; renderItemTable(); })
            .catch(() => { document.getElementById('itemTbody').innerHTML = '<tr class="empty-row"><td colspan="7">加载失败</td></tr>'; });
    }
    function renderItemTable() {
        var h = '';
        if (_items.length === 0) {
            h = '<tr class="empty-row"><td colspan="7">暂无商品</td></tr>';
        } else {
            _items.forEach(function(item) {
                var img = item.imagePath ? (ctx + '/' + item.imagePath) : '';
                var statusTag = item.status === '上架' ? '<span class="tag tag-ok">上架</span>' : '<span class="tag tag-no">下架</span>';
                var toggleBtn = item.status === '上架'
                    ? '<button class="btn btn-sm btn-danger" onclick="toggleItem('+item.id+',\'下架\')">下架</button>'
                    : '<button class="btn btn-sm btn-success" onclick="toggleItem('+item.id+',\'上架\')">上架</button>';
                h += '<tr>' +
                    '<td>' + (img ? '<img src="' + img + '" style="width:36px;height:36px;border-radius:6px;object-fit:cover;">' : '') + '</td>' +
                    '<td>' + item.name + '</td>' +
                    '<td>' + (item.description ? item.description.substring(0,20) : '') + '</td>' +
                    '<td>¥' + item.price.toFixed(2) + '</td>' +
                    '<td>' + item.category + '</td>' +
                    '<td>' + statusTag + '</td>' +
                    '<td class="cell-actions">' +
                    '<button class="btn btn-outline btn-sm" onclick="editItem(' + item.id + ')">编辑</button>' +
                    toggleBtn +
                    '<button class="btn btn-danger btn-sm" onclick="deleteItem(' + item.id + ')">删除</button>' +
                    '</td></tr>';
            });
        }
        document.getElementById('itemTbody').innerHTML = h;
    }
    function openItemForm() {
        document.getElementById('itemModalTitle').textContent = '添加商品';
        document.getElementById('itemAction').value = 'add';
        document.getElementById('itemId').value = '';
        document.getElementById('itemForm').reset();
        document.getElementById('itemModal').classList.add('show');
    }
    function editItem(id) {
        var item = _items.find(function(x) { return x.id === id; });
        if (!item) return;
        document.getElementById('itemModalTitle').textContent = '编辑商品';
        document.getElementById('itemAction').value = 'update';
        document.getElementById('itemId').value = item.id;
        document.getElementById('itemName').value = item.name;
        document.getElementById('itemDesc').value = item.description || '';
        document.getElementById('itemPrice').value = item.price;
        document.getElementById('itemImagePath').value = item.imagePath || '';
        document.getElementById('itemCategory').value = item.category;
        document.getElementById('itemModal').classList.add('show');
    }
    function closeItemForm() { document.getElementById('itemModal').classList.remove('show'); }
    function submitItem(e) {
        e.preventDefault();
        var id = document.getElementById('itemId').value;
        var action = document.getElementById('itemAction').value;
        var name = document.getElementById('itemName').value;
        var desc = document.getElementById('itemDesc').value;
        var price = document.getElementById('itemPrice').value;
        var img = document.getElementById('itemImagePath').value;
        var cat = document.getElementById('itemCategory').value;

        var body = 'action=' + action + '&name=' + encodeURIComponent(name) + '&description=' + encodeURIComponent(desc) +
            '&price=' + price + '&imagePath=' + encodeURIComponent(img) + '&category=' + encodeURIComponent(cat);
        if (action === 'update') body += '&id=' + id;

        fetch(ctx + '/adminItem', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: body })
            .then(r => r.text())
            .then(msg => {
                if (msg === 'ok') { toast('操作成功'); closeItemForm(); loadItems(); }
                else toast(msg, 'err');
            });
    }
    function toggleItem(id, status) {
        fetch(ctx + '/adminItem', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: 'action=toggle&id=' + id + '&status=' + status })
            .then(r => r.text())
            .then(msg => {
                if (msg === 'ok') { toast('状态已更新'); loadItems(); }
                else toast(msg, 'err');
            });
    }
    function deleteItem(id) {
        if (!confirm('确定删除该商品吗？')) return;
        fetch(ctx + '/adminItem', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body: 'action=delete&id=' + id })
            .then(r => r.text())
            .then(msg => {
                if (msg === 'ok') { toast('已删除'); loadItems(); }
                else toast(msg, 'err');
            });
    }

    loadOverview();
</script>
</body>
</html>