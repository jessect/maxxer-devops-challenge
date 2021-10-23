package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"rest-go/controllers"
	"rest-go/database"
	"rest-go/entity"

	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/gorilla/mux"
	_ "github.com/jinzhu/gorm/dialects/mysql" //Required for MySQL dialect
)

func getSecret() Config {
	secretName := os.Getenv("SECRET_ARN")
	region := os.Getenv("AWS_REGION")

	//Create a Secrets Manager client
	svc := secretsmanager.New(session.New(),
		aws.NewConfig().WithRegion(region))
	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretName),
		VersionStage: aws.String("AWSCURRENT"),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		panic(err.Error())
	}

	var secretString string
	if result.SecretString != nil {
		secretString = *result.SecretString
	}

	var secretData Config
	err = json.Unmarshal([]byte(secretString), &secretData)
	if err != nil {
		panic(err.Error())
	}

	return secretData
}

type Config struct {
	User string `json:"username"`
	Pass string `json:"password"`
	Host string `json:"host"`
	Name string `json:"dbname"`
}

func main() {
	var c Config
	c = getSecret()

	initDB(c)
	log.Println("Starting the HTTP server on port 8090")

	router := mux.NewRouter().StrictSlash(true)
	router.Path("/metrics").Handler(promhttp.Handler())
	initaliseHandlers(router)
	log.Fatal(http.ListenAndServe(":8090", router))
}

func HomeServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "myapp version 1.0 %s", r.URL.Path[1:])
}

func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	// A very simple health check.
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	// In the future we could report back on the status of our DB, or our cache
	// (e.g. Redis) by performing a simple PING, and include them in the response.
	io.WriteString(w, `{"alive": true}`)
}

func initaliseHandlers(router *mux.Router) {
	router.HandleFunc("/", HomeServer).Methods("GET")
	router.HandleFunc("/health", HealthCheckHandler).Methods("GET")
	router.HandleFunc("/create", controllers.CreatePerson).Methods("POST")
	router.HandleFunc("/get", controllers.GetAllPerson).Methods("GET")
	router.HandleFunc("/get/{id}", controllers.GetPersonByID).Methods("GET")
	router.HandleFunc("/update/{id}", controllers.UpdatePersonByID).Methods("PUT")
	router.HandleFunc("/delete/{id}", controllers.DeletPersonByID).Methods("DELETE")
}

func initDB(c Config) {

	config :=
		database.Config{
			ServerName: c.Host,
			User:       c.User,
			Password:   c.Pass,
			DB:         c.Name,
		}

	connectionString := database.GetConnectionString(config)
	err := database.Connect(connectionString)
	if err != nil {
		panic(err.Error())
	}
	database.Migrate(&entity.Person{})
}
