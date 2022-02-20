package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing an hash (file)
type SmartContract struct {
	contractapi.Contract
}

type Metadata struct {
	ID          string `json:"ID"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Hash        string `json:"hash"`
}

// InitLedger adds a base set of Metadatas to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	metadatos := []Metadata{
		Metadata{ID: "asset1", Name: "file1.txt", Description: "Hello World!", Hash: "QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG"},
		Metadata{ID: "asset2", Name: "file3.txt", Description: "probando", Hash: "Qmawzj8J2PFZFHWjtnDmjUQ7c9Ahv1Y9u3zva6YzTJDWcP"},
	}

	for i, metadato := range metadatos {
		metadatoAsBytes, _ := json.Marshal(metadato)
		err := ctx.GetStub().PutState("Metadata"+strconv.Itoa(i), metadatoAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// CreateAsset issues a new asset to the world state with given details.
func (s *SmartContract) CreateMetadata(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
	exists, err := s.MetadataExists(ctx, id)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the asset %s already exists", id)
	}

	metadato := Metadata{
		ID:          id,
		Name:        name,
		Description: descripcion,
		Hash:        hash,
	}
	assetJSON, err := json.Marshal(metadato)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, assetJSON)
}

// AssetExists returns true when asset with given ID exists in world state
func (s *SmartContract) MetadataExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	metadatosJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	return metadatosJSON != nil, nil
}

// ReadAsset returns the asset stored in the world state with given id.
func (s *SmartContract) ReadMetadata(ctx contractapi.TransactionContextInterface, id string) (*Metadata, error) {
	metadatosJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if metadatosJSON == nil {
		return nil, fmt.Errorf("the asset %s does not exist", id)
	}

	var metadatos Metadata
	err = json.Unmarshal(metadatosJSON, &metadatos)
	if err != nil {
		return nil, err
	}

	return &metadatos, nil
}

// UpdateAsset updates an existing asset in the world state with provided parameters.
func (s *SmartContract) UpdateMetadata(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
	exists, err := s.MetadataExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}

	// overwriting original asset with new asset
	metadato := Metadata{
		ID:          id,
		Name:        name,
		Description: descripcion,
		Hash:        hash,
	}
	metadataJSON, err := json.Marshal(metadato)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, metadataJSON)
}

// DeleteAsset deletes an given asset from the world state.
func (s *SmartContract) DeleteMetadata(ctx contractapi.TransactionContextInterface, id string) error {
	exists, err := s.MetadataExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}

	return ctx.GetStub().DelState(id)
}

// GetAllAssets returns all assets found in world state
func (s *SmartContract) GetAllMetadatos(ctx contractapi.TransactionContextInterface) ([]*Metadata, error) {
	// range query with empty string for startKey and endKey does an
	// open-ended query of all assets in the chaincode namespace.
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var metadatos []*Metadata
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var metadato Metadata
		err = json.Unmarshal(queryResponse.Value, &metadato)
		if err != nil {
			return nil, err
		}
		metadatos = append(metadatos, &metadato)
	}

	return metadatos, nil
}
