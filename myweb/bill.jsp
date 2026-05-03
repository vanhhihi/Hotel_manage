<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<String[]> summary = (List<String[]>) request.getAttribute("summary");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Hóa Đơn</title>
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
        .navbar a { color: white; text-decoration: none; margin-left: 15px; font-size: 14px; }
        .navbar a:hover { text-decoration: underline; }

        .container { padding: 30px; }

        .title {
            font-size: 18px;
            color: #2c3e50;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .day-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 16px;
        }
        .day-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.2s;
            text-decoration: none;
            display: block;
            color: #333;
        }
        .day-card:hover { border-color: #4a90e2; transform: translateY(-2px); }
        .day-date  { font-size: 18px; font-weight: bold; color: #2c3e50; margin-bottom: 8px; }
        .day-rooms { font-size: 13px; color: #999; margin-bottom: 8px; }
        .day-total { font-size: 20px; font-weight: bold; color: #27ae60; }

        .empty { color: #999; font-size: 14px; margin-top: 20px; }
        .error { color: red; margin-bottom: 16px; font-size: 14px; }
    </style>
</head>
<body>

<div class="navbar">
    <h1>🧾 Hóa Đơn</h1>
    <div>
        <a href="home.jsp">← Trang chủ</a>
        <a href="LogoutServlet">Đăng xuất</a>
    </div>
</div>

<div class="container">
    <% String error = (String) request.getAttribute("error");
       if (error != null) { %>
        <p class="error"><%= error %></p>
    <% } %>

    <p class="title">📅 Doanh thu 10 ngày gần nhất</p>

    <div class="day-grid">
        <% if (summary != null && !summary.isEmpty()) {
            for (String[] row : summary) { %>
                <a href="BillServlet?date=<%= row[0] %>" class="day-card">
                    <div class="day-date">📅 <%= row[0] %></div>
                    <div class="day-rooms">🚪 <%= row[1] %> phòng</div>
                    <div class="day-total"><%= String.format("%,.0f", Double.parseDouble(row[2])) %> đ</div>
                </a>
        <% }
        } else { %>
            <p class="empty">Chưa có dữ liệu trong 10 ngày gần nhất.</p>
        <% } %>
    </div>
</div>

</body>
</html>