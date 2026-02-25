package com.example.demo.admin.dto;

public class ComplaintDto {

    private Long id;
    private String user;
    private String type;
    private String status;
    private String date;

    public ComplaintDto() {
    }

    public ComplaintDto(Long id,
                        String user,
                        String type,
                        String status,
                        String date) {
        this.id = id;
        this.user = user;
        this.type = type;
        this.status = status;
        this.date = date;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUser() { return user; }
    public void setUser(String user) { this.user = user; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
}
