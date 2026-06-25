<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>欢迎 - 校园流浪猫管理系统</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body, html {
            width: 100%;
            height: 100%;
            overflow: hidden;
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            /* 与登录页完全一致的背景：图片 + 白色遮罩 */
            background: url('images/welcome_bg.jpg') no-repeat center center / cover;
            position: relative;
        }

        /* 白色半透明遮罩，与登录页完全一致 */
        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.45);
            z-index: 0;
            pointer-events: none;
        }

        /* 最外层容器：垂直居中 */
        .splash-wrapper {
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            z-index: 1;
        }

        /* 核心内容卡片，调整为与登录页卡片一致的通透质感 */
        .splash-card {
            position: relative;
            width: 520px;
            background: rgba(255, 255, 255, 0.65);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-radius: 30px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.06),
            0 0 0 1px rgba(255, 255, 255, 0.8);
            padding: 45px 40px;
            animation: fadeInCard 0.8s ease-out;
            text-align: center;
        }

        /* 移除原有的背景图层和遮罩层 */
        .splash-card .bg-image,
        .splash-card .overlay {
            display: none;
        }

        /* 主标题 */
        .welcome-title {
            font-size: 36px;
            font-weight: bold;
            color: #d2691e;
            letter-spacing: 3px;
            margin-bottom: 15px;
            text-shadow: 0 2px 4px rgba(255,255,255,0.8);
            animation: slideUp 1s ease-out;
        }

        /* 副标题 */
        .welcome-sub {
            font-size: 17px;
            color: #a0653a;
            background: rgba(255,255,255,0.7);
            padding: 8px 25px;
            border-radius: 25px;
            letter-spacing: 1px;
            animation: slideUp 1.2s ease-out;
        }

        /* 猫咪装饰 */
        .cat-paw {
            font-size: 50px;
            margin-top: 10px;
            animation: pawBounce 1.5s infinite;
        }

        /* 渐入动画 */
        @keyframes fadeInCard {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes pawBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-6px); }
        }
    </style>
</head>
<body>
<div class="splash-wrapper">
    <div class="splash-card">
        <!-- 文字内容 -->
        <div class="welcome-title">🐾 欢迎来到<br>校园流浪猫管理系统</div>
        <div class="welcome-sub">给流浪的生命一个温暖的家</div>
        <div class="cat-paw">🐱</div>
    </div>
</div>

<script>
    // 3秒后跳转登录页
    setTimeout(function() {
        window.location.href = 'index.jsp';
    }, 3000);
</script>
</body>
</html>