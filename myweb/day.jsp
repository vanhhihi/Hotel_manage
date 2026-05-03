<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<String[]> bills = (List<String[]>) request.getAttribute("bills");
    String date = (String) request.getAttribute("date");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi Tiết Ngày <%= date %></title>
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

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }
        th {
            background: #2c3e50;
            color: white;
            padding: 12px 16px;
            text-align: left;
            font-size: 14px;
        }
        td {
            padding: 12px 16px;
            font-size: 14px;
            border-bottom: 1px solid #f0f0f0;
            color: #333;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9f9f9; }

        .total-row td {
            font-weight: bold;
            color: #27ae60;
            font-size: 15px;
            border-top: 2px solid #eee;
        }

        .type-hourly  { color: #e67e22; }
        .type-nightly { color: #8e44ad; }

        .empty { color: #999; font-size: 14px; margin-top: 20px; }
        .error { color: red; margin-bottom: 16px; font-size: 14px; }
    </style>
</head>
<body>

<div class="navbar">
    <h1>🧾 Chi Tiết Ngày <%= date %></h1>
    <div>
        <a href="BillServlet">← Quay lại</a>
        <a href="home.jsp">🏠 Trang chủ</a>
        <a href="LogoutServlet">Đăng xuất</a>
    </div>
</div>

<div class="container">
    <% String error = (String) request.getAttribute("error");
       if (error != null) { %>
        <p class="error"><%= error %></p>
    <% } %>

    <p class="title">📅 Hóa đơn ngày <%= date %></p>

    <% if (bills != null && !bills.isEmpty()) { %>
        <table>
            <thead>
                <tr>
                    <th>Phòng</th>
                    <th>Người đặt</th>
                    <th>Khách hàng</th>
                    <th>Loại</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Tổng tiền</th>
                </tr>
            </thead>
            <tbody>
                <%
                    double grandTotal = 0;
                    for (String[] bill : bills) {
                        grandTotal += Double.parseDouble(bill[5]);
                %>
                <tr>
                    <td>🚪 <%= bill[0] %></td>
                    <td>👤 <%= bill[1] %></td>
                    <td>🧑 <%= bill[6] != null ? bill[6] : "-" %></td>
                    <td class="type-<%= bill[2] %>">
                        <%= "hourly".equals(bill[2]) ? "⏱️ Theo giờ" : "🌙 Theo đêm" %>
                    </td>
                    <td><%= bill[3] %></td>
                    <td><%= bill[4] %></td>
                    <td><%= String.format("%,.0f", Double.parseDouble(bill[5])) %> đ</td>
                </tr>
                <% } %>
                <tr class="total-row">
                    <td colspan="5" style="text-align:right;">Tổng cộng:</td>
                    <td><%= String.format("%,.0f", grandTotal) %> đ</td>
                </tr>
            </tbody>
        </table>
    <% } else { %>
        <p class="empty">Không có hóa đơn nào trong ngày này.</p>
    <% } %>
</div>

</body>
</html>