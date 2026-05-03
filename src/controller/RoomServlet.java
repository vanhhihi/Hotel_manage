package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/RoomServlet")
public class RoomServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/hotel_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "123456aA@";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String page = request.getParameter("page");
        if ("booking".equals(page)) {
            loadRooms(request, response, "booking.jsp");
        } else {
            loadRooms(request, response, "room.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addRoom(request, response);
        } else if ("edit".equals(action)) {
            editRoom(request, response);
        } else if ("delete".equals(action)) {
            deleteRoom(request, response);
        } else if ("book".equals(action)) {
            bookRoom(request, response);
        } else if ("checkout".equals(action)) {
            checkoutRoom(request, response);
        } else {
            response.sendRedirect("RoomServlet");
        }
    }

    private void loadRooms(HttpServletRequest request, HttpServletResponse response, String page)
            throws ServletException, IOException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);            // Load danh sách phòng
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM rooms ORDER BY room_number");

            List<String[]> rooms = new ArrayList<>();
            while (rs.next()) {
                String[] room = {
                    rs.getString("room_number"),   // room[0]
                    rs.getString("type"),           // room[1]
                    rs.getString("price_per_hour"), // room[2]
                    rs.getString("price_per_night"),// room[3]
                    rs.getString("status")          // room[4]
                };
                rooms.add(room);
            }
            rs.close(); stmt.close();

            // Load booking đang active
            Statement stmt2 = conn.createStatement();
            ResultSet rs2 = stmt2.executeQuery(
                "SELECT room_number, username, type, check_in, customer FROM bookings WHERE status='active'"
            );

            Map<String, String[]> bookingMap = new HashMap<>();
            while (rs2.next()) {
                String[] booking = {
                    rs2.getString("username"),  // booking[0]
                    rs2.getString("type"),      // booking[1]
                    rs2.getString("check_in"),  // booking[2]
                    rs2.getString("customer")   // booking[3]
                };
                bookingMap.put(rs2.getString("room_number"), booking);
            }
            rs2.close(); stmt2.close();
            conn.close();

            request.setAttribute("rooms", rooms);
            request.setAttribute("bookingMap", bookingMap);
            request.getRequestDispatcher(page).forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher(page).forward(request, response);
        }
    }

    private void addRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomNumber    = request.getParameter("room_number");
        String type          = request.getParameter("type");
        String pricePerHour  = request.getParameter("price_per_hour");
        String pricePerNight = request.getParameter("price_per_night");
        String status        = request.getParameter("status");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "INSERT INTO rooms (room_number, type, price_per_hour, price_per_night, status) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, roomNumber);
            ps.setString(2, type);
            ps.setDouble(3, Double.parseDouble(pricePerHour));
            ps.setDouble(4, Double.parseDouble(pricePerNight));
            ps.setString(5, status);
            ps.executeUpdate();

            ps.close(); conn.close();
            request.setAttribute("success", "Thêm phòng " + roomNumber + " thành công!");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getMessage());
        }

        loadRooms(request, response, "room.jsp");
    }

    private void editRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomNumber    = request.getParameter("room_number");
        String type          = request.getParameter("type");
        String pricePerHour  = request.getParameter("price_per_hour");
        String pricePerNight = request.getParameter("price_per_night");
        String status        = request.getParameter("status");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "UPDATE rooms SET type=?, price_per_hour=?, price_per_night=?, status=? WHERE room_number=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, type);
            ps.setDouble(2, Double.parseDouble(pricePerHour));
            ps.setDouble(3, Double.parseDouble(pricePerNight));
            ps.setString(4, status);
            ps.setString(5, roomNumber);
            ps.executeUpdate();

            ps.close(); conn.close();
            request.setAttribute("success", "Sửa phòng " + roomNumber + " thành công!");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getMessage());
        }

        loadRooms(request, response, "room.jsp");
    }

    private void deleteRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomNumber = request.getParameter("room_number");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            String sql = "DELETE FROM rooms WHERE room_number=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, roomNumber);
            ps.executeUpdate();

            ps.close(); conn.close();
            request.setAttribute("success", "Xóa phòng " + roomNumber + " thành công!");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getMessage());
        }

        loadRooms(request, response, "room.jsp");
    }

    private void bookRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomNumber   = request.getParameter("room_number");
        String type         = request.getParameter("type");
        String usernameBook = request.getParameter("username");
        String customer = request.getParameter("customer");
        System.out.println("Customer: " + customer);
        System.out.println("Encoding: " + request.getCharacterEncoding());
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            // Cập nhật status phòng
            String sqlRoom = "UPDATE rooms SET status='occupied' WHERE room_number=? AND status='available'";
            PreparedStatement ps1 = conn.prepareStatement(sqlRoom);
            ps1.setString(1, roomNumber);
            int rows = ps1.executeUpdate();
            ps1.close();

            if (rows > 0) {
                // Lưu booking vào bảng bookings
                String sqlBook = "INSERT INTO bookings (room_number, username, type, check_in, status, customer) VALUES (?, ?, ?, NOW(), 'active', ?)";
                PreparedStatement ps2 = conn.prepareStatement(sqlBook);
                ps2.setString(1, roomNumber);
                ps2.setString(2, usernameBook);
                ps2.setString(3, type);
                ps2.setString(4, customer);
                ps2.executeUpdate();
                ps2.close();

                request.setAttribute("success", "Đặt phòng " + roomNumber + " thành công!");
            } else {
                request.setAttribute("error", "Phòng " + roomNumber + " không available!");
            }

            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getMessage());
        }

        loadRooms(request, response, "booking.jsp");
    }

    private void checkoutRoom(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    String roomNumber = request.getParameter("room_number");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        // Lấy thông tin booking hiện tại
        String sqlGet = "SELECT b.type, b.check_in, r.price_per_hour, r.price_per_night " +
                        "FROM bookings b JOIN rooms r ON b.room_number = r.room_number " +
                        "WHERE b.room_number=? AND b.status='active'";
        PreparedStatement psGet = conn.prepareStatement(sqlGet);
        psGet.setString(1, roomNumber);
        ResultSet rs = psGet.executeQuery();

        double totalPrice = 0;

        if (rs.next()) {
            String type         = rs.getString("type");
            Timestamp checkIn   = rs.getTimestamp("check_in");
            double pricePerHour = rs.getDouble("price_per_hour");
            double pricePerNight= rs.getDouble("price_per_night");

            // Tính thời gian đã ở
            long now      = System.currentTimeMillis();
            long checkinMs= checkIn.getTime();
            long diffMs   = now - checkinMs;

            if ("hourly".equals(type)) {
                long diffMinutes = (long) Math.ceil((double) diffMs / (1000 * 60));
                totalPrice = diffMinutes * (pricePerHour / 60.0);
            } else {
                long diffDays = (long) Math.ceil((double) diffMs / (1000 * 60 * 60 * 24));
                totalPrice = diffDays * pricePerNight;
            }
        }
        rs.close(); psGet.close();

        // Cập nhật status phòng
        String sqlRoom = "UPDATE rooms SET status='available' WHERE room_number=? AND status='occupied'";
        PreparedStatement ps1 = conn.prepareStatement(sqlRoom);
        ps1.setString(1, roomNumber);
        int rows = ps1.executeUpdate();
        ps1.close();

        if (rows > 0) {
            // Cập nhật booking với total_price và check_out
            String sqlBook = "UPDATE bookings SET status='done', check_out=NOW(), total_price=? " +
                             "WHERE room_number=? AND status='active'";
            PreparedStatement ps2 = conn.prepareStatement(sqlBook);
            ps2.setDouble(1, totalPrice);
            ps2.setString(2, roomNumber);
            ps2.executeUpdate();
            ps2.close();

            request.setAttribute("success", "Trả phòng " + roomNumber + " thành công! Tổng tiền: " +
                String.format("%,.0f", totalPrice) + " đ");
        } else {
            request.setAttribute("error", "Phòng " + roomNumber + " chưa được đặt!");
        }

        conn.close();

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Lỗi: " + e.getMessage());
    }

    loadRooms(request, response, "booking.jsp");
    }
}