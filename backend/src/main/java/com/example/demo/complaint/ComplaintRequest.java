package com.example.demo.complaint;

public class ComplaintRequest {

    private String user;
    private String email;
    private String type;
    private String message;

    public ComplaintRequest() {
    }

    public String getUser() { return user; }
    public void setUser(String user) { this.user = user; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
