package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/BillServlet")
public class BillServlet extends HttpServlet {

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

        String date = request.getParameter("date");

        if (date != null) {
            // Load hóa đơn chi tiết theo ngày → day.jsp
            loadByDay(request, response, date);
        } else {
            // Load tổng hợp 10 ngày gần nhất → bill.jsp
            loadSummary(request, response);
        }
    }

    // Load tổng tiền theo từng ngày trong 10 ngày gần nhất
    private void loadSummary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql =
                "SELECT DATE(check_out) as ngay, " +
                "COUNT(*) as so_phong, " +
                "SUM(total_price) as tong_tien " +
                "FROM bookings " +
                "WHERE status='done' AND check_out IS NOT NULL AND total_price IS NOT NULL " +
                "AND check_out >= DATE_SUB(CURDATE(), INTERVAL 10 DAY) " +
                "GROUP BY DATE(check_out) " +
                "ORDER BY ngay DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            List<String[]> summary = new ArrayList<>();
            while (rs.next()) {
                String[] row = {
                    rs.getString("ngay"),       // row[0] ngày
                    rs.getString("so_phong"),   // row[1] số phòng
                    rs.getString("tong_tien")   // row[2] tổng tiền
                };
                summary.add(row);
            }

            rs.close(); stmt.close(); conn.close();

            request.setAttribute("summary", summary);
            request.getRequestDispatcher("bill.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("bill.jsp").forward(request, response);
        }
    }

    // Load hóa đơn chi tiết theo ngày
    private void loadByDay(HttpServletRequest request, HttpServletResponse response, String date)
        throws ServletException, IOException {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String sql =
            "SELECT room_number, username, type, check_in, check_out, total_price, customer " +
            "FROM bookings " +
            "WHERE status='done' AND total_price IS NOT NULL AND DATE(check_out) = ? " +
            "ORDER BY check_out DESC";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, date);
        ResultSet rs = ps.executeQuery();

        List<String[]> bills = new ArrayList<>();
        while (rs.next()) {
            String[] row = {
                rs.getString("room_number"),
                rs.getString("username"),
                rs.getString("type"),
                rs.getString("check_in"),
                rs.getString("check_out"),
                rs.getString("total_price"),
                rs.getString("customer")
            };
            bills.add(row);
        }

        rs.close(); ps.close(); conn.close();

        request.setAttribute("bills", bills);
        request.setAttribute("date", date);
        request.getRequestDispatcher("day.jsp").forward(request, response);

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        request.setAttribute("date", date);
        request.getRequestDispatcher("day.jsp").forward(request, response);
    }
}
}