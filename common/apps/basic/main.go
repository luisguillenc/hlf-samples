package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/gateway"
	"github.com/luisguillenc/hlf2-samples/common/apps/basic/server"
)

func main() {
	//getenv and set defaults
	listenAddr := getenv("LISTEN_ADDR", ":8080")
	walletPath := getenv("WALLET", "wallet")
	mspid := getenv("MSPID", "Org1MSP")
	certPath := getenv("CERTFILE", "config/cert.pem")
	keyPath := getenv("KEYSTORE", "config/keystore")
	ccpPath := getenv("CONNECTION_PROFILE", "config/connection.yaml")
	channel := getenv("CHANNEL_NAME", "test-channel")
	chaincode := getenv("CHAINCODE", "basic")

	//get wallet
	wallet, err := gateway.NewFileSystemWallet(walletPath)
	if err != nil {
		log.Fatalf("Failed to create wallet: %v", err)
	}
	if !wallet.Exists("appUser") {
		err = populateWallet(wallet, mspid, certPath, keyPath)
		if err != nil {
			log.Fatalf("Failed to populate wallet contents: %v", err)
		}
	}

	//create gateway
	gw, err := gateway.Connect(
		gateway.WithConfig(config.FromFile(filepath.Clean(ccpPath))),
		gateway.WithIdentity(wallet, "appUser"),
	)
	if err != nil {
		log.Fatalf("Failed to connect to gateway: %v", err)
	}
	defer gw.Close()

	//get channel and contract api
	network, err := gw.GetNetwork(channel)
	if err != nil {
		log.Fatalf("Failed to get network: %v", err)
	}
	contract := network.GetContract(chaincode)
	if contract == nil {
		log.Fatalf("Failed getting chaincode: %s", chaincode)
	}

	//init server with contract
	s := server.New(contract)
	log.Fatal(http.ListenAndServe(listenAddr, s.Router()))
}

func getenv(name, defvalue string) (value string) {
	value = os.Getenv(name)
	if value == "" {
		value = defvalue
	}
	return
}

func populateWallet(wallet *gateway.Wallet, mspid, certPath, keyPath string) error {
	cert, err := ioutil.ReadFile(filepath.Clean(certPath))
	if err != nil {
		return err
	}
	key, err := ioutil.ReadFile(filepath.Clean(keyPath))
	if err != nil {
		return err
	}
	identity := gateway.NewX509Identity(mspid, string(cert), string(key))

	return wallet.Put("appUser", identity)
}
