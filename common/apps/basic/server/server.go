package server

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/hyperledger/fabric-sdk-go/pkg/gateway"
)

type api struct {
	router   http.Handler
	contract *gateway.Contract
}

type Server interface {
	Router() http.Handler
}

func New(contract *gateway.Contract) Server {
	a := &api{contract: contract}
	r := mux.NewRouter()
	r.HandleFunc("/assets", a.getAllAssests).Methods(http.MethodGet)
	r.HandleFunc("/assets", a.addAsset).Methods(http.MethodPost)
	a.router = r
	return a
}

func (a *api) Router() http.Handler {
	return a.router
}

func (a *api) getAllAssests(w http.ResponseWriter, r *http.Request) {
	result, err := a.contract.EvaluateTransaction("GetAllAssets")
	if err != nil {
		log.Printf("Failed to evaluate transaction: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(err.Error())
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(result)
}

type addAssetRequest struct {
	ID             string `json:"ID"`
	Color          string `json:"color"`
	Size           int    `json:"size"`
	Owner          string `json:"owner"`
	AppraisedValue int    `json:"appraisedValue"`
}

func (a *api) addAsset(w http.ResponseWriter, r *http.Request) {
	decoder := json.NewDecoder(r.Body)

	var g addAssetRequest
	err := decoder.Decode(&g)
	w.Header().Set("Content-Type", "application/json")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(w).Encode("Error unmarshalling request body")
		return
	}
	_, err = a.contract.SubmitTransaction("CreateAsset",
		g.ID, g.Color, strconv.Itoa(g.Size), g.Owner, strconv.Itoa(g.AppraisedValue))
	if err != nil {
		log.Printf("Failed to Submit transaction: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(err.Error())
		return
	}
	w.WriteHeader(http.StatusCreated)
}
