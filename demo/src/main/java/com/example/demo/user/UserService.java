package com.example.demo.user;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;



@Service
public class UserService {

    private final UserRepository repo;

    @Autowired
    public UserService(UserRepository repo) {
        this.repo = repo;
    }

    /**
     * Register a new user.
     * Throws IllegalArgumentException when username/email already exists or required fields missing.
     */
    public User registerUser(User user) {
        if (user == null
                || user.getUsername() == null || user.getUsername().trim().isEmpty()
                || user.getPassword() == null || user.getPassword().trim().isEmpty()
                || user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Missing required fields");
        }

        if (repo.existsByUsername(user.getUsername())) {
            throw new IllegalArgumentException("Username already exists");
        }

        if (repo.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        // NOTE: For production, hash the password (BCrypt). For now we store as plain text for demo.
        return repo.save(user);
    }

    /**
     * Simple authentication check (username + password).
     * Returns the found User on success, or empty Optional on failure.
     */
    public Optional<User> authenticate(String username, String password) {
        if (username == null || password == null) return Optional.empty();
        return repo.findByUsername(username)
                   .filter(u -> password.equals(u.getPassword()));
    }
}
