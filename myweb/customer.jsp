<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    List<String[]> customers = (List<String[]>) request.getAttribute("customers");
    Map<String, List<String[]>> detailMap = (Map<String, List<String[]>>) request.getAttribute("detailMap");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Khách Hàng</title>
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
        .title { font-size: 18px; color: #2c3e50; margin-bottom: 20px; font-weight: bold; }

        .search-bar { margin-bottom: 20px; }
        .search-bar input {
            padding: 9px 14px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            width: 300px;
        }
        .search-bar input:focus { outline: none; border-color: #4a90e2; }

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
        tr:hover td { background: #f0f7ff; cursor: pointer; }
        .total-price { color: #27ae60; font-weight: bold; }

        /* Popup */
        .overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 100;
            justify-content: center;
            align-items: center;
        }
        .overlay.active { display: flex; }
        .popup {
            background: white;
            border-radius: 8px;
            padding: 30px;
            width: 700px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }
        .popup h3 { margin-bottom: 20px; color: #2c3e50; font-size: 18px; }
        .popup table th { background: #34495e; }
        .btn-close {
            padding: 8px 20px;
            background: #95a5a6;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 16px;
            font-size: 14px;
        }
        .btn-close:hover { opacity: 0.85; }

        .type-hourly  { color: #e67e22; }
        .type-nightly { color: #8e44ad; }
        .status-active { color: #27ae60; font-weight: bold; }
        .status-done   { color: #999; }

        .empty { color: #999; font-size: 14px; margin-top: 20px; }
        .error { color: red; margin-bottom: 16px; font-size: 14px; }
    </style>
</head>
<body>

<div class="navbar">
    <h1>👥 Khách Hàng</h1>
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

    <p class="title">👥 Danh sách khách hàng</p>

    <div class="search-bar">
        <input type="text" id="searchInput" placeholder="🔍 Tìm theo tên khách..."
               onkeyup="searchTable()" />
    </div>

    <% if (customers != null && !customers.isEmpty()) { %>
        <table id="customerTable">
            <thead>
                <tr>
                    <th>Tên khách</th>
                    <th>Số lần thuê</th>
                    <th>Tổng tiền</th>
                </tr>
            </thead>
            <tbody>
                <% int idx = 0;
                for (String[] row : customers) { %>
                <tr onclick="openDetail(<%= idx %>)">
                    <td>🧑 <%= row[0] %></td>
                    <td><%= row[1] %> lần</td>
                    <td class="total-price">
                        <%= row[2] != null ? String.format("%,.0f", Double.parseDouble(row[2])) + " đ" : "Chưa tính" %>
                    </td>
                </tr>
                <% idx++; } %>
            </tbody>
        </table>
    <% } else { %>
        <p class="empty">Chưa có dữ liệu khách hàng.</p>
    <% } %>
</div>

<!-- Popup chi tiết -->
<div class="overlay" id="detailPopup">
    <div class="popup">
        <h3 id="popupTitle">Chi tiết khách hàng</h3>
        <table id="detailTable">
            <thead>
                <tr>
                    <th>Phòng</th>
                    <th>Loại thuê</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody id="detailBody"></tbody>
        </table>
        <button class="btn-close" onclick="closeDetail()">✖ Đóng</button>
    </div>
</div>

<!-- Lưu detailMap vào JS -->
<script>
    const customerNames = [
        <% if (customers != null) {
            boolean first = true;
            for (String[] row : customers) {
                if (!first) out.print(",");
                first = false;
        %>
        '<%= row[0].replace("'", "\\'") %>'
        <% } } %>
    ];

    const detailList = [
        <% if (detailMap != null) {
            boolean firstCustomer = true;
            for (Map.Entry<String, List<String[]>> entry : detailMap.entrySet()) {
                if (!firstCustomer) out.print(",");
                firstCustomer = false;
        %>
        [
            <% boolean firstRow = true;
               for (String[] d : entry.getValue()) {
                   if (!firstRow) out.print(",");
                   firstRow = false;
            %>
            {
                room: '<%= d[0] != null ? d[0] : "" %>',
                type: '<%= d[1] != null ? d[1] : "" %>',
                checkIn: '<%= d[2] != null ? d[2] : "" %>',
                checkOut: '<%= d[3] != null ? d[3] : "" %>',
                price: '<%= d[4] != null ? d[4] : "" %>',
                status: '<%= d[5] != null ? d[5] : "" %>'
            }
            <% } %>
        ]
        <% } } %>
    ];

    function openDetail(index) {
    let name = customerNames[index];
    let rows = detailList[index] || [];
    document.getElementById('popupTitle').textContent = '🧑 Chi tiết: ' + name;
    let html = '';
    rows.forEach(function(d) {
        let price = d.price ? parseFloat(d.price).toLocaleString('vi-VN') + ' đ' : 'Chưa tính';
        let checkout = d.checkOut ? d.checkOut : 'Đang thuê';
        let status = d.status === 'active' ? '<span class="status-active">🟢 Đang thuê</span>' : '<span class="status-done">✅ Đã trả</span>';
        let type = d.type === 'hourly' ? '<span class="type-hourly">⏱️ Theo giờ</span>' : '<span class="type-nightly">🌙 Theo đêm</span>';
        html += '<tr>' +
            '<td>🚪 ' + d.room + '</td>' +
            '<td>' + type + '</td>' +
            '<td>' + d.checkIn + '</td>' +
            '<td>' + checkout + '</td>' +
            '<td>' + price + '</td>' +
            '<td>' + status + '</td>' +
            '</tr>';
    });
    document.getElementById('detailBody').innerHTML = html;
    document.getElementById('detailPopup').classList.add('active');
}

    function closeDetail() {
        document.getElementById('detailPopup').classList.remove('active');
    }

    function searchTable() {
        let input = document.getElementById('searchInput').value.toLowerCase();
        let rows = document.querySelectorAll('#customerTable tbody tr');
        rows.forEach(row => {
            let name = row.cells[0].textContent.toLowerCase();
            row.style.display = name.includes(input) ? '' : 'none';
        });
    }
</script>

</body>
</html>