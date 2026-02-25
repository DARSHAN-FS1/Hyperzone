package com.example.demo.exception;

import java.time.Instant;
import java.util.Map;

public class ApiError {
    private Instant timestamp;
    private int status;
    private String error;
    private String message;
    private Map<String, Object> details;

    public ApiError() {
        this.timestamp = Instant.now();
    }

    public ApiError(int status, String error, String message) {
        this();
        this.status = status;
        this.error = error;
        this.message = message;
    }

    public ApiError(int status, String error, String message, Map<String,Object> details) {
        this(status, error, message);
        this.details = details;
    }

    // getters & setters
    public Instant getTimestamp() { return timestamp; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Map<String, Object> getDetails() { return details; }
    public void setDetails(Map<String, Object> details) { this.details = details; }
}
