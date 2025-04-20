// filename: templates/java-basic-webserver/app/src/main/java/com/example/App.java
// A simple Spring Boot web server that displays a hello message and the current time
// This is a basic template for building web applications with Java Spring Boot

package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@SpringBootApplication
@RestController
public class App {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @GetMapping("/")
    public String hello() {
        // Format the current time to a string "Time: HH:MM:SS Date: DD/MM/YYYY"
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("'Time:' HH:mm:ss 'Date:' dd/MM/yyyy");
        String timeDateString = LocalDateTime.now().format(formatter);
        
        return "Hello world ! Template: java-basic-webserver. " + timeDateString;
    }
} 