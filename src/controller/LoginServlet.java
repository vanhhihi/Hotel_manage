package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    // ---- Cấu hình kết nối DB ----
    private static final String DB_URL  = "jdbc:mysql://localhost:3306/hotel_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "123456aA@";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
            PreparedStatement ps = conn.prepareStatement(sql); // chuẩn bị câu lệnh 
            ps.setString(1, username);
            ps.setString(2, password);   // thay ? thứ 2 bằng password

            ResultSet rs = ps.executeQuery();// gửi câu lệnh lên mysql và nhận kết quả 

            if (rs.next()) {
                // Đăng nhập thành công → lưu session
                HttpSession session = request.getSession();// tạo một bộ nhớ tạm trên RAM để luuw thông tin
                session.setAttribute("username", username);
                session.setAttribute("role", rs.getString("role"));
                response.sendRedirect("home.jsp");
            } else {
                // Sai tài khoản / mật khẩu
                request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

            rs.close(); ps.close(); conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Truy cập trực tiếp URL → chuyển về trang login
        response.sendRedirect("login.jsp");
    }
}