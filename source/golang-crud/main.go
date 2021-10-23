package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"rest-go/controllers"
	"rest-go/database"
	"rest-go/entity"

	"github.com/gorilla/mux"
	_ "github.com/jinzhu/gorm/dialects/mysql" //Required for MySQL dialect
)

func main() {
	initDB()
	log.Println("Starting the HTTP server on port 8090")

	router := mux.NewRouter().StrictSlash(true)
	initaliseHandlers(router)
	log.Fatal(http.ListenAndServe(":8090", router))
}

func HomeServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "myapp version 1.0 %s", r.URL.Path[1:])
}

func initaliseHandlers(router *mux.Router) {
	router.HandleFunc("/", HomeServer).Methods("GET")
	router.HandleFunc("/create", controllers.CreatePerson).Methods("POST")
	router.HandleFunc("/get", controllers.GetAllPerson).Methods("GET")
	router.HandleFunc("/get/{id}", controllers.GetPersonByID).Methods("GET")
	router.HandleFunc("/update/{id}", controllers.UpdatePersonByID).Methods("PUT")
	router.HandleFunc("/delete/{id}", controllers.DeletPersonByID).Methods("DELETE")
}

func initDB() {

	config :=
		database.Config{
			ServerName: os.Getenv("DB_HOST"),
			User:       os.Getenv("DB_USER"),
			Password:   os.Getenv("DB_PASS"),
			DB:         os.Getenv("DB_NAME"),
		}

	connectionString := database.GetConnectionString(config)
	err := database.Connect(connectionString)
	if err != nil {
		panic(err.Error())
	}
	database.Migrate(&entity.Person{})
}
