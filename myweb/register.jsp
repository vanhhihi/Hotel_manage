<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng Ký - Quản Lý Khách Sạn</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            background: #f0f2f5;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .register-box {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 380px;
        }
        h2 { text-align: center; margin-bottom: 24px; color: #333; }
        .form-group { margin-bottom: 16px; }
        label { display: block; margin-bottom: 6px; color: #555; font-size: 14px; }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        input:focus { outline: none; border-color: #4a90e2; }
        .btn-register {
            width: 100%;
            padding: 11px;
            background: #27ae60;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 15px;
            cursor: pointer;
            margin-top: 8px;
        }
        .btn-register:hover { background: #219a52; }
        .error { color: red; font-size: 13px; text-align: center; margin-bottom: 12px; }
        .success { color: green; font-size: 13px; text-align: center; margin-bottom: 12px; }
        .back-link { text-align: center; margin-top: 14px; font-size: 14px; }
        .back-link a { color: #4a90e2; text-decoration: none; }
    </style>
</head>
<body>
    <div class="register-box">
        <h2>📝 Đăng Ký Tài Khoản</h2>

        <% String error = (String) request.getAttribute("error");
           String success = (String) request.getAttribute("success");
           if (error != null) { %>
            <p class="error"><%= error %></p>
        <% } %>
        <% if (success != null) { %>
            <p class="success"><%= success %></p>
        <% } %>

        <form action="RegisterServlet" method="post">
            <div class="form-group">
                <label>Tên đăng nhập</label>
                <input type="text" name="username" placeholder="Nhập tên đăng nhập" required />
            </div>
            <div class="form-group">
                <label>Mật khẩu</label>
                <input type="password" name="password" placeholder="Nhập mật khẩu" required />
            </div>
            <div class="form-group">
                <label>Xác nhận mật khẩu</label>
                <input type="password" name="confirmPassword" placeholder="Nhập lại mật khẩu" required />
            </div>
            <button type="submit" class="btn-register">Đăng Ký</button>
        </form>
        <div class="back-link">
            <a href="login.jsp">← Quay lại đăng nhập</a>
        </div>
    </div>
</body>
</html>