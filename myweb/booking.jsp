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

    List<String[]> rooms = (List<String[]>) request.getAttribute("rooms");
    Map<String, String[]> bookingMap = (Map<String, String[]>) request.getAttribute("bookingMap");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đặt Phòng</title>
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

        .toolbar { display: flex; gap: 12px; margin-bottom: 24px; }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            color: white;
        }
        .btn-book     { background: #27ae60; }
        .btn-checkout { background: #e74c3c; }
        .btn-confirm  { background: #27ae60; flex: 1; padding: 10px; }
        .btn-cancel   { background: #95a5a6; flex: 1; padding: 10px; }
        .btn:hover { opacity: 0.85; }

        .room-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 16px;
        }
        .room-card {
            background: white;
            border-radius: 8px;
            padding: 16px;
            text-align: center;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.2s;
        }
        .room-card:hover { border-color: #4a90e2; transform: translateY(-2px); }
        .room-card.selected { border-color: #4a90e2; background: #eaf3fb; }
        .room-number { font-size: 22px; font-weight: bold; color: #2c3e50; }
        .room-type   { font-size: 12px; color: #999; margin-top: 4px; }
        .room-price  { font-size: 12px; color: #27ae60; margin-top: 4px; }
        .room-status {
            font-size: 11px;
            margin-top: 8px;
            padding: 3px 8px;
            border-radius: 10px;
            display: inline-block;
        }
        .available   { background: #d5f5e3; color: #1e8449; }
        .occupied    { background: #fadbd8; color: #c0392b; }
        .maintenance { background: #fef9e7; color: #d68910; }

        .error   { color: red;   margin-bottom: 16px; font-size: 14px; }
        .success { color: green; margin-bottom: 16px; font-size: 14px; }

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
            width: 420px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }
        .popup h3 { margin-bottom: 20px; color: #2c3e50; font-size: 18px; }

        /* Tab */
        .tabs {
            display: flex;
            margin-bottom: 20px;
            border-bottom: 2px solid #eee;
        }
        .tab {
            flex: 1;
            padding: 10px;
            text-align: center;
            cursor: pointer;
            font-size: 14px;
            color: #999;
            border-bottom: 3px solid transparent;
            margin-bottom: -2px;
        }
        .tab.active { color: #2c3e50; border-bottom-color: #4a90e2; font-weight: bold; }

        .tab-content { display: none; }
        .tab-content.active { display: block; }

        .form-group { margin-bottom: 14px; }
        .form-group label { display: block; margin-bottom: 6px; color: #555; font-size: 14px; }
        .form-group input {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .form-group input:focus { outline: none; border-color: #4a90e2; }
        .form-group input[readonly] { background: #f5f5f5; }

        .price-display {
            background: #f0f9f4;
            border: 1px solid #27ae60;
            border-radius: 4px;
            padding: 10px;
            text-align: center;
            color: #27ae60;
            font-weight: bold;
            font-size: 15px;
            margin-bottom: 14px;
        }

        .popup-buttons { display: flex; gap: 10px; margin-top: 20px; }
    </style>
</head>
<body>

<div class="navbar">
    <h1>📋 Đặt Phòng</h1>
    <div>
        <a href="home.jsp">← Trang chủ</a>
        <a href="LogoutServlet">Đăng xuất</a>
    </div>
</div>

<div class="container">

    <% String error = (String) request.getAttribute("error");
       String success = (String) request.getAttribute("success");
       if (error != null) { %>
        <p class="error"><%= error %></p>
    <% } %>
    <% if (success != null) { %>
        <p class="success"><%= success %></p>
    <% } %>

    <div class="toolbar">
        <button class="btn btn-book" onclick="openBookPopup()">✔ Đặt Phòng</button>
        <button class="btn btn-checkout" onclick="checkoutSelected()">✖ Trả Phòng</button>
    </div>

    <div class="room-grid">
        <% if (rooms != null) {
            for (String[] room : rooms) { %>
                <div class="room-card"
                     onclick="selectRoom(this, '<%= room[0] %>', '<%= room[1] %>', '<%= room[2] %>', '<%= room[3] %>', '<%= room[4] %>')"
                     data-room="<%= room[0] %>"
                     data-status="<%= room[3] %>">
                    <div class="room-number">🚪 <%= room[0] %></div>
                    <div class="room-type"><%= room[1] %></div>
                    <div class="room-price">
                        <%= String.format("%,.0f", Double.parseDouble(room[2])) %> đ/giờ<br/>
                        <%= String.format("%,.0f", Double.parseDouble(room[3])) %> đ/đêm
                    </div>
                    <div class="room-status <%= room[4] %>"><%= room[4] %></div>
                    <%
                        if (bookingMap != null && bookingMap.containsKey(room[0])) {
                            String[] booking = bookingMap.get(room[0]);
                    %>
                    <div style="font-size:11px; color:#666; margin-top:6px;">
                        👤 <%= booking[0] %><br/>
                        ⏱️ <%= booking[2] %>
                    </div>
                    <% } %>
                </div>
            <% }
        } %>
    </div>
</div>

<!-- Popup Đặt Phòng -->
<div class="overlay" id="bookPopup">
    <div class="popup">
        <h3>📋 Đặt Phòng <span id="popup_room_number"></span></h3>

        <!-- Tabs -->
        <div class="tabs">
            <div class="tab active" onclick="switchTab('hourly')">⏱️ Theo Giờ</div>
            <div class="tab" onclick="switchTab('nightly')">🌙 Theo Đêm</div>
        </div>

        <!-- Tab Theo Giờ -->
        <div class="tab-content active" id="tab-hourly">
            <div class="form-group">
                <label>Giá theo giờ</label>
                <input type="text" id="hourly_price_display" readonly />
            </div>
            <div class="form-group">
                <label>Thời gian bắt đầu</label>
                <input type="text" id="hourly_checkin" readonly />
            </div>
            <p style="font-size:13px; color:#999; margin-bottom:14px;">
                ※ Khách trả phòng khi bấm "Trả Phòng"
            </p>
            <form action="RoomServlet" method="post">
                <input type="hidden" name="action" value="book" />
                <input type="hidden" name="type" value="hourly" />
                <input type="hidden" name="room_number" id="hourly_room_number" />
                <input type="hidden" name="username" value="<%= username %>" />
                <div class="popup-buttons">
                    <button type="submit" class="btn btn-confirm">✔ Xác Nhận</button>
                    <button type="button" class="btn btn-cancel" onclick="closePopup()">✖ Hủy</button>
                </div>
            </form>
        </div>

        <!-- Tab Theo Đêm -->
        <div class="tab-content" id="tab-nightly">
            <div class="form-group">
                <label>Giá theo đêm</label>
                <input type="text" id="nightly_price_display" readonly />
            </div>
            <div class="form-group">
                <label>Số đêm</label>
                <input type="number" id="nightly_nights" min="1" value="1"
                       oninput="calcNightlyPrice()" />
            </div>
            <div class="price-display" id="nightly_total">Tổng: 0 đ</div>
            <form action="RoomServlet" method="post">
                <input type="hidden" name="action" value="book" />
                <input type="hidden" name="type" value="nightly" />
                <input type="hidden" name="room_number" id="nightly_room_number" />
                <input type="hidden" name="username" value="<%= username %>" />
                <input type="hidden" name="nights" id="nightly_nights_hidden" value="1" />
                <div class="popup-buttons">
                    <button type="submit" class="btn btn-confirm" onclick="setNights()">✔ Xác Nhận</button>
                    <button type="button" class="btn btn-cancel" onclick="closePopup()">✖ Hủy</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Form ẩn trả phòng -->
<form id="checkoutForm" action="RoomServlet" method="post">
    <input type="hidden" name="action" value="checkout" />
    <input type="hidden" name="room_number" id="checkout_room_number" />
</form>

<script>
    let selectedRoom = null;

    function selectRoom(card, roomNumber, type, priceHour, priceNight, status) {
        document.querySelectorAll('.room-card').forEach(c => c.classList.remove('selected'));
        card.classList.add('selected');
        selectedRoom = { roomNumber, type, priceHour, priceNight, status };
    }

    function openBookPopup() {
        if (!selectedRoom) {
            alert('Vui lòng chọn phòng trước!');
            return;
        }
        if (selectedRoom.status !== 'available') {
            alert('Phòng ' + selectedRoom.roomNumber + ' không available!');
            return;
        }

        // Điền thông tin vào popup
        document.getElementById('popup_room_number').textContent = '- Phòng ' + selectedRoom.roomNumber;
        document.getElementById('hourly_room_number').value = selectedRoom.roomNumber;
        document.getElementById('nightly_room_number').value = selectedRoom.roomNumber;

        // Hiển thị giá
        let priceHour = parseFloat(selectedRoom.priceHour);
        let priceNight = parseFloat(selectedRoom.priceNight);
        document.getElementById('hourly_price_display').value =
            priceHour.toLocaleString('vi-VN') + ' đ/giờ';
        document.getElementById('nightly_price_display').value =
            priceNight.toLocaleString('vi-VN') + ' đ/đêm';

        // Thời gian bắt đầu
        let now = new Date();
        document.getElementById('hourly_checkin').value = now.toLocaleString('vi-VN');

        // Tính tổng đêm
        calcNightlyPrice();

        // Mở popup
        document.getElementById('bookPopup').classList.add('active');
        switchTab('hourly');
    }

    function switchTab(tab) {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));

        if (tab === 'hourly') {
            document.querySelectorAll('.tab')[0].classList.add('active');
            document.getElementById('tab-hourly').classList.add('active');
        } else {
            document.querySelectorAll('.tab')[1].classList.add('active');
            document.getElementById('tab-nightly').classList.add('active');
        }
    }

    function calcNightlyPrice() {
        if (!selectedRoom) return;
        let nights = parseInt(document.getElementById('nightly_nights').value) || 1;
        let priceNight = parseFloat(selectedRoom.priceNight);
        let total = nights * priceNight;
        document.getElementById('nightly_total').textContent =
            'Tổng: ' + total.toLocaleString('vi-VN') + ' đ';
        document.getElementById('nightly_nights_hidden').value = nights;
    }

    function setNights() {
        let nights = document.getElementById('nightly_nights').value;
        document.getElementById('nightly_nights_hidden').value = nights;
    }

    function closePopup() {
        document.getElementById('bookPopup').classList.remove('active');
    }

    function checkoutSelected() {
        if (!selectedRoom) {
            alert('Vui lòng chọn phòng trước!');
            return;
        }
        if (selectedRoom.status !== 'occupied') {
            alert('Phòng ' + selectedRoom.roomNumber + ' chưa được đặt!');
            return;
        }
        if (confirm('Xác nhận trả phòng ' + selectedRoom.roomNumber + '?')) {
            document.getElementById('checkout_room_number').value = selectedRoom.roomNumber;
            document.getElementById('checkoutForm').submit();
        }
    }
</script>

</body>
</html>