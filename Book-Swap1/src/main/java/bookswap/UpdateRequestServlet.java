package bookswap;

import java.io.IOException;
import bookswap.mail7;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/UpdateRequestServlet")
public class UpdateRequestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");
        String bookIdStr = request.getParameter("bookId");

        if (action == null || requestIdStr == null || bookIdStr == null) {
            response.getWriter().write("Error: Missing parameters.");
            return;
        }

        int requestId, bookId;
        try {
            requestId = Integer.parseInt(requestIdStr);
            bookId = Integer.parseInt(bookIdStr);
        } catch (NumberFormatException e) {
            response.getWriter().write("Error: Invalid request or book ID.");
            return;
        }

        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "")) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Fetch email and phone number of the book owner
            String[] ownerDetails = fetchBookOwnerDetails(con, bookId);
            String recipientEmail = fetchRequesterEmail(con, requestId);
            if (ownerDetails == null) {
                response.getWriter().write("Error: Book owner not found.");
                return;
            }
            String ownerEmail = ownerDetails[0];
            String ownerPhone = ownerDetails[1];

            String subject, body;
            if ("accept".equalsIgnoreCase(action)) {
                updateRequestStatus(con, requestId, bookId);
                subject = "Request Accepted";
                body = "Your request for book ID " + bookId + " has been accepted. " +
                       "\nThe owner of the book can be contacted at Email: " + ownerEmail + 
                       "\nPhone: " + ownerPhone + ".";
            } else if ("decline".equalsIgnoreCase(action)) {
                deleteRequest(con, requestId);
                subject = "Request Declined";
                body = "Your request for book ID " + bookId + " has been declined.";
            } else {
                response.getWriter().write("Error: Invalid action.");
                return;
            }

            // Send email
            mail7 obj = new mail7(recipientEmail, subject, body);
            obj.sendMail();

            response.getWriter().write("Request processed successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error: An unexpected error occurred - " + e.getMessage());
        }
    }

    private String fetchRequesterEmail(Connection con, int requestId) throws SQLException {
        String query = "SELECT u.email FROM requests r JOIN user u ON r.requesting_user_id = u.id WHERE r.id = ?";
        try (PreparedStatement stmt = con.prepareStatement(query)) {
            stmt.setInt(1, requestId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("email");
                }
            }
        }
        return null;
    }
    private String[] fetchBookOwnerDetails(Connection con, int bookId) throws SQLException {
        String query = "SELECT u.email, u.phone_number " +
                       "FROM books b JOIN user u ON b.user_id = u.id WHERE b.book_id = ?";
        try (PreparedStatement stmt = con.prepareStatement(query)) {
            stmt.setInt(1, bookId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new String[] { rs.getString("email"), rs.getString("phone_number") };
                }
            }
        }
        return null;
    }

    private void updateRequestStatus(Connection con, int requestId, int bookId) throws SQLException {
        String updateRequest = "UPDATE requests SET status = 'accepted' WHERE id = ?";
        String updateBook = "UPDATE books SET status = 'unavailable' WHERE book_id = ?";
        try (PreparedStatement stmt1 = con.prepareStatement(updateRequest);
             PreparedStatement stmt2 = con.prepareStatement(updateBook)) {
            stmt1.setInt(1, requestId);
            stmt1.executeUpdate();

            stmt2.setInt(1, bookId);
            stmt2.executeUpdate();
        }
    }

    private void deleteRequest(Connection con, int requestId) throws SQLException {
        String query = "DELETE FROM requests WHERE id = ?";
        try (PreparedStatement stmt = con.prepareStatement(query)) {
            stmt.setInt(1, requestId);
            stmt.executeUpdate();
        }
    }
}
