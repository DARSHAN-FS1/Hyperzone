package com.example.demo;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin(origins = "*")  //  allow Flutter web (any port)
@RestController
public class HelloController {

    @GetMapping("/hello")
    public String sayHello() {
        return "Hello from GameSphere Backend!";
    }
}
