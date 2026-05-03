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
        <title>Quản Lý Phòng</title>
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
            .navbar a {
                color: white;
                text-decoration: none;
                margin-left: 15px;
                font-size: 14px;
            }
            .navbar a:hover { text-decoration: underline; }

            .container { padding: 30px; }

            .toolbar {
                display: flex;
                gap: 12px;
                margin-bottom: 24px;
            }
            .btn {
                padding: 10px 20px;
                border: none;
                border-radius: 4px;
                font-size: 14px;
                cursor: pointer;
                text-decoration: none;
                color: white;
            }
            .btn-add     { background: #27ae60; }
            .btn-edit    { background: #f39c12; }
            .btn-del     { background: #e74c3c; }
            .btn-confirm { background: #27ae60; flex: 1; padding: 10px; }
            .btn-cancel  { background: #95a5a6; flex: 1; padding: 10px; }
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
            .room-price  { font-size: 13px; color: #27ae60; margin-top: 4px; }
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
                width: 400px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            }
            .popup h3 { margin-bottom: 20px; color: #2c3e50; font-size: 18px; }
            .form-group { margin-bottom: 14px; }
            .form-group label { display: block; margin-bottom: 6px; color: #555; font-size: 14px; }
            .form-group input,
            .form-group select {
                width: 100%;
                padding: 9px 12px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 14px;
            }
            .form-group input:focus,
            .form-group select:focus { outline: none; border-color: #4a90e2; }
            .popup-buttons { display: flex; gap: 10px; margin-top: 20px; }
        </style>
    </head>
    <body>

    <div class="navbar">
        <h1>🛏️ Quản Lý Phòng</h1>
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
            <button class="btn btn-add" onclick="openPopup('addPopup')">+ Thêm Phòng</button>
            <button class="btn btn-edit" onclick="openPopup('editPopup')">✏️ Sửa Phòng</button>
            <button class="btn btn-del" onclick="deleteSelected()">🗑️ Xóa Phòng</button>
        </div>

        <div class="room-grid">
            <% if (rooms != null) {
                for (String[] room : rooms) { %>
                    <div class="room-card" onclick="selectRoom(this, '<%= room[0] %>', '<%= room[1] %>', '<%= room[2] %>', '<%= room[3] %>', '<%= room[4] %>')">
                        <div class="room-number">🚪 <%= room[0] %></div>
                        <div class="room-type"><%= room[1] %></div>
                        <div class="room-price">
                            <%= String.format("%,.0f", Double.parseDouble(room[2])) %> đ/giờ |
                            <%= String.format("%,.0f", Double.parseDouble(room[3])) %> đ/đêm
                        </div>
                        <div class="room-status <%= room[4] %>"><%= room[4] %></div>
                        <%
                            if (bookingMap != null && bookingMap.containsKey(room[0])) {
                                String[] booking = bookingMap.get(room[0]);
                         %>
                        <div style="font-size:11px; color:#666; margin-top:6px;">
                            👤 <%= booking[0] %><br/>
                            🧑 <%= booking[3] != null ? booking[3] : "Chưa có tên" %><br/>
                            ⏱️ <%= booking[2] %>
                        </div>
                        <% } %>
                    </div>
                <% }
                } %>
            </div>                      
        </div>     


    <!-- Popup Thêm Phòng -->
    <div class="overlay" id="addPopup">
        <div class="popup">
            <h3>+ Thêm Phòng Mới</h3>
            <form action="RoomServlet" method="post">
                <input type="hidden" name="action" value="add" />
                <div class="form-group">
                    <label>Số phòng</label>
                    <input type="text" name="room_number" placeholder="Ví dụ: 301" required />
                </div>
                <div class="form-group">
                    <label>Loại phòng</label>
                    <select name="type">
                        <option value="Standard">Standard</option>
                        <option value="Deluxe">Deluxe</option>
                        <option value="Suite">Suite</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Giá/giờ (VNĐ)</label>
                    <input type="number" name="price_per_hour" placeholder="Ví dụ: 62500" required />
                </div>
                <div class="form-group">
                    <label>Giá/đêm (VNĐ)</label>
                    <input type="number" name="price_per_night" placeholder="Ví dụ: 500000" required />
</div>
                <div class="form-group">
                    <label>Trạng thái</label>
                    <select name="status">
                        <option value="available">Available</option>
                        <option value="occupied">Occupied</option>
                        <option value="maintenance">Maintenance</option>
                    </select>
                </div>
                <div class="popup-buttons">
                    <button type="submit" class="btn btn-confirm">✔ Xác Nhận</button>
                    <button type="button" class="btn btn-cancel" onclick="closePopup('addPopup')">✖ Hủy</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Popup Sửa Phòng -->
    <div class="overlay" id="editPopup">
        <div class="popup">
            <h3>✏️ Sửa Phòng</h3>
            <form action="RoomServlet" method="post">
                <input type="hidden" name="action" value="edit" />
                <div class="form-group">
                    <label>Số phòng</label>
                    <input type="text" name="room_number" id="edit_room_number" readonly
                        style="background:#f5f5f5;" />
                </div>
                <div class="form-group">
                    <label>Loại phòng</label>
                    <select name="type" id="edit_type">
                        <option value="Standard">Standard</option>
                        <option value="Deluxe">Deluxe</option>
                        <option value="Suite">Suite</option>
                    </select>
                </div>
                <div class="form-group">
                <label>Giá/giờ (VNĐ)</label>
                    <input type="number" name="price_per_hour" id="edit_price_hour" required />
                </div>
                <div class="form-group">
                    <label>Giá/đêm (VNĐ)</label>
                    <input type="number" name="price_per_night" id="edit_price_night" required />
                </div>
                <div class="form-group">
                    <label>Trạng thái</label>
                    <select name="status" id="edit_status">
                        <option value="available">Available</option>
                        <option value="occupied">Occupied</option>
                        <option value="maintenance">Maintenance</option>
                    </select>
                </div>
                <div class="popup-buttons">
                    <button type="submit" class="btn btn-confirm">✔ Xác Nhận</button>
                    <button type="button" class="btn btn-cancel" onclick="closePopup('editPopup')">✖ Hủy</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Form ẩn để xóa -->
    <form id="deleteForm" action="RoomServlet" method="post">
        <input type="hidden" name="action" value="delete" />
        <input type="hidden" name="room_number" id="delete_room_number" />
    </form>

    <script>
    let selectedRoom = null;

    function selectRoom(card, roomNumber, type, priceHour, priceNight, status) {
        document.querySelectorAll('.room-card').forEach(c => c.classList.remove('selected'));
        card.classList.add('selected');
        selectedRoom = { roomNumber, type, priceHour, priceNight, status };
    }

    function openPopup(id) {
        if (id === 'editPopup') {
            if (!selectedRoom) {
                alert('Vui lòng chọn phòng trước!');
                return;
            }
            document.getElementById('edit_room_number').value = selectedRoom.roomNumber;
            document.getElementById('edit_type').value = selectedRoom.type;
            document.getElementById('edit_price_hour').value = selectedRoom.priceHour;
            document.getElementById('edit_price_night').value = selectedRoom.priceNight;
            document.getElementById('edit_status').value = selectedRoom.status;
        }
        document.getElementById(id).classList.add('active');
    }

    function closePopup(id) {
        document.getElementById(id).classList.remove('active');
    }

    function deleteSelected() {
        if (!selectedRoom) {
            alert('Vui lòng chọn phòng trước!');
            return;
        }
        if (confirm('Bạn có chắc muốn xóa phòng ' + selectedRoom.roomNumber + '?')) {
            document.getElementById('delete_room_number').value = selectedRoom.roomNumber;
            document.getElementById('deleteForm').submit();
        }
    }
</script>

    </body>
    </html>