    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng Nhập - Quản Lý Khách Sạn</title>
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
        .login-box {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 380px;
        }
        h2 {
            text-align: center;
            margin-bottom: 24px;
            color: #333;
        }
        .form-group {
            margin-bottom: 16px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            color: #555;
            font-size: 14px;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        input:focus {
            outline: none;
            border-color: #4a90e2;
        }
        .btn-login {
            width: 100%;
            padding: 11px;
            background: #4a90e2;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 15px;
            cursor: pointer;
            margin-top: 8px;
        }
        .btn-login:hover { background: #357abd; }
        .error {
            color: red;
            font-size: 13px;
            text-align: center;
            margin-bottom: 12px;
        }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>🏨 Quản Lý Khách Sạn</h2>

        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
            <p class="error"><%= error %></p>
        <% } %>

        <form action="LoginServlet" method="post">
            <div class="form-group">
                <label>Tên đăng nhập</label>
                <input type="text" name="username" placeholder="Nhập tên đăng nhập" required />
            </div>
            <div class="form-group">
                <label>Mật khẩu</label>
                <input type="password" name="password" placeholder="Nhập mật khẩu" required />
            </div>
            <button type="submit" class="btn-login">Đăng Nhập</button>
            <p style="text-align:center; margin-top:14px; font-size:14px;">
            Chưa có tài khoản? <a href="register.jsp">Đăng ký ngay</a>
        </p>
        </form>
    </div>
</body>
</html>