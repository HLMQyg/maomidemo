<%@ page import="com.example.maomi.model.User" %>
<%@ page import="com.example.maomi.dao.CartDAO" %>
<%@ page import="com.example.maomi.dao.ItemDAO" %>
<%@ page import="com.example.maomi.model.CartItem" %>
<%@ page import="com.example.maomi.model.Item" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
  User sessionUser = (User) session.getAttribute("user");
  if (sessionUser == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
  }
  ItemDAO itemDAO = new ItemDAO();
  List<Item> items = itemDAO.getAllItems();   // 已过滤上架商品
  CartDAO cartDAO = new CartDAO();
  List<CartItem> cartItems = cartDAO.getByUsername(sessionUser.getUsername());
  double total = 0;
  for (CartItem item : cartItems) {
    total += item.getQuantity() * item.getItemPrice();
  }

  // 将数据库中的细分类合并为5个大类
  Map<String, String> categoryMap = new HashMap<>();
  categoryMap.put("猫粮", "猫粮");
  categoryMap.put("猫罐头", "猫罐头");
  categoryMap.put("猫条", "猫零食");
  categoryMap.put("冻干零食", "猫零食");
  categoryMap.put("猫饼干", "猫零食");
  categoryMap.put("磨牙零食", "猫零食");
  categoryMap.put("功能性零食", "猫零食");
  categoryMap.put("猫草", "猫零食");
  categoryMap.put("宠物奶", "营养品");
  categoryMap.put("营养膏", "营养品");
  categoryMap.put("猫玩具", "猫玩具");
  categoryMap.put("湿粮包", "猫零食");  // 湿粮包归入猫零食
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>校园猫粮铺 - 流浪猫管理</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: #fffaf3;
      font-family: "Microsoft YaHei", sans-serif;
      position: relative;
    }
    body::before {
      content: "";
      position: fixed; top: 0; left: 0;
      width: 100%; height: 100%;
      background: url('../images/login-bg.jpg') center/cover no-repeat;
      opacity: 0.08; z-index: -1; pointer-events: none;
    }
    .navbar {
      background: rgba(255,250,240,0.92); backdrop-filter: blur(12px);
      box-shadow: 0 2px 15px rgba(0,0,0,0.06); padding: 12px 30px;
      display: flex; align-items: center; justify-content: space-between;
      position: sticky; top: 0; z-index: 100;
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
      padding: 5px 15px; border-radius: 20px; cursor: pointer; margin-left: 15px;
    }
    .container { max-width: 1000px; margin: 30px auto; padding: 20px; }
    .section-title {
      color: #6f4518; margin: 25px 0 15px; font-size: 22px;
      border-bottom: 2px solid #f0d9b5; padding-bottom: 8px;
    }
    .search-category {
      display: flex; flex-direction: column; gap: 12px; margin-bottom: 25px;
    }
    .search-box {
      display: flex; gap: 10px;
    }
    .search-box input {
      flex: 1; padding: 10px 16px; border: 1.5px solid #f0d9b5;
      border-radius: 25px; background: white; font-size: 15px; outline: none;
      transition: 0.3s;
    }
    .search-box input:focus { border-color: #e6a14c; box-shadow: 0 0 0 3px rgba(230,161,76,0.12); }
    .search-box button {
      background: #e6a14c; color: white; border: none; border-radius: 25px;
      padding: 10px 25px; font-weight: 700; cursor: pointer; transition: 0.3s;
    }
    .search-box button:hover { background: #c97d2a; }
    .category-tabs {
      display: flex; flex-wrap: wrap; gap: 8px;
    }
    .category-tab {
      background: white; border: 1px solid #f0d9b5; border-radius: 20px;
      padding: 6px 18px; font-size: 13px; color: #b3904f; cursor: pointer;
      transition: 0.2s; font-weight: 600; white-space: nowrap;
    }
    .category-tab.active, .category-tab:hover {
      background: #e6a14c; color: white; border-color: #e6a14c;
    }
    .product-grid {
      display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 20px; margin-bottom: 30px;
    }
    .product-card {
      background: white; border-radius: 18px; padding: 15px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.06); text-align: center; transition: 0.3s;
    }
    .product-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.1); }
    .product-card img {
      width: 100px; height: 100px; border-radius: 16px; object-fit: cover; margin-bottom: 10px;
    }
    .product-name { font-weight: 700; color: #6f4518; font-size: 16px; }
    .product-price { color: #b3904f; font-size: 14px; margin: 6px 0; }
    .add-to-cart-btn {
      background: #e6a14c; color: white; border: none; border-radius: 20px;
      padding: 6px 16px; cursor: pointer;
    }
    .cart-card {
      background: white; border-radius: 18px; padding: 20px; margin-bottom: 15px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.06);
      display: flex; align-items: center; justify-content: space-between;
    }
    .cart-info { display: flex; align-items: center; gap: 15px; }
    .cart-info img { width: 60px; height: 60px; border-radius: 12px; object-fit: cover; }
    .cart-name { font-weight: 700; color: #6f4518; }
    .cart-price { color: #b3904f; }
    .quantity-input { width: 60px; padding: 5px; border: 1px solid #f0d9b5; border-radius: 8px; }
    .remove-btn { background: #f8d7da; color: #721c24; border: none; border-radius: 8px; padding: 5px 15px; cursor: pointer; }
    .total-row { text-align: right; font-size: 20px; font-weight: 700; color: #6f4518; margin: 20px 0; }
    .checkout-btn {
      background: #e6a14c; color: white; border: none; border-radius: 20px;
      padding: 12px 30px; font-weight: 700; font-size: 16px; cursor: pointer; float: right;
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

<div class="container">
  <h2 class="section-title">🎁 猫咪零食铺</h2>

  <div class="search-category">
    <div class="search-box">
      <input type="text" id="searchInput" placeholder="搜索商品名称..." oninput="filterProducts()">
      <button onclick="document.getElementById('searchInput').value='';filterProducts();">清除</button>
    </div>
    <div class="category-tabs" id="categoryTabs">
      <!-- 固定5个大类 + 全部 -->
      <span class="category-tab active" onclick="filterProducts('全部')">全部</span>
      <span class="category-tab" onclick="filterProducts('猫粮')">猫粮</span>
      <span class="category-tab" onclick="filterProducts('猫罐头')">猫罐头</span>
      <span class="category-tab" onclick="filterProducts('猫零食')">猫零食</span>
      <span class="category-tab" onclick="filterProducts('营养品')">营养品</span>
      <span class="category-tab" onclick="filterProducts('猫玩具')">猫玩具</span>
    </div>
  </div>

  <div class="product-grid" id="productGrid">
    <% for (Item item : items) {
      // 获取映射后的大类，未映射的默认归入“猫零食”
      String mappedCategory = categoryMap.getOrDefault(item.getCategory(), "猫零食");
    %>
    <div class="product-card" data-category="<%= mappedCategory %>" data-name="<%= item.getName() %>">
      <img src="<%= request.getContextPath() + "/" + (item.getImagePath() != null ? item.getImagePath() : "images/items/default.jpg") %>" alt="<%= item.getName() %>">
      <div class="product-name"><%= item.getName() %></div>
      <div class="product-price">¥<%= String.format("%.2f", item.getPrice()) %></div>
      <button class="add-to-cart-btn" onclick="addToCart(<%= item.getId() %>)">加入购物车</button>
    </div>
    <% } %>
  </div>

  <h2 class="section-title">🛒 我的购物车</h2>
  <% if (cartItems.isEmpty()) { %>
  <div style="text-align:center; color:#a68a64;">购物车是空的，去选购商品吧～</div>
  <% } else { %>
  <% for (CartItem ci : cartItems) { %>
  <div class="cart-card">
    <div class="cart-info">
      <img src="<%= request.getContextPath() + "/" + (ci.getImagePath() != null ? ci.getImagePath() : "images/items/default.jpg") %>" alt="">
      <div>
        <div class="cart-name"><%= ci.getItemName() %></div>
        <div class="cart-price">¥<%= String.format("%.2f", ci.getItemPrice()) %></div>
      </div>
    </div>
    <div style="display:flex; align-items:center; gap:10px;">
      <input type="number" class="quantity-input" value="<%= ci.getQuantity() %>" min="1"
             onchange="updateCart(<%= ci.getId() %>, this.value)">
      <button class="remove-btn" onclick="removeCart(<%= ci.getId() %>)">删除</button>
    </div>
  </div>
  <% } %>
  <div class="total-row">总价：¥<%= String.format("%.2f", total) %></div>
  <button class="checkout-btn" onclick="checkout()">结算购买</button>
  <% } %>
</div>

<script>
  // 原有购物车函数
  function addToCart(itemId) {
    fetch('<%= request.getContextPath() %>/addToCart', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'itemId=' + itemId + '&quantity=1'
    }).then(res => res.text()).then(msg => {
      if (msg === 'ok') { alert('已加入购物车！'); location.reload(); }
      else alert('添加失败');
    });
  }
  function updateCart(cartId, qty) {
    fetch('<%= request.getContextPath() %>/updateCartItem', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'cartId=' + cartId + '&quantity=' + qty
    }).then(res => res.text()).then(msg => {
      if (msg === 'ok') location.reload();
    });
  }
  function removeCart(cartId) {
    if (!confirm('确定移除？')) return;
    fetch('<%= request.getContextPath() %>/removeCartItem', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'cartId=' + cartId
    }).then(res => res.text()).then(msg => {
      if (msg === 'ok') location.reload();
    });
  }
  function checkout() {
    if (!confirm('确认购买所有商品？')) return;
    fetch('<%= request.getContextPath() %>/checkout', { method: 'POST' })
            .then(res => res.text()).then(msg => {
      if (msg === 'ok') {
        alert('结算成功！商品已放入储物柜。');
        location.href = '<%= request.getContextPath() %>/pages/feeding.jsp';
      } else alert('结算失败');
    });
  }
  function logout() {
    if (confirm('确定退出登录？')) location.href = '<%= request.getContextPath() %>/logout';
  }

  // 当前选中的分类（默认为“全部”）
  var currentCategory = '全部';

  // 筛选函数
  function filterProducts(category) {
    if (category !== undefined) {
      currentCategory = category;
      // 更新分类标签的高亮
      var tabs = document.querySelectorAll('.category-tab');
      tabs.forEach(function(tab) {
        tab.classList.remove('active');
      });
      event.target.classList.add('active');
    }
    var searchText = document.getElementById('searchInput').value.trim().toLowerCase();
    var cards = document.querySelectorAll('.product-card');
    cards.forEach(function(card) {
      var cardCat = card.getAttribute('data-category');
      var cardName = card.getAttribute('data-name').toLowerCase();
      var show = true;
      if (currentCategory !== '全部' && cardCat !== currentCategory) show = false;
      if (searchText && cardName.indexOf(searchText) === -1) show = false;
      card.style.display = show ? '' : 'none';
    });
  }

  // 搜索框输入事件
  document.getElementById('searchInput').addEventListener('input', function() {
    filterProducts(currentCategory);
  });
</script>
</body>
</html>