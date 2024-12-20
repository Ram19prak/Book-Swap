package bookswap;

import java.io.IOException;
import java.sql.*;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/RequestHandlerServlet")

public class RequestHandlerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // No need to declare SQLException in the throws clause
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("id") != null) {
            int userId = (int) session.getAttribute("id");
            String bookIdStr = request.getParameter("BookId");
            String ownerIdStr = request.getParameter("ownerId");

            if (bookIdStr != null && !bookIdStr.isEmpty() && ownerIdStr != null && !ownerIdStr.isEmpty()) {
                try {
                    int bookId = Integer.parseInt(bookIdStr);
                    int ownerId = Integer.parseInt(ownerIdStr);
                    System.out.println("UserId: " + userId);
                    System.out.println("BookId: " + bookId);
                    System.out.println("OwnerId: " + ownerId);

                    // Open the database connection
                    Connection con = null;
                    PreparedStatement checkStmt = null;
                    PreparedStatement insertStmt = null;
                    ResultSet rs = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "");
                        
                        // Disable auto-commit to manage transactions manually
                        con.setAutoCommit(false);
                        
                        // Check if the request already exists
                        String checkQuery = "SELECT COUNT(*) FROM requests WHERE book_id = ? AND requesting_user_id = ? AND book_owner_id = ?";
                        checkStmt = con.prepareStatement(checkQuery);
                        checkStmt.setInt(1, bookId);
                        checkStmt.setInt(2, userId);
                        checkStmt.setInt(3, ownerId);
                        
                        rs = checkStmt.executeQuery();
                        if (rs.next()) {
                            int count = rs.getInt(1); // Get the count of the matching rows
                            
                            if (count > 0) {
                                // If the request already exists, inform the user
                                response.getWriter().write("You have already requested this book.");
                            } else {
                                // Proceed with the insert as no duplicate found
                                String insertQuery = "INSERT INTO requests (book_id, requesting_user_id, book_owner_id, status) VALUES (?, ?, ?, 'Pending')";
                                insertStmt = con.prepareStatement(insertQuery);
                                insertStmt.setInt(1, bookId);
                                insertStmt.setInt(2, userId);
                                insertStmt.setInt(3, ownerId);
                                
                                insertStmt.executeUpdate();

                                con.commit();
                                count = 0;
                                response.sendRedirect("home.jsp"); // Redirect to home page after request
                            }
                        }
                    } catch (SQLException | ClassNotFoundException e) {
                       if (con != null) {
                            try {
								con.rollback();
							} catch (SQLException e1) {
								
								e1.printStackTrace();
							}
                        }
                        e.printStackTrace();
                        response.getWriter().write("Error occurred while processing your request. Please try again later.");
                    } finally {
                        try {
                            if (rs != null) rs.close();
                            if (checkStmt != null) checkStmt.close();
                            if (insertStmt != null) insertStmt.close();
                            if (con != null) con.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                    response.getWriter().write("Invalid Book ID or Owner ID.");
                }
            }
        } else {
            response.getWriter().write("You must be logged in to send a request.");
        }
    }
}
