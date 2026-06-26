<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.dao.CatDAO" %>
<%@ page import="com.example.maomi.dao.FeedingRecordDAO" %>
<%@ page import="com.example.maomi.model.Cat" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    CatDAO catDAO = new CatDAO();
    FeedingRecordDAO frDAO = new FeedingRecordDAO();
    List<Cat> cats = catDAO.getAllCats();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>在线喂养 - 校园流浪猫管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #fffaf3;
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            position: relative;
            display: flex;
            flex-direction: column;
            height: 100vh;
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
        .user-badge { display: flex; align-items: center; gap: 8px; color: #8b5a10; font-weight: 600; }
        .logout-btn {
            background: none; border: 1px solid #e6a14c; color: #e6a14c;
            padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600;
            transition: 0.2s; margin-left: 15px;
        }
        .logout-btn:hover { background: #e6a14c; color: white; }

        .main-container { display: flex; flex: 1; overflow: hidden; min-height: 0; }
        .sidebar {
            width: 260px; background: #fefaf5; padding: 20px 15px;
            box-shadow: 2px 0 10px rgba(0,0,0,0.05);
            display: flex; flex-direction: column; overflow-y: auto;
        }
        .sidebar-header { text-align: center; margin-bottom: 20px; cursor: pointer; }
        .sidebar-avatar {
            width: 70px; height: 70px; border-radius: 50%; object-fit: cover;
            border: 3px solid #f0d9b5; margin-bottom: 8px;
        }
        .sidebar-username { font-weight: 700; color: #6f4518; font-size: 16px; position: relative; display: inline-block; }
        .sidebar h3 {
            color: #b87c2c; margin: 15px 0 10px; font-size: 18px;
            border-bottom: 1px solid #f0d9b5; padding-bottom: 8px;
        }
        .inventory-item {
            background: white; border-radius: 12px; padding: 8px; margin-bottom: 8px;
            display: flex; align-items: center; cursor: grab; border: 1px solid #f0d9b5;
            transition: transform 0.2s;
        }
        .inventory-item:active { cursor: grabbing; }
        .inventory-item img {
            width: 40px; height: 40px; border-radius: 8px; margin-right: 10px; object-fit: cover;
        }
        .inventory-item .info { flex: 1; }
        .inventory-item .name { font-weight: 700; color: #6f4518; font-size: 14px; }
        .inventory-item .qty { font-size: 12px; color: #b3904f; }

        .right-content { flex: 1; display: flex; flex-direction: column; padding: 25px; overflow-y: auto; }
        .right-content h2 { color: #6f4518; margin-bottom: 20px; }
        .cat-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px; flex: 1;
        }
        .cat-card {
            background: white; border-radius: 16px; padding: 12px; text-align: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05); transition: 0.3s;
            display: flex; flex-direction: column; align-items: center;
        }
        .cat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 18px rgba(0,0,0,0.08); }
        .cat-card img {
            width: 100px; height: 100px; border-radius: 50%; object-fit: cover;
            margin-bottom: 8px; border: 2px solid #f0d9b5;
        }
        .cat-card h4 { color: #6f4518; margin: 4px 0; font-size: 16px; }
        .cat-card p { color: #a68a64; font-size: 12px; margin: 2px 0; }
        .status {
            display: inline-block; padding: 2px 10px; border-radius: 12px;
            font-size: 12px; font-weight: 600; margin: 4px 0;
        }
        .status-school { background: #e6f7e6; color: #2d6a2d; }
        .status-feeding { background: #fff3cd; color: #856404; }
        .status-fed { background: #d4edda; color: #155724; }
        .feed-btn {
            margin-top: 6px; background: #e6a14c; color: white; border: none;
            border-radius: 18px; padding: 6px 16px; cursor: pointer; font-weight: 600;
            font-size: 13px; transition: 0.3s;
        }
        .feed-btn:hover { background: #c97d2a; }

        .cart-icon {
            position: fixed; bottom: 30px; right: 30px; background: #e6a14c;
            width: 55px; height: 55px; border-radius: 50%; display: flex;
            justify-content: center; align-items: center; font-size: 26px;
            color: white; box-shadow: 0 6px 18px rgba(0,0,0,0.2); cursor: pointer;
            z-index: 10; text-decoration: none; transition: 0.3s;
        }
        .cart-icon:hover { background: #c97d2a; transform: scale(1.1); }

        .feed-dialog-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: none; justify-content: center;
            align-items: center; z-index: 200;
        }
        .feed-dialog {
            background: white; border-radius: 18px; padding: 25px;
            width: 320px; box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .feed-dialog h3 { color: #6f4518; margin-bottom: 15px; }
        .feed-dialog select, .feed-dialog input {
            width: 100%; padding: 10px; border: 1px solid #f0d9b5;
            border-radius: 10px; margin-bottom: 12px;
        }
        /* 消息模态框样式 */
        .msg-modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: none; justify-content: center;
            align-items: center; z-index: 300;
        }
        .msg-modal {
            background: white; border-radius: 18px; padding: 25px;
            width: 400px; max-height: 400px; overflow-y: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .msg-modal h3 { color: #6f4518; margin-bottom: 15px; }
        .msg-item {
            border-bottom: 1px solid #f0d9b5; padding: 8px 0;
        }
        .msg-item .msg-content { font-size: 14px; color: #6f4518; }
        .msg-item .msg-time { font-size: 12px; color: #aaa; }
        /* 红点样式 */
        .msg-badge {
            display: none;
            background: red;
            color: white;
            border-radius: 50%;
            padding: 2px 6px;
            font-size: 12px;
            margin-left: 6px;
            vertical-align: middle;
        }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="nav-logo">🐾 校园流浪猫</div>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/pages/home.jsp">🏠 首页</a>
        <a href="<%= request.getContextPath() %>/myAdoptions">📋 我的领养</a>
        <a href="<%= request.getContextPath() %>/pages/forum.jsp">💬 论坛</a>
        <a href="<%= request.getContextPath() %>/knowledgeList">📖 知识科普</a>
        <a href="<%= request.getContextPath() %>/pages/feeding.jsp">🍼 在线喂养</a>
        <a href="<%= request.getContextPath() %>/pages/user_center.jsp">👤 个人中心</a>
    </div>
    <div class="user-badge">
        🐱 <%= sessionUser.getUsername() %>
        <button class="logout-btn" onclick="logout()">退出登录</button>
    </div>
</nav>

<div class="main-container">
    <div class="sidebar" id="inventoryPanel">
        <div class="sidebar-header" onclick="showFeedingMessages()" style="cursor:pointer;">
            <img class="sidebar-avatar"
                 src="<%= request.getContextPath() %>/avatar?name=<%= sessionUser.getProfileImage() != null ? sessionUser.getProfileImage() : "default.png" %>"
                 alt="头像"
                 onerror="this.src='<%= request.getContextPath() %>/uploads/avatars/default.png'">
            <div class="sidebar-username">
                <%= sessionUser.getUsername() %>
                <span id="msgBadge" class="msg-badge">0</span>
            </div>
        </div>
        <h3>🎒 我的储物柜</h3>
        <div id="inventoryList"></div>
    </div>

    <div class="right-content">
        <h2>🐱 等待投喂的小可爱</h2>
        <div class="cat-grid">
            <% for (Cat cat : cats) {
                if ("已领养".equals(cat.getState())) continue;

                String feeder = null;
                if ("喂养中".equals(cat.getState())) {
                    feeder = frDAO.getLastFeedingUserByCatId(cat.getId());
                }
            %>
            <div class="cat-card" data-catid="<%= cat.getId() %>"
                 ondragover="allowDrop(event)" ondrop="dropFeed(event)">
                <img src="<%= request.getContextPath() + "/" + cat.getImagePath() %>" alt="<%= cat.getName() %>">
                <h4><%= cat.getName() %></h4>
                <p><%= cat.getGender() %> | <%= cat.getAge() %>个月 | <%= cat.getHealthStatus() %></p>
                <span class="status
                        <%= "在校".equals(cat.getState()) ? "status-school" :
                            ("喂养中".equals(cat.getState()) ? "status-feeding" :
                             ("已喂养".equals(cat.getState()) ? "status-fed" : "status-school")) %>"
                      id="catState-<%= cat.getId() %>">
                        <%= cat.getState() %>
                    </span>
                <% if (feeder != null) { %>
                <p style="font-size:11px; color:#856404; margin-top:3px;">🤱 喂养人：<%= feeder %></p>
                <% } %>
                <button class="feed-btn" onclick="openFeedDialog(<%= cat.getId() %>)">🍽️ 喂养</button>
            </div>
            <% } %>
        </div>
    </div>
</div>

<a class="cart-icon" href="<%= request.getContextPath() %>/pages/cart.jsp">🛒</a>

<div class="feed-dialog-overlay" id="feedDialog">
    <div class="feed-dialog">
        <h3>选择喂养物品</h3>
        <select id="feedItemSelect"></select>
        <input type="number" id="feedQty" value="1" min="1" placeholder="数量">
        <div style="display: flex; justify-content: space-between; margin-top: 15px;">
            <button class="feed-btn" onclick="submitFeed()" style="width: 48%;">确认喂养</button>
            <button class="feed-btn" onclick="closeFeedDialog()" style="width: 48%; background: #aaa;">取消</button>
        </div>
    </div>
</div>

<!-- 查看管理员回复的消息模态框 -->
<div class="msg-modal-overlay" id="messagesModal">
    <div class="msg-modal">
        <span style="float:right; cursor:pointer; font-size: 20px;" onclick="closeMessages()">&times;</span>
        <h3>💬 管理员回复</h3>
        <div id="messagesList"></div>
    </div>
</div>

<script>
    // 存储库存数据，供喂养时检查
    window.inventoryData = [];

    // 加载库存
    function loadInventory() {
        fetch('<%= request.getContextPath() %>/getInventory')
            .then(res => res.json())
            .then(data => {
                window.inventoryData = data;   // 缓存库存
                var container = document.getElementById('inventoryList');
                var html = '';
                data.forEach(item => {
                    html +=
                        '<div class="inventory-item" draggable="true" ondragstart="dragStart(event)" data-itemid="' + item.itemId + '">' +
                        '<img src="<%= request.getContextPath() %>/' + item.image + '" onerror="this.src=\'images/default_item.png\'">' +
                        '<div class="info">' +
                        '<div class="name">' + item.name + '</div>' +
                        '<div class="qty">数量：' + item.quantity + '</div>' +
                        '</div>' +
                        '</div>';
                });
                container.innerHTML = html;
            });
    }

    // 检查库存是否为空的通用方法
    function checkInventoryEmpty() {
        if (!window.inventoryData || window.inventoryData.length === 0) {
            alert('您的储物柜中还没有商品，请先去商城购买~');
            window.location.href = '<%= request.getContextPath() %>/pages/cart.jsp';
            return true;
        }
        return false;
    }

    var draggedItemId = null;
    function dragStart(e) {
        draggedItemId = e.target.closest('.inventory-item').dataset.itemid;
        e.dataTransfer.setData('text/plain', draggedItemId);
    }
    function allowDrop(e) { e.preventDefault(); }

    function dropFeed(e) {
        e.preventDefault();
        var catCard = e.target.closest('.cat-card');
        if (!catCard) return;
        var catId = catCard.dataset.catid;
        if (!draggedItemId) return;

        // 检查库存
        if (checkInventoryEmpty()) return;

        var stateElem = document.getElementById('catState-' + catId);
        if (!stateElem) return;
        var state = stateElem.innerText.trim();
        if (state === '喂养中' || state === '已喂养') {
            alert('猫咪已经在喂养啦');
            return;
        }
        performFeed(catId, draggedItemId, 1);
    }

    function performFeed(catId, itemId, qty) {
        var stateElem = document.getElementById('catState-' + catId);
        if (stateElem) {
            var state = stateElem.innerText.trim();
            if (state === '喂养中' || state === '已喂养') {
                alert('猫咪已经在喂养啦');
                return;
            }
        }
        fetch('<%= request.getContextPath() %>/feedCat', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'catId=' + catId + '&itemId=' + itemId + '&quantity=' + qty
        }).then(res => res.text()).then(msg => {
            if (msg === 'ok') {
                alert('喂养成功！');
                location.reload();
            } else {
                alert(msg);
            }
        });
    }

    var currentFeedCatId = null;
    function openFeedDialog(catId) {
        currentFeedCatId = catId;

        // 检查库存
        if (checkInventoryEmpty()) return;

        var stateElem = document.getElementById('catState-' + catId);
        if (stateElem) {
            var state = stateElem.innerText.trim();
            if (state === '喂养中' || state === '已喂养') {
                alert('猫咪已经在喂养啦');
                return;
            }
        }
        fetch('<%= request.getContextPath() %>/getInventory')
            .then(res => res.json())
            .then(data => {
                var select = document.getElementById('feedItemSelect');
                select.innerHTML = '';
                data.forEach(item => {
                    select.innerHTML += '<option value="' + item.itemId + '">' + item.name + ' (剩余：' + item.quantity + ')</option>';
                });
                document.getElementById('feedDialog').style.display = 'flex';
            });
    }
    function closeFeedDialog() { document.getElementById('feedDialog').style.display = 'none'; }
    function submitFeed() {
        var itemId = document.getElementById('feedItemSelect').value;
        var qty = document.getElementById('feedQty').value;
        if (!itemId || !qty || qty < 1) {
            alert('请选择商品并输入有效数量');
            return;
        }
        performFeed(currentFeedCatId, itemId, qty);
        closeFeedDialog();
    }

    // 检查未读消息并显示红点
    function checkUnreadMessages() {
        fetch('<%= request.getContextPath() %>/getFeedingMessages?action=unreadCount')
            .then(res => res.json())
            .then(data => {
                var badge = document.getElementById('msgBadge');
                if (data.count > 0) {
                    badge.style.display = 'inline-block';
                    badge.innerText = data.count;
                } else {
                    badge.style.display = 'none';
                }
            });
    }

    // 查看管理员回复消息（同时标记已读）
    function showFeedingMessages() {
        // 标记已读
        fetch('<%= request.getContextPath() %>/getFeedingMessages', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=markRead'
        }).then(() => {
            var badge = document.getElementById('msgBadge');
            badge.style.display = 'none';
        });

        // 加载消息列表
        fetch('<%= request.getContextPath() %>/getFeedingMessages')
            .then(res => res.json())
            .then(data => {
                var container = document.getElementById('messagesList');
                if (data.length === 0) {
                    container.innerHTML = '<div style="color:#aaa;">暂无消息</div>';
                } else {
                    var html = '';
                    data.forEach(function(m) {
                        var imgTag = '';
                        if (m.imagePath) {
                            imgTag = '<div><img src="<%= request.getContextPath() %>/' + m.imagePath + '" style="max-width:100%; margin-top:5px; border-radius:8px;"></div>';
                        }
                        html += '<div class="msg-item">' +
                            '<div style="font-weight:700; color:#b87c2c;">猫咪：' + (m.catName || '未知') + '</div>' +
                            '<div class="msg-content">' + (m.message || '无内容') + '</div>' +
                            imgTag +
                            '<div class="msg-time">' + (m.createdAt ? m.createdAt.substring(0,16) : '') + '</div>' +
                            '</div>';
                    });
                    container.innerHTML = html;
                }
                document.getElementById('messagesModal').style.display = 'flex';
            });
    }
    function closeMessages() { document.getElementById('messagesModal').style.display = 'none'; }

    function logout() {
        if (confirm('确定要退出登录吗？')) {
            window.location.href = '<%= request.getContextPath() %>/logout';
        }
    }

    window.onload = function() {
        loadInventory();
        checkUnreadMessages();
        setInterval(checkUnreadMessages, 30000);
    };
</script>
</body>
</html>