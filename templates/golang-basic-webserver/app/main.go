// filename: templates/golang-basic-webserver/app/main.go
// A simple Go web server that displays a hello message and the current time
// This is a basic template for building web applications with Go

package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	port := "3000"
	
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Format the current time to a string "Time: HH:MM:SS Date: DD/MM/YYYY"
		currentTime := time.Now()
		timeDateString := fmt.Sprintf("Time: %02d:%02d:%02d Date: %02d/%02d/%d",
			currentTime.Hour(), currentTime.Minute(), currentTime.Second(),
			currentTime.Day(), currentTime.Month(), currentTime.Year())
		
		fmt.Fprintf(w, "Hello world ! Template: golang-basic-webserver. %s", timeDateString)
	})

	fmt.Printf("Server running at http://localhost:%s\n", port)
	http.ListenAndServe(":"+port, nil)
} 