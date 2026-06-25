<%@ page import="com.example.maomi.dao.CatDAO" %>
<%@ page import="com.example.maomi.model.Cat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.maomi.model.User" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.example.maomi.dao.FavoriteDAO" %>
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
  // 获取当前用户收藏的猫咪ID集合
  FavoriteDAO favDAO = new FavoriteDAO();
  Set<Integer> favoriteCatIds = favDAO.getFavoriteCatIds(sessionUser.getUsername());
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>猫咪大家庭 - 校园流浪猫管理</title>
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

    /* 轮播图容器 */
    .carousel-container {
      max-width: 1200px;
      margin: 30px auto 20px;
      position: relative;
      border-radius: 24px;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0,0,0,0.08);
      background: #fff;
    }
    .carousel-slides {
      display: flex;
      transition: transform 0.5s ease-in-out;
      width: 100%;
    }
    .carousel-slide {
      min-width: 100%;
      height: 400px;
      background-size: cover;
      background-position: center;
      cursor: pointer;
      position: relative;
    }
    .carousel-slide::after {
      content: '';
      position: absolute;
      bottom: 0; left: 0; right: 0;
      height: 80px;
      background: linear-gradient(transparent, rgba(0,0,0,0.4));
    }
    .carousel-dots {
      position: absolute; bottom: 15px; left: 50%; transform: translateX(-50%);
      display: flex; gap: 8px;
    }
    .carousel-dot {
      width: 10px; height: 10px; border-radius: 50%;
      background: rgba(255,255,255,0.5); cursor: pointer; transition: background 0.3s;
    }
    .carousel-dot.active { background: #e6a14c; width: 24px; border-radius: 5px; }
    .carousel-arrow {
      position: absolute; top: 50%; transform: translateY(-50%);
      background: rgba(255,255,255,0.7); border: none; font-size: 24px;
      padding: 10px 14px; cursor: pointer; border-radius: 50%;
      color: #b87c2c; font-weight: bold; transition: background 0.3s;
    }
    .carousel-arrow:hover { background: rgba(255,255,255,0.95); }
    .carousel-arrow.left { left: 10px; }
    .carousel-arrow.right { right: 10px; }

    /* 搜索框 */
    .search-area { text-align: center; margin: 10px 0 25px; }
    .search-area input {
      padding: 12px 20px; width: 320px; border: 2px solid #f0d9b5;
      border-radius: 30px; background: white; font-size: 15px; outline: none; transition: 0.3s;
    }
    .search-area input:focus { border-color: #e6a14c; box-shadow: 0 0 0 4px rgba(230,161,76,0.15); }
    .search-area button {
      padding: 12px 22px; background: #e6a14c; color: white;
      border: none; border-radius: 30px; font-weight: 700; margin-left: 10px;
      cursor: pointer; transition: 0.3s;
    }
    .search-area button:hover { background: #c97d2a; }

    /* 猫咪卡片网格 */
    .cat-grid {
      display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 25px; padding: 0 40px 50px; max-width: 1200px; margin: 0 auto;
    }
    .cat-card {
      background: white; border-radius: 22px; overflow: hidden;
      box-shadow: 0 8px 22px rgba(0,0,0,0.06); transition: 0.3s;
      display: flex; flex-direction: column;
    }
    .cat-card:hover { transform: translateY(-5px); box-shadow: 0 15px 30px rgba(0,0,0,0.1); }
    .cat-image { width: 100%; height: 200px; object-fit: cover; }
    .cat-info { padding: 16px; flex: 1; }
    .cat-name { font-size: 20px; font-weight: 700; color: #6f4518; }
    .cat-meta { color: #a68a64; font-size: 14px; margin: 5px 0; }
    .state-badge {
      display: inline-block; padding: 3px 12px; border-radius: 15px;
      font-size: 13px; font-weight: 600; margin-top: 8px;
    }
    .state-school { background: #e6f7e6; color: #2d6a2d; }
    .state-adopted { background: #fde8d0; color: #b85c1a; }
    .fav-icon {
      font-size: 22px; color: #f4b26a; cursor: pointer; margin-left: 10px;
      vertical-align: middle; transition: 0.2s; display: inline-block;
    }
    .fav-icon.favorited { color: #e6a14c; }
    .fav-icon:hover { transform: scale(1.2); }

    /* 模态框 */
    .modal-overlay {
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.5); display: none; justify-content: center;
      align-items: center; z-index: 200;
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
    .adopt-btn, .disabled-btn {
      width: 100%; padding: 12px; border-radius: 12px; border: none;
      font-weight: 700; margin-top: 10px; cursor: pointer;
    }
    .adopt-btn { background: #e6a14c; color: white; }
    .adopt-btn:hover { background: #c97d2a; }
    .disabled-btn { background: #f0d9b5; color: #8b5a10; cursor: not-allowed; }
    #adoptFormArea {
      background: #fef9f2; border-radius: 18px; padding: 20px;
      margin-top: 15px; border: 1px solid #f5e0c4;
    }
    #adoptFormArea h4 { margin: 0 0 15px 0; color: #b87c2c; font-size: 17px; }
    #adoptFormArea label { display: block; font-size: 13px; color: #b3904f; margin-bottom: 4px; margin-top: 12px; font-weight: 600; }
    #adoptFormArea input,
    #adoptFormArea textarea {
      width: 100%; padding: 10px 14px; border: 1.5px solid #f0d9b5;
      border-radius: 12px; font-size: 14px; background: #fffef9; transition: 0.3s;
      outline: none; resize: vertical;
    }
    #adoptFormArea input:focus,
    #adoptFormArea textarea:focus {
      border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.12); background: #fff;
    }
    #adoptFormArea .adopt-btn {
      margin-top: 18px; background: linear-gradient(135deg, #f4b26a, #e6a14c);
      box-shadow: 0 6px 16px rgba(230,161,76,0.25); border-radius: 14px;
      font-size: 15px; transition: 0.3s;
    }
    #adoptFormArea .adopt-btn:hover {
      background: linear-gradient(135deg, #e6a14c, #c97d2a);
      transform: translateY(-1px); box-shadow: 0 8px 20px rgba(230,161,76,0.35);
    }
    .logout-btn {
      background: none; border: 1px solid #e6a14c; color: #e6a14c;
      padding: 5px 15px; border-radius: 20px; cursor: pointer; font-weight: 600;
      transition: 0.2s; margin-left: 15px;
    }
    .logout-btn:hover { background: #e6a14c; color: white; }
  </style>
</head>
<body>
<!-- 导航栏 -->
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

<!-- 轮播图 -->
<% if (cats != null && !cats.isEmpty()) { %>
<div class="carousel-container">
  <div class="carousel-slides" id="carouselSlides">
    <% for (Cat cat : cats) { %>
    <div class="carousel-slide" style="background-image: url('<%= request.getContextPath() + "/" + cat.getImagePath() %>');" data-catid="<%= cat.getId() %>" onclick="openCatModal(<%= cat.getId() %>)"></div>
    <% } %>
  </div>
  <button class="carousel-arrow left" onclick="prevSlide()">&#10094;</button>
  <button class="carousel-arrow right" onclick="nextSlide()">&#10095;</button>
  <div class="carousel-dots" id="carouselDots">
    <% for (int i = 0; i < cats.size(); i++) { %>
    <span class="carousel-dot <%= i == 0 ? "active" : "" %>" onclick="goToSlide(<%= i %>)"></span>
    <% } %>
  </div>
</div>
<% } %>

<!-- 搜索框 -->
<div class="search-area">
  <input type="text" id="searchInput" placeholder="搜索猫咪名字...">
  <button onclick="searchCat()">🔍 搜索</button>
</div>

<!-- 猫咪卡片 -->
<div class="cat-grid">
  <% for (Cat cat : cats) { %>
  <div class="cat-card" data-catname="<%= cat.getName() %>" data-catid="<%= cat.getId() %>" onclick="openCatModal(<%= cat.getId() %>)" style="cursor:pointer;">
    <img class="cat-image" src="<%= request.getContextPath() + "/" + cat.getImagePath() %>" alt="<%= cat.getName() %>">
    <div class="cat-info">
      <div class="cat-name"><%= cat.getName() %></div>
      <div class="cat-meta">
        <%= cat.getGender() %> | <%= cat.getAge() %>个月 | <%= cat.getColor() %>
      </div>
      <span class="state-badge <%= "在校".equals(cat.getState()) ? "state-school" : "state-adopted" %>">
        <%= cat.getState() %>
      </span>
      <span class="fav-icon <%= favoriteCatIds.contains(cat.getId()) ? "favorited" : "" %>"
            id="fav-icon-<%= cat.getId() %>"
            onclick="event.stopPropagation(); toggleFavorite(<%= cat.getId() %>)"
            title="<%= favoriteCatIds.contains(cat.getId()) ? "取消收藏" : "收藏" %>">
        <%= favoriteCatIds.contains(cat.getId()) ? "★" : "☆" %>
      </span>
    </div>
  </div>
  <% } %>
</div>

<!-- 猫咪详情模态框（已移除留言板块） -->
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
  // 轮播图逻辑
  var currentSlide = 0;
  var slides = document.querySelectorAll('.carousel-slide');
  var dots = document.querySelectorAll('.carousel-dot');
  var totalSlides = slides.length;

  function showSlide(index) {
    if (index >= totalSlides) currentSlide = 0;
    else if (index < 0) currentSlide = totalSlides - 1;
    else currentSlide = index;
    document.getElementById('carouselSlides').style.transform = 'translateX(-' + (currentSlide * 100) + '%)';
    dots.forEach((dot, i) => dot.classList.toggle('active', i === currentSlide));
  }

  function nextSlide() { showSlide(currentSlide + 1); }
  function prevSlide() { showSlide(currentSlide - 1); }
  function goToSlide(index) { showSlide(index); }

  if (totalSlides > 1) setInterval(nextSlide, 4000);

  // 搜索功能
  function searchCat() {
    var keyword = document.getElementById('searchInput').value.trim().toLowerCase();
    var cards = document.querySelectorAll('.cat-card');
    cards.forEach(function(card) {
      var name = card.getAttribute('data-catname').toLowerCase();
      card.style.display = name.indexOf(keyword) > -1 ? '' : 'none';
    });
  }

  // 猫咪详情模态框逻辑
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

  // 收藏功能
  function toggleFavorite(catId) {
    fetch('<%= request.getContextPath() %>/toggleFavorite', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'catId=' + catId
    })
            .then(res => res.text())
            .then(result => {
              var icon = document.getElementById('fav-icon-' + catId);
              if (result === 'added') {
                icon.innerText = '★';
                icon.classList.add('favorited');
                icon.title = '取消收藏';
              } else if (result === 'removed') {
                icon.innerText = '☆';
                icon.classList.remove('favorited');
                icon.title = '收藏';
              } else if (result === 'login') {
                alert('请先登录');
              }
            });
  }

  // 退出登录
  function logout() {
    if (confirm('确定要退出登录吗？')) {
      window.location.href = '<%= request.getContextPath() %>/logout';
    }
  }
</script>
</body>
</html>