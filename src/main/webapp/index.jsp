<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园流浪猫管理系统</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            /* 暖黄背景图 + 柔和渐变，使用 soft-light 融合，消除粉感 */
            background:
                    url('images/login-bg.jpg') no-repeat center center / cover,
                    linear-gradient(135deg, #fff5e6 0%, #f5d6a8 100%);
            background-blend-mode: soft-light;
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            position: relative;
            overflow: hidden;
        }

        /* 移除之前 body::before 的图片层，因为已通过 body 背景实现 */
        body::before {
            display: none;
        }

        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        /* 背景柔光装饰圆 */
        .bg-circle {
            position: absolute;
            border-radius: 50%;
            background: rgba(255,255,255,0.35);
            filter: blur(12px);
            z-index: 0;
            animation: float 10s ease-in-out infinite;
        }
        .circle1 {
            width: 320px;
            height: 320px;
            top: -120px;
            right: -100px;
            animation-delay: 0s;
        }
        .circle2 {
            width: 240px;
            height: 240px;
            bottom: -80px;
            left: -60px;
            animation-delay: 3s;
        }
        .circle3 {
            width: 160px;
            height: 160px;
            top: 20%;
            left: 10%;
            background: rgba(255,255,255,0.2);
            animation-delay: 6s;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0) scale(1); }
            50% { transform: translateY(-25px) scale(1.05); }
        }

        /* 卡片容器 - 暖黄磨砂质感 */
        .card {
            position: relative;
            z-index: 1;
            width: 450px;
            background: rgba(255, 250, 240, 0.8); /* 米黄半透明底 */
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border-radius: 32px;
            box-shadow:
                    0 25px 60px rgba(160, 110, 50, 0.18),
                    0 0 0 1px rgba(255,255,255,0.7),
                    inset 0 1px 0 rgba(255,255,255,0.9);
            padding: 45px 40px;
            animation: cardFadeIn 0.9s ease-out;
        }

        @keyframes cardFadeIn {
            from {
                opacity: 0;
                transform: translateY(35px) scale(0.95);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .logo-area {
            text-align: center;
            margin-bottom: 28px;
        }

        .logo-icon {
            font-size: 52px;
            margin-bottom: 8px;
            display: inline-block;
            animation: iconBounce 3.5s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0) rotate(-2deg); }
            50% { transform: translateY(-8px) rotate(2deg); }
        }

        .title {
            font-size: 25px;
            font-weight: 700;
            color: #8b6914; /* 暖棕黄 */
            letter-spacing: 1.5px;
            margin-bottom: 4px;
        }

        .subtitle {
            font-size: 13px;
            color: #b3904f;
            letter-spacing: 0.5px;
        }

        /* 选项卡 */
        .tabs {
            display: flex;
            margin-bottom: 30px;
            background: rgba(255, 243, 220, 0.8);
            border-radius: 16px;
            padding: 5px;
            gap: 5px;
        }

        .tab-btn {
            flex: 1;
            border: none;
            background: transparent;
            padding: 13px 0;
            font-size: 15px;
            font-weight: 600;
            color: #b3904f;
            border-radius: 13px;
            cursor: pointer;
            transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            letter-spacing: 0.5px;
        }

        .tab-btn.active {
            background: linear-gradient(135deg, #fff7e6, #ffe4b5); /* 暖黄渐变 */
            color: #c0852a;
            box-shadow: 0 5px 15px rgba(192, 133, 42, 0.2);
            transform: translateY(-1px);
        }

        .tab-btn:hover:not(.active) {
            color: #c0852a;
            background: rgba(255,255,255,0.6);
        }

        /* 面板切换 */
        .form-panel {
            display: none;
            animation: panelFade 0.45s ease;
        }

        .form-panel.active {
            display: block;
        }

        @keyframes panelFade {
            from { opacity: 0; transform: translateX(12px); }
            to { opacity: 1; transform: translateX(0); }
        }

        /* 输入框 */
        .input-group {
            margin-bottom: 20px;
            position: relative;
        }

        .input-group .icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 17px;
            color: #d4a373;
            pointer-events: none;
            transition: 0.3s;
        }

        .input-group input {
            width: 100%;
            padding: 15px 18px 15px 46px;
            border: 2px solid #f5e0c4;
            border-radius: 18px;
            font-size: 14.5px;
            background: rgba(255,255,255,0.9);
            transition: all 0.3s ease;
            outline: none;
            color: #6f4518;
        }

        .input-group input:focus {
            border-color: #f0a04b;
            background: #fff;
            box-shadow: 0 0 0 5px rgba(240, 160, 75, 0.12);
        }

        .input-group .no-icon {
            padding-left: 18px !important;
        }

        .code-box {
            display: flex;
            gap: 12px;
        }

        .code-box input {
            flex: 1;
        }

        .get-code-btn {
            padding: 0 20px;
            background: linear-gradient(135deg, #f4b26a, #e6a14c);
            border: none;
            border-radius: 18px;
            color: white;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.3s ease;
            white-space: nowrap;
            letter-spacing: 0.5px;
        }

        .get-code-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(230, 161, 76, 0.4);
        }

        .code-display {
            margin-top: 12px;
            padding: 10px;
            background: linear-gradient(135deg, #fff8e7, #ffe8c6);
            border-radius: 14px;
            text-align: center;
            font-weight: 600;
            color: #a66a1a;
            font-size: 15px;
            letter-spacing: 2px;
            animation: codePop 0.35s ease;
        }

        @keyframes codePop {
            from { transform: scale(0.9); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        .submit-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #f4b26a, #e6a14c);
            color: white;
            border: none;
            border-radius: 18px;
            font-size: 16.5px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            letter-spacing: 1px;
            margin-top: 10px;
            box-shadow: 0 10px 24px rgba(192, 133, 42, 0.3);
        }

        .submit-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 14px 30px rgba(192, 133, 42, 0.45);
            background: linear-gradient(135deg, #e6a14c, #c97d2a);
        }

        .submit-btn:active {
            transform: translateY(0);
        }

        .text-link {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #a68a64;
        }

        .text-link a {
            color: #a66a1a;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: 0.2s;
        }

        .text-link a:hover {
            color: #7f4d10;
            text-decoration: underline;
        }

        .error-msg {
            color: #c1121f;
            text-align: center;
            margin-top: 14px;
            font-size: 14px;
            font-weight: 500;
            min-height: 20px;
        }

        .hidden {
            display: none !important;
        }

        @media (max-width: 480px) {
            .card {
                width: 92%;
                padding: 35px 28px;
            }
            .title {
                font-size: 22px;
            }
        }
    </style>
</head>
<body>
<!-- 背景装饰 -->
<div class="bg-circle circle1"></div>
<div class="bg-circle circle2"></div>
<div class="bg-circle circle3"></div>

<div class="card">
    <div class="logo-area">
        <div class="logo-icon">🐾</div>
        <div class="title">校园流浪猫管理</div>
        <div class="subtitle">温柔守护每一只校园小毛孩</div>
    </div>

    <!-- 角色选项卡 -->
    <div class="tabs">
        <button class="tab-btn active" onclick="switchTab('user')">🐱 用户</button>
        <button class="tab-btn" onclick="switchTab('admin')">🔧 管理员</button>
    </div>

    <!-- 用户登录面板 -->
    <div id="userPanel" class="form-panel active">
        <form action="login" method="post">
            <input type="hidden" name="role" value="user">
            <div class="input-group">
                <span class="icon">👤</span>
                <input type="text" name="username" placeholder="用户名" required>
            </div>
            <div class="input-group">
                <span class="icon">🔒</span>
                <input type="password" name="password" placeholder="密码" required>
            </div>
            <button type="submit" class="submit-btn">登 录</button>
        </form>
        <div class="text-link">
            还没有账号？<a onclick="switchToRegister()">立即注册</a>
        </div>
    </div>

    <!-- 管理员登录面板 -->
    <div id="adminPanel" class="form-panel">
        <form action="login" method="post">
            <input type="hidden" name="role" value="admin">
            <div class="input-group">
                <span class="icon">🛡️</span>
                <input type="text" name="username" placeholder="管理员账号" required>
            </div>
            <div class="input-group">
                <span class="icon">🔒</span>
                <input type="password" name="password" placeholder="管理员密码" required>
            </div>
            <button type="submit" class="submit-btn">管理员登录</button>
        </form>
    </div>

    <!-- 用户注册面板 -->
    <div id="registerPanel" class="form-panel">
        <form action="register" method="post" onsubmit="return checkReg()">
            <div class="input-group">
                <span class="icon">🐱</span>
                <input type="text" name="username" id="regUsername" placeholder="设置用户名" required>
            </div>
            <div class="input-group">
                <span class="icon">🔑</span>
                <input type="password" name="password" id="regPassword" placeholder="设置密码" required>
            </div>
            <div class="input-group">
                <span class="icon">📱</span>
                <input type="text" name="phone" id="regPhone" placeholder="手机号" required>
            </div>
            <div class="input-group code-box">
                <span class="icon">✉️</span>
                <input type="text" name="code" id="regCodeInput" placeholder="验证码" required style="flex:1">
                <button type="button" class="get-code-btn" onclick="getCode()">获取验证码</button>
            </div>
            <div id="codeDisplay" class="code-display hidden"></div>
            <button type="submit" class="submit-btn">注 册</button>
        </form>
        <div class="text-link">
            已有账号？<a onclick="switchToLogin()">返回登录</a>
        </div>
    </div>

    <div class="error-msg">${requestScope.msg}</div>
</div>

<script>
    function switchTab(role) {
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.form-panel').forEach(panel => panel.classList.remove('active'));
        if (role === 'user') {
            document.querySelector('.tab-btn:nth-child(1)').classList.add('active');
            document.getElementById('userPanel').classList.add('active');
        } else {
            document.querySelector('.tab-btn:nth-child(2)').classList.add('active');
            document.getElementById('adminPanel').classList.add('active');
        }
        document.getElementById('registerPanel').classList.remove('active');
    }

    function switchToRegister() {
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.form-panel').forEach(panel => panel.classList.remove('active'));
        document.getElementById('registerPanel').classList.add('active');
    }

    function switchToLogin() {
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.form-panel').forEach(panel => panel.classList.remove('active'));
        document.querySelector('.tab-btn:nth-child(1)').classList.add('active');
        document.getElementById('userPanel').classList.add('active');
    }

    function getCode() {
        var phone = document.getElementById("regPhone").value;
        if (!phone) {
            alert("请先输入手机号");
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "sendCode", true);
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var code = xhr.responseText;
                document.getElementById("codeDisplay").innerText = "验证码：" + code + "（已发送至手机）";
                document.getElementById("codeDisplay").classList.remove("hidden");
            }
        };
        xhr.send("phone=" + encodeURIComponent(phone));
    }

    function checkReg() {
        if (!document.getElementById("regCodeInput").value) {
            alert("请输入验证码");
            return false;
        }
        return true;
    }
</script>
</body>
</html>