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
            background: linear-gradient(135deg, #fdf6e4 0%, #f5e6d3 100%); /* 暖色渐变底 */
        }

        /* 最外层容器：垂直居中 */
        .splash-wrapper {
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* 核心内容卡片 */
        .splash-card {
            position: relative;
            width: 520px;
            height: 380px;
            border-radius: 30px;
            overflow: hidden;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
            animation: fadeInCard 0.8s ease-out;
        }

        /* 背景图片层：缩小并居中显示在卡片内 */
        .splash-card .bg-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('images/welcome_bg.jpg') center center / cover no-repeat;
            /* 降低透明度并加一点模糊柔化 */
            opacity: 0.55;
            filter: blur(1px) brightness(1.1);
            z-index: 1;
        }

        /* 半透明遮罩层，让图片更柔和 */
        .splash-card .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 245, 235, 0.6); /* 暖白半透明 */
            z-index: 2;
        }

        /* 文字内容层 */
        .splash-content {
            position: relative;
            z-index: 3;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 30px;
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
        <!-- 背景图 + 遮罩 -->
        <div class="bg-image"></div>
        <div class="overlay"></div>

        <!-- 文字内容 -->
        <div class="splash-content">
            <div class="welcome-title">🐾 欢迎来到<br>校园流浪猫管理系统</div>
            <div class="welcome-sub">给流浪的生命一个温暖的家</div>
            <div class="cat-paw">🐱</div>
        </div>
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