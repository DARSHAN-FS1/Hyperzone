package com.example.demo.user;

import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserController(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // Register new user
    @PostMapping
    public ResponseEntity<?> createUser(@Valid @RequestBody UserRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(new ErrorMessage(409, "Email already registered"));
        }

        if (userRepository.existsByUsername(req.getUsername())) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(new ErrorMessage(409, "Username already taken"));
        }

        User u = new User();
        u.setUsername(req.getUsername());
        u.setEmail(req.getEmail());
        u.setPassword(passwordEncoder.encode(req.getPassword()));

        User saved = userRepository.save(u);
        UserResponse resp = new UserResponse(saved.getId(), saved.getUsername(), saved.getEmail());
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    // LOGIN
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody UserRequest req) {

        if (req.getUsername() == null || req.getPassword() == null) {
            return ResponseEntity.badRequest()
                    .body(new ErrorMessage(400, "Missing username or password"));
        }

        Optional<User> userOpt = userRepository.findByUsername(req.getUsername());
        if (userOpt.isPresent()) {
            User user = userOpt.get();

            if (passwordEncoder.matches(req.getPassword(), user.getPassword())) {

                // ✅ Send user info to Flutter
                UserResponse resp = new UserResponse(
                        user.getId(),
                        user.getUsername(),
                        user.getEmail()
                );
                return ResponseEntity.ok(resp);
            }
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(new ErrorMessage(401, "Invalid username or password"));
    }

    @GetMapping
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody User update) {
        Optional<User> u = userRepository.findById(id);
        if (u.isEmpty()) return ResponseEntity.notFound().build();

        User user = u.get();
        if (update.getUsername() != null) user.setUsername(update.getUsername());
        if (update.getEmail() != null) user.setEmail(update.getEmail());
        if (update.getPassword() != null) user.setPassword(passwordEncoder.encode(update.getPassword()));
        userRepository.save(user);

        UserResponse resp = new UserResponse(user.getId(), user.getUsername(), user.getEmail());
        return ResponseEntity.ok(resp);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        if (!userRepository.existsById(id)) return ResponseEntity.notFound().build();
        userRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // Helper classes
    private static class ErrorMessage {
        private int status;
        private String message;
        public ErrorMessage(int status, String message) { this.status = status; this.message = message; }
        public int getStatus(){ return status; }
        public String getMessage(){ return message; }
    }
}
