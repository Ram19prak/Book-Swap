package bookswap;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import java.sql.*;
import java.io.*;
import java.util.Base64;

@WebServlet("/addbookServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 10,   // 10MB
    maxFileSize = 1024 * 1024 * 50,         // 50MB
    maxRequestSize = 1024 * 1024 * 100      // 100MB
)
public class addbookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("id"); // Retrieve as Integer, which can be null

        // Check if the userId is null, meaning the user is not logged in
        if (userId == null) {
            response.sendRedirect("login.html?error=You must be logged in to add a book.");
            return;
        }

        String book = request.getParameter("bookname");
        String author = request.getParameter("author");
        String category = request.getParameter("category");
        String status = request.getParameter("status");

        Part photo = request.getPart("bookphoto");

        InputStream photoInputStream = null;
        if (photo != null) {
            photoInputStream = photo.getInputStream();
        }

        Connection con = null;
        PreparedStatement stmt = null;
        String query = "INSERT INTO books (book_name, author, book_category, status, photo, user_id) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "");

            stmt = con.prepareStatement(query);
            stmt.setString(1, book);
            stmt.setString(2, author);
            stmt.setString(3, category);
            stmt.setString(4, status);
            stmt.setBlob(5, photoInputStream); // Store the image as a BLOB
            stmt.setInt(6, userId); // Use the userId directly
            int rows = stmt.executeUpdate();

            if (rows > 0) {
                response.sendRedirect("home.jsp?message=Book added successfully.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp?error=" + e.getMessage());
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

}
