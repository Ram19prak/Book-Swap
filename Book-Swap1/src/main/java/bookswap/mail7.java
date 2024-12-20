package bookswap;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class mail7 {
    private String toEmail;
    private String subject;
    private String body;

    private static final String senderMail = "m99702251@gmail.com"; // Your email
    private static final String senderPassword = "kmmxndbwddkehova"; // Your app-specific password
    private static final String host = "smtp.gmail.com";

    // Constructor to initialize email details
    public mail7(String toEmail, String subject, String body) {
        this.toEmail = toEmail;
        this.subject = subject;
        this.body = body;
        System.out.println(toEmail +" "+ subject +" "+ body);
    }
    

    // Method to send mail
    protected void sendMail() {
        // Mail server properties
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", "587");

        // Authenticate and create session
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderMail, senderPassword);
            }
        });

        try {
            // Compose email
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderMail, "BookSwap"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(body);

            // Send email
            Transport.send(message);
            System.out.println("Email sent successfully to " + toEmail);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Failed to send email to " + toEmail);
        }
    }
}
