package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CustomerServlet")
public class CustomerServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/hotel_db";
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

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // 1 query duy nhất, group trong Java
            String sql =
                "SELECT customer, room_number, type, check_in, check_out, total_price, status " +
                "FROM bookings " +
                "WHERE customer IS NOT NULL " +
                "ORDER BY customer ASC, check_in DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            // LinkedHashMap giữ đúng thứ tự
            Map<String, List<String[]>> detailMap = new LinkedHashMap<>();
            Map<String, Double>         totalMap  = new LinkedHashMap<>();
            Map<String, Integer>        countMap  = new LinkedHashMap<>();

            while (rs.next()) {
                String cust = rs.getString("customer");
                String[] row = {
                    rs.getString("room_number"),  // row[0]
                    rs.getString("type"),          // row[1]
                    rs.getString("check_in"),      // row[2]
                    rs.getString("check_out"),     // row[3]
                    rs.getString("total_price"),   // row[4]
                    rs.getString("status")         // row[5]
                };

                if (!detailMap.containsKey(cust)) {
                    detailMap.put(cust, new ArrayList<>());
                    totalMap.put(cust, 0.0);
                    countMap.put(cust, 0);
                }
                detailMap.get(cust).add(row);
                countMap.put(cust, countMap.get(cust) + 1);
                if (row[4] != null) {
                    totalMap.put(cust, totalMap.get(cust) + Double.parseDouble(row[4]));
                }
            }

            rs.close(); stmt.close(); conn.close();

            // Tạo customers cùng thứ tự với detailMap
            List<String[]> customers = new ArrayList<>();
            for (String cust : detailMap.keySet()) {
                customers.add(new String[]{
                    cust,
                    String.valueOf(countMap.get(cust)),
                    String.valueOf(totalMap.get(cust))
                });
            }

            request.setAttribute("customers", customers);
            request.setAttribute("detailMap", detailMap);
            request.getRequestDispatcher("customer.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("customer.jsp").forward(request, response);
        }
    }
}