package bookswap;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Servlet implementation class registration
 */
@WebServlet("/registration")
public class registration extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database connection details
    private static final String DB_URL = "jdbc:mysql://localhost:3306/book_swap"; // Change to your DB name
    private static final String DB_USER = "root";  // Change to your MySQL username
    private static final String DB_PASSWORD = "";  // Change to your MySQL password

    public registration() {
        super();
    }

    // Handle POST request to register user
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String name = request.getParameter("name");
        String password = request.getParameter("password");

        // Validate email format
        if (!isValidEmail(email)) {
            response.getWriter().println("Invalid email format.");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            // Step 1: Establish the connection
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Step 2: Prepare the SQL insert statement
            String sql = "INSERT INTO user (email, username, password) VALUES (?, ?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, name);
            stmt.setString(3, password);

            // Step 3: Execute the update
            int rowsInserted = stmt.executeUpdate();
            if (rowsInserted > 0) {
                response.sendRedirect("login.html");
            } else {
                response.getWriter().println("Error during registration.");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("Database error: " + e.getMessage());
        } 
    }

    // Validate email using regular expression
    private boolean isValidEmail(String email) {
        // Regex to validate email format
        String regex = "^[A-Za-z0-9+_.-]+@(.+)$";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }
}
