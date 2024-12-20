<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*, java.util.Base64" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Home Page</title>

    <link rel="stylesheet" href="style1.css">
    
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body style="background_color:images/slide_04.jpg;">
    <div class="container">
        <header>
            <h2>
                <em>Welcome,</em> 
                <% 
                    session = request.getSession(false);
                    if (session != null && session.getAttribute("name") != null) {
                        out.print(session.getAttribute("name"));
                    } else {
                        response.sendRedirect("login.html"); 
                    }
                %>
            </h2>
        </header>
        <nav>
            <ul>
                <li><a href="home.jsp">Home</a></li>
                <li><a href="#"></a></li>
                <li><a href="#"></a></li>
                <li><a href="#"></a></li>
                <li><a href="login.html">Logout</a></li>
            </ul>
        </nav>
        
        <div class="row">
            <div class="col-md-4">
                <div class="option-item">
                <a href="#"><img src="assets/images/products-heading_01.jpg" alt=""></a>
                    <a href="addBook.jsp">
                        <li><a href="javascript:void(0);" onclick="showForm('addBook')"><b>Add Book</b></a></li>
                    </a>
                    <p>Click here to add a new book to the system.</p>
                </div>
            </div>
            
            <!-- Option to View Books -->
            <div class="col-md-4">
                <div class="option-item">
                <a href="#"><img src="assets/images/products-heading_02.jpg" alt=""></a>
                    <a href="viewBooks.jsp">
                        <li><a href="javascript:void(0);" onclick="showForm('viewBooks')"><b>View Books</b></a></li>
                    </a>
                    <p>Click here to view the list of books in the system.</p>
                </div>
            </div>

            <!-- Option to View Requests -->
            <div class="col-md-4">
                <div class="option-item">
                <a href="#"><img src="assets/images/products-heading_04.jpg" alt=""></a>
                    <a href="viewRequests.jsp">
                        <li><a href="javascript:void(0);" onclick="showForm('available')"><b>Available books</b></a></li>
                    </a>
                    <p>Click here to view available books.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="option-item">
                <a href="#"><img src="assets/images/products-heading_03.jpg" alt=""></a>
                    <a href="viewRequests.jsp">
                        <li><a href="javascript:void(0);" onclick="showForm('viewRequests')"><b>View Requests</b></a></li>
                    </a>
                    <p>Click here to view user requests for books.</p>
                </div>
            </div>
        </div>
    </div>

<div class="form-container">
		<% String errormsg = request.getParameter("error"); %>
		<% if(errormsg != null) {%>
			<center><h2 style="color:red; background-color:white"><%= errormsg %></h2></center>
		<%} %>
		
		<% String successmsg = request.getParameter("success"); 
			if(successmsg != null) {
		%>
		<center><h2 style="color:green; background-color:white"><%= successmsg %></h2></center>
		<%} %>
        <!-- Add Book Form -->
        <div id="addBook" class="form-box">
            <div class="form-content">
                <h2>Add Book</h2>
                <form action="addbookServlet"  method="post" enctype="multipart/form-data">
                    <div class="input-field">
                    <label>Book Name</label>
                        <input type="text" name="bookname" required>
                    </div>
                    <div class="input-field">
                                            <label>Author</label>
                        <input type="text" name="author" required>
                    </div>
                   
                    <div class="input-field">
                      <label>Category</label>
                        <input type="text" name="category" required>
                      
                    </div>
                    <div class="input-field">
                      <label>Status</label>
						<select name="status" required>
						    <option value="available">Available</option>
						    <option value="unavailable">Unavailable</option>
						</select>
                    </div>
                    <div class="input-field">
                    <label>Upload Book Photo</label>
                        <input type="file" name="bookphoto" required>
                        
                    </div>
                    <button type="submit">Add Book</button>
                </form>
            </div>
        </div>

        <!-- View Books Form -->
