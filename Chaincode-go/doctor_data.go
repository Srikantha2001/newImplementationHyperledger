package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// Chaincode structure
type DoctorChaincode struct {
	contractapi.Contract
}

// Doctor data structure
type DoctorData struct {
	DoctorID string `json:"doctorID"`
}

// Function to add doctor data
func (d *DoctorChaincode) AddDoctor(ctx contractapi.TransactionContextInterface, doctor string) error {

	// Create a new doctor data object
	doctorData := DoctorData{
		DoctorID: doctor,
	}

	doctorDataJSON, err := json.Marshal(doctorData)
	if err != nil {
		return fmt.Errorf("failed to marshal doctor data: %v", err)
	}

	err = ctx.GetStub().PutState(doctor, doctorDataJSON)
	if err != nil {
		return fmt.Errorf("failed to store doctor data: %v", err)
	}

	return nil
}

// Main function
func main() {

	// Create a new chaincode object
	chaincode, err := contractapi.NewChaincode(&DoctorChaincode{})
	if err != nil {
		fmt.Printf("Error creating Doctor data chaincode: %s", err.Error())
		return
	}

	// Start the chaincode
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting doctor data chaincode: %s", err.Error())
	}
}
