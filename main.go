package main

import (
	"io"
	"log"
	"net/http"
)

// go run -ldflags "-X main.build=$(git rev-parse --short HEAD)' main.go

var (
	build string
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		io.WriteString(w, "Hello world with GitHub Action !!! "+build)
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}