<div id="viewBooks" class="form-box" style="display:none;">
    <div class="form-content">
        <h2>View Books</h2>
        <p>Here you can view all the books added by you.</p>
        <form enctype="multipart/form-data">
            <br>
            <div id="bookList">
                <table border="2" style="color:black;">
                    <thead>
                        <tr>
                            <th>Book Name</th>
                            <th>Author</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>Photo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        session = request.getSession(false); // Use false to avoid creating a new session
                        int userId = 0; // Default value

                        if (session != null && session.getAttribute("id") != null) {
                            userId = (int) session.getAttribute("id");
                        } 

                            if (userId != 0) {
                                Connection con = null;
                                PreparedStatement stmt = null;
                                ResultSet rs = null;
                                String query = "SELECT book_name, author, book_category, status, photo FROM books WHERE user_id = ?"; 
                                
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "");
                                    stmt = con.prepareStatement(query);
                                    stmt.setInt(1, userId); 
                                    rs = stmt.executeQuery();

                                    while (rs.next()) {
                                        String bookName = rs.getString("book_name");
                                        String author = rs.getString("author");
                                        String category = rs.getString("book_category");
                                        String status = rs.getString("status");
                                        Blob photo = rs.getBlob("photo");

                                        out.print("<tr>");
                                        out.print("<td>" + bookName + "</td>");
                                        out.print("<td>" + author + "</td>");
                                        out.print("<td>" + category + "</td>");
                                        out.print("<td>" + status + "</td>");
                                        
                                       
                                        if (photo != null) {
                                            try {
                                                // Retrieve and encode the photo blob
                                                byte[] photoBytes = photo.getBytes(1, (int) photo.length());
                                                String encodedPhoto = Base64.getEncoder().encodeToString(photoBytes);

                                                // Render the image tag with proper MIME type
                                                out.print("<td><img src='data:image/jpeg;base64," + encodedPhoto + "' alt='Book Image' width='100' height='100' /></td>");
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                                out.print("<td>Error Loading Image</td>");
                                            }
                                        } else {
                                            out.print("<td>No Image</td>");
                                        }

                                        out.print("</tr>");
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    try {
                                        if (rs != null) rs.close();
                                        if (stmt != null) stmt.close();
                                        if (con != null) con.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            } else {
                                out.print("<tr><td colspan='5'>You must be logged in to view books.</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </form>
    </div>
</div>


<div id="viewRequests" class="form-box">
    <div class="form-content">
        <h2>View Requests</h2>
        <p>Here you can view all the user requests for books.</p>
        <table border="2" style="color:black;">
            <thead>
                <tr>
                    <th>Book Name</th>
                    <th>Requester</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    session = request.getSession(false);
                    if (session != null && session.getAttribute("id") != null) {
                        userId = (int) session.getAttribute("id");
                        Connection con = null;
                        PreparedStatement stmt = null;
                        ResultSet rs = null;

                        String query = "SELECT r.id AS request_id, b.book_name, u.username AS requester_name, r.status, r.book_id FROM requests r JOIN books b ON r.book_id = b.book_id JOIN user u ON r.requesting_user_id = u.id WHERE book_owner_id = ?";
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "");
                            stmt = con.prepareStatement(query);
                            stmt.setInt(1, userId);
                            rs = stmt.executeQuery();

                            while (rs.next()) {
                                int requestId = rs.getInt("request_id");
                                String bookName = rs.getString("book_name");
                                String requesterName = rs.getString("requester_name");
                                String status = rs.getString("status");
                                int bookId = rs.getInt("book_id");

                                out.print("<tr>");
                                out.print("<td>" + bookName + "</td>");
                                out.print("<td>" + requesterName + "</td>");
                                out.print("<td>" + status + "</td>");
                                if ("pending".equalsIgnoreCase(status)) {
                                    out.print("<td>");
                                    out.print("<button type='button' style='background-color:green;' onclick=\"updateRequest('accept', " + requestId + ", " + bookId + ")\">Accept</button>");
                                    out.print("<button type='button' style='background-color:red;' onclick=\"updateRequest('decline', " + requestId + ", " + bookId + ")\">Decline</button>");
                                    out.print("</td>");
                                } else {
                                    out.print("<td>No actions available</td>");
                                }
                                out.print("</tr>");
                            }
                        } catch (Exception e) {
                            out.print("<tr><td colspan='4'>" + e + "</td></tr>");
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (stmt != null) stmt.close();
                                if (con != null) con.close();
                            } catch (SQLException e) {
                                out.print("<tr><td colspan='4'>" + e + "</td></tr>");
                            }
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="4">You must be logged in to view requests.</td>
                    </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        <h2>Your Request</h2>
        <table border="2" style="color:black;">
            <thead>
                <tr>
                    <th>Book Name</th>
                    <th>Owner Name</th>
                    <th>Status</th>
                    <th>Updated at</th>
                </tr>
            </thead>
            <tbody>
                <%
                    session = request.getSession(false);
                    if (session != null && session.getAttribute("id") != null) {
                        userId = (int) session.getAttribute("id");
                        Connection con = null;
                        PreparedStatement stmt = null;
                        ResultSet rs = null;

                        String query = "SELECT r.id AS request_id, b.book_name, u.username AS owner_name, r.status, r.book_id ,r.updated_at  FROM requests r JOIN books b ON r.book_id = b.book_id JOIN user u ON r.book_owner_id = u.id WHERE r.requesting_user_id = ? AND (r.status = ? OR r.status = ?) ";
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "");
                            stmt = con.prepareStatement(query);
                            stmt.setInt(1, userId);
                            stmt.setString(2, "accepted");
                            stmt.setString(3, "pending");
                            rs = stmt.executeQuery();

                            while (rs.next()) {
                                int requestId = rs.getInt("request_id");
                                String bookName = rs.getString("book_name");
                                String ownerName = rs.getString("owner_name");
                                String status = rs.getString("status");
                                String update = rs.getString("updated_at");
                                int bookId = rs.getInt("book_id");

                                out.print("<tr>");
                                out.print("<td>" + bookName + "</td>");
                                out.print("<td>" + ownerName + "</td>");
                                out.print("<td>" + status + "</td>");
                                out.print("<td>" + update + "</td>");
                                out.print("</tr>");
                            }
                        } catch (Exception e) {
                            out.print("<tr><td colspan='4'>" + e + "</td></tr>");
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (stmt != null) stmt.close();
                                if (con != null) con.close();
                            } catch (SQLException e) {
                                out.print("<tr><td colspan='4'>" + e + "</td></tr>");
                            }
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="4">You must be logged in to view requests.</td>
                    </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>
</div>

<script>
function updateRequest(action, requestId, bookId) {
    console.log("Action:", action, "Request ID:", requestId, "Book ID:", bookId);
    
    const params = new URLSearchParams();
    params.append("action", action);
    params.append("requestId", requestId);
    params.append("bookId", bookId);

    fetch("UpdateRequestServlet", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: params.toString(),
    })
    .then(response => response.text())
    .then(data => {
        alert(data);
    })
    .catch(error => console.error("Error:", error));

}

