<%@ page import="com.example.maomi.dao.CatDAO" %>
<%@ page import="com.example.maomi.model.Cat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.maomi.model.User" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
  // 检查登录状态
  User sessionUser = (User) session.getAttribute("user");
  if (sessionUser == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
  }
  // 获取猫咪列表
  CatDAO catDAO = new CatDAO();
  List<Cat> cats = catDAO.getAllCats();  // 所有猫咪（含已领养）
  // 统计数据
  int totalCats = cats.size();
  int adoptedCount = 0;
  for (Cat c : cats) {
    if ("已领养".equals(c.getState())) adoptedCount++;
  }
  int availableCount = totalCats - adoptedCount;
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>猫咪大家庭 - 校园流浪猫管理</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: #fffaf3; /* 暖杏色底 */
      font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
      position: relative;
    }
    /* 背景柔光图案（使用与登录页类似的图片，低透明度） */
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
    .nav-logo {
      font-size: 22px;
      font-weight: 700;
      color: #b87c2c;
      letter-spacing: 1px;
    }
    .nav-links {
      display: flex;
      gap: 25px;
    }
    .nav-links a {
      text-decoration: none;
      color: #a66a1a;
      font-weight: 600;
      padding: 6px 14px;
      border-radius: 20px;
      transition: 0.2s;
      font-size: 15px;
    }
    .nav-links a:hover {
      background: #ffeed9;
      color: #8b5a10;
    }
    .user-badge {
      display: flex;
      align-items: center;
      gap: 8px;
      color: #8b5a10;
      font-weight: 600;
    }
    /* 统计卡片区 */
    .stats-row {
      display: flex;
      justify-content: center;
      gap: 30px;
      padding: 30px 20px 10px;
    }
    .stat-card {
      background: white;
      border-radius: 20px;
      padding: 20px 30px;
      text-align: center;
      box-shadow: 0 8px 20px rgba(0,0,0,0.04);
      min-width: 140px;
      transition: 0.3s;
    }
    .stat-card:hover { transform: translateY(-3px); }
    .stat-number {
      font-size: 32px;
      font-weight: 700;
      color: #e6a14c;
    }
    .stat-label {
      color: #b3904f;
      font-size: 14px;
      margin-top: 4px;
    }
    /* 搜索框 */
    .search-area {
      text-align: center;
      margin: 10px 0 25px;
    }
    .search-area input {
      padding: 12px 20px;
      width: 320px;
      border: 2px solid #f0d9b5;
      border-radius: 30px;
      background: white;
      font-size: 15px;
      outline: none;
      transition: 0.3s;
    }
    .search-area input:focus {
      border-color: #e6a14c;
      box-shadow: 0 0 0 4px rgba(230,161,76,0.15);
    }
    .search-area button {
      padding: 12px 22px;
      background: #e6a14c;
      color: white;
      border: none;
      border-radius: 30px;
      font-weight: 700;
      margin-left: 10px;
      cursor: pointer;
      transition: 0.3s;
    }
    .search-area button:hover { background: #c97d2a; }
    /* 猫咪卡片网格 */
    .cat-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 25px;
      padding: 0 40px 50px;
      max-width: 1200px;
      margin: 0 auto;
    }
    .cat-card {
      background: white;
      border-radius: 22px;
      overflow: hidden;
      box-shadow: 0 8px 22px rgba(0,0,0,0.06);
      transition: 0.3s;
      display: flex;
      flex-direction: column;
    }
    .cat-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 15px 30px rgba(0,0,0,0.1);
    }
    .cat-image {
      width: 100%;
      height: 200px;
      object-fit: cover;
    }
    .cat-info {
      padding: 16px;
      flex: 1;
    }
    .cat-name {
      font-size: 20px;
      font-weight: 700;
      color: #6f4518;
    }
    .cat-meta {
      color: #a68a64;
      font-size: 14px;
      margin: 5px 0;
    }
    .state-badge {
      display: inline-block;
      padding: 3px 12px;
      border-radius: 15px;
      font-size: 13px;
      font-weight: 600;
      margin-top: 8px;
    }
    .state-school { background: #e6f7e6; color: #2d6a2d; }
    .state-adopted { background: #fde8d0; color: #b85c1a; }
    .comment-section {
      border-top: 1px solid #f3e0cc;
      padding: 14px 16px;
      background: #fefaf5;
    }
    .comment-list {
      max-height: 100px;
      overflow-y: auto;
      margin-bottom: 8px;
      font-size: 13px;
    }
    .comment-item {
      padding: 4px 0;
      color: #6f4518;
      border-bottom: 1px dashed #f0d9b5;
    }
    .comment-item strong {
      color: #e6a14c;
    }
    .comment-input {
      display: flex;
      gap: 8px;
    }
    .comment-input input {
      flex: 1;
      padding: 8px 12px;
      border: 1px solid #f0d9b5;
      border-radius: 15px;
      font-size: 13px;
    }
    .comment-input button {
      padding: 8px 14px;
      background: #e6a14c;
      color: white;
      border: none;
      border-radius: 15px;
      cursor: pointer;
      font-weight: 600;
    }
  </style>
</head>
<body>
<!-- 导航栏 -->
<nav class="navbar">
  <div class="nav-logo">🐾 校园流浪猫</div>
  <div class="nav-links">
    <a href="user_center.jsp">👤 个人中心</a>
    <a href="my_adoptions.jsp">📋 我的领养</a>
    <a href="forum.jsp">💬 论坛</a>
    <a href="knowledge.jsp">📖 知识科普</a>
  </div>
  <div class="user-badge">
    🐱 <%= sessionUser.getUsername() %>
  </div>
</nav>

<!-- 统计卡片 -->
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

<!-- 搜索框 -->
<div class="search-area">
  <input type="text" id="searchInput" placeholder="搜索猫咪名字...">
  <button onclick="searchCat()">🔍 搜索</button>
</div>

<!-- 猫咪卡片 -->
<div class="cat-grid">
  <% for (Cat cat : cats) { %>
  <div class="cat-card" data-catname="<%= cat.getName() %>">
    <img class="cat-image" src="<%= request.getContextPath() + "/" + cat.getImagePath() %>" alt="<%= cat.getName() %>">
    <div class="cat-info">
      <div class="cat-name"><%= cat.getName() %></div>
      <div class="cat-meta">
        <%= cat.getGender() %> | <%= cat.getAge() %>个月 | <%= cat.getColor() %>
      </div>
      <span class="state-badge <%= "在校".equals(cat.getState()) ? "state-school" : "state-adopted" %>">
                    <%= cat.getState() %>
                </span>
    </div>
    <!-- 留言区 -->
    <div class="comment-section">
      <div class="comment-list" id="comments-<%= cat.getId() %>">
        <!-- 留言将动态加载 -->
      </div>
      <div class="comment-input">
        <input type="text" id="commentInput-<%= cat.getId() %>" placeholder="留下你的关心...">
        <button onclick="addComment(<%= cat.getId() %>)">发送</button>
      </div>
    </div>
  </div>
  <% } %>
</div>

<script>
  // 页面加载时，为每只猫咪加载留言
  window.onload = function() {
    var cards = document.querySelectorAll('.cat-card');
    cards.forEach(function(card) {
      // 从 data-catname 或 id 获取猫咪ID (这里从评论区id解析)
      var commentDiv = card.querySelector('.comment-list');
      var id = commentDiv.id.split('-')[1];
      loadComments(id);
    });
  };

  // 加载某只猫咪的留言
  function loadComments(catId) {
    fetch('<%= request.getContextPath() %>/getComments?catId=' + catId)
            .then(response => response.json())
            .then(data => {
              var container = document.getElementById('comments-' + catId);
              container.innerHTML = '';
              if (data.length === 0) {
                container.innerHTML = '<div style="color:#aaa; font-size:12px;">暂无留言，快来关爱它吧~</div>';
              } else {
                data.forEach(function(c) {
                  container.innerHTML += '<div class="comment-item"><strong>' + c.username + ':</strong> ' + c.comment + '</div>';
                });
              }
            })
            .catch(err => console.error('加载留言失败', err));
  }

  // 添加留言
  function addComment(catId) {
    var input = document.getElementById('commentInput-' + catId);
    var text = input.value.trim();
    if (!text) return;
    fetch('<%= request.getContextPath() %>/addComment', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'catId=' + catId + '&comment=' + encodeURIComponent(text)
    })
            .then(res => res.text())
            .then(msg => {
              if (msg === 'ok') {
                input.value = '';
                loadComments(catId); // 刷新留言
              } else {
                alert('留言失败，请重试');
              }
            });
  }

  // 搜索功能（简单的前端过滤，也可提交到后端搜索）
  function searchCat() {
    var keyword = document.getElementById('searchInput').value.trim().toLowerCase();
    var cards = document.querySelectorAll('.cat-card');
    cards.forEach(function(card) {
      var name = card.getAttribute('data-catname').toLowerCase();
      if (name.indexOf(keyword) > -1) {
        card.style.display = '';
      } else {
        card.style.display = 'none';
      }
    });
  }
</script>
</body>
</html>