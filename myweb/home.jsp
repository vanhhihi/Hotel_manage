<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
     response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang Chủ - Quản Lý Khách Sạn</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f0f2f5; }

        .navbar {
            background: #2c3e50;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .navbar h1 { font-size: 20px; }
        .navbar .user-info { font-size: 14px; }
        .navbar a {
            color: white;
            text-decoration: none;
            margin-left: 15px;
            font-size: 14px;
        }
        .navbar a:hover { text-decoration: underline; }

        .container {
            padding: 30px;
        }
        .welcome {
            background: white;
            padding: 20px 30px;
            border-radius: 8px;
            margin-bottom: 24px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }
        .welcome h2 { color: #2c3e50; margin-bottom: 6px; }
        .welcome p { color: #777; font-size: 14px; }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }
        .menu-card {
            background: white;
            padding: 30px 20px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            cursor: pointer;
            transition: transform 0.2s;
            text-decoration: none;
            color: #333;
            display: block;
        }
        .menu-card:hover { transform: translateY(-4px); }
        .menu-card .icon { font-size: 40px; margin-bottom: 12px; }
        .menu-card h3 { font-size: 16px; color: #2c3e50; }
        .menu-card p { font-size: 13px; color: #999; margin-top: 6px; }
    </style>
</head>
<body>

    <div class="navbar">
        <h1>🏨 Quản Lý Khách Sạn</h1>
        <div class="user-info">
            👤 <%= username %> (<%= role %>)
            <a href="LogoutServlet">Đăng xuất</a>
        </div>
    </div>

    <div class="container">
        <div class="welcome">
            <h2>Xin chào, <%= username %>! 👋</h2>
            <p>Chào mừng bạn đến với hệ thống quản lý khách sạn.</p>
        </div>

        <div class="menu-grid">
            <a href="RoomServlet" class="menu-card">
                <div class="icon">🛏️</div>
                <h3>Quản Lý Phòng</h3>
                <p>Xem, thêm, sửa, xóa phòng</p>
            </a>
            <a href="RoomServlet?page=booking" class="menu-card">
                <div class="icon">📋</div>
                <h3>Đặt Phòng</h3>
                <p>Quản lý đặt phòng của khách</p>
            </a>
            <a href="CustomerServlet" class="menu-card">
                <div class="icon">👥</div>
                <h3>Khách Hàng</h3>
                <p>Danh sách khách hàng</p>
            </a>
            <a href="BillServlet" class="menu-card">
                <div class="icon">🧾</div>
                <h3>Hóa Đơn</h3>
                <p>Quản lý thanh toán</p>
            </a>
            <a href="report.jsp" class="menu-card">
                <div class="icon">📊</div>
                <h3>Báo Cáo</h3>
                <p>Thống kê doanh thu</p>
            </a>
            <a href="account.jsp" class="menu-card">
                <div class="icon">⚙️</div>
                <h3>Tài Khoản</h3>
                <p>Quản lý tài khoản nhân viên</p>
            </a>
        </div>
    </div>

</body>
</html>