</script>



<div id="available" class="form-box">
    <div class="form-content">
        <h2>Available Books</h2>
        <p>Here you can view all books.</p>
        <form id="requestForm" action="RequestHandlerServlet" method="post">
            <!-- Hidden fields for dynamic data -->
            <input type="hidden" id="BookId" name="BookId">
            <input type="hidden" id="ownerId" name="ownerId">
            <div id="bookList">
                <table border="2" style="color:black;">
                    <thead>
                        <tr>
                            <th>Book Name</th>
                            <th>Author</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>UserName</th>
                            <th>Photo</th>
                            <th>Request</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            session = request.getSession(false);
                            if (session != null && session.getAttribute("id") != null) {
                                userId = (int) session.getAttribute("id");
                                Connection con = null;
                                PreparedStatement stmt = null;
                                ResultSet rs = null;

                                String query = "SELECT b.book_name, b.author, b.book_category, b.status, b.photo, b.book_id, u.username, b.user_id " +
                                               "FROM books b JOIN user u ON b.user_id = u.id WHERE b.user_id != ?";
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/book_swap", "root", "");
                                    stmt = con.prepareStatement(query);
                                    stmt.setInt(1, userId);
                                    rs = stmt.executeQuery();

                                    while (rs.next()) {
                                        String bookName = rs.getString("book_name");
                                        String author = rs.getString("author");
                                        String category = rs.getString("book_category");
                                        String status = rs.getString("status");
                                        Blob photo = rs.getBlob("photo");
                                        String username = rs.getString("username");
                                        int bookId = rs.getInt("book_id");
                                        int ownerId = rs.getInt("user_id");

                                        out.print("<tr>");
                                        out.print("<td>" + bookName + "</td>");
                                        out.print("<td>" + author + "</td>");
                                        out.print("<td>" + category + "</td>");
                                        out.print("<td>" + status + "</td>");
                                        out.print("<td>" + username + "</td>");
                                        if (photo != null) {
                                            byte[] photoBytes = photo.getBytes(1, (int) photo.length());
                                            String encodedPhoto = Base64.getEncoder().encodeToString(photoBytes);
                                            out.print("<td><img src='data:image/jpeg;base64," + encodedPhoto + "' width='100' height='100' /></td>");
                                        } else {
                                            out.print("<td>No Image</td>");
                                        }

                                        if ("available".equalsIgnoreCase(status)) {
                                            out.print("<td><button type='button' onclick=\"sendRequest('" + bookId + "', '" + ownerId + "')\">Send Request</button></td>");
                                        } else {
                                            out.print("<td>Unavailable</td>");
                                        }
                                        out.print("</tr>");
                                    }
                                } catch (Exception e) {
                                    out.print(e);
                                } finally {
                                    try {
                                        if (rs != null) rs.close();
                                        if (stmt != null) stmt.close();
                                        if (con != null) con.close();
                                    } catch (SQLException e) {
                                        out.print(e);
                                    }
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="7">You must be logged in to view books.</td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </form>
    </div>
</div>



    </div>
</div>

<script>
        function showForm(formId) {
            var forms = document.querySelectorAll('.form-box');
            forms.forEach(function(form) {
                form.style.display = 'none';
            });

            var selectedForm = document.getElementById(formId);
            if (selectedForm) {
                selectedForm.style.display = 'block';
            }
        }
        
        function sendRequest(bookId, ownerId) {
            document.getElementById('BookId').value = bookId;
            document.getElementById('ownerId').value = ownerId;
            document.getElementById('requestForm').submit();
        }


</script>

    <footer>
        <p>&copy; 2024 Book Swap Platform</p>
    </footer>
</body>
</html>
