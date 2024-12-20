package bookswap;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;


@WebServlet("/loginServlet")
public class loginServlet extends HttpServlet {
   
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "");

            String query = "SELECT id, username FROM user WHERE email = ? AND password = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, email);
            stmt.setString(2, password); 
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
            	HttpSession session = request.getSession();
            	session.setAttribute("id", rs.getInt("id"));
                session.setAttribute("name", rs.getString("username"));
                response.sendRedirect("home.jsp");
            } else {
                response.setContentType("text/html");
                response.getWriter().println("<p>Invalid email or password. <a href='login.html'>Try again</a></p>");
            }
        } catch (ClassNotFoundException e) {
            response.getWriter().println("Error: MySQL JDBC Driver not found.");
            e.printStackTrace(response.getWriter());
        } catch (SQLException e) {
            response.getWriter().println("Error: Unable to log in.");
            e.printStackTrace(response.getWriter());
        }
	}

}
