Aldimediamarkt# Creating channel
export CHANNEL_NAME=billchannel

peer channel create -o orderer.efi.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/efi.com/orderers/orderer.efi.com/msp/tlscacerts/tlsca.efi.com-cert.pem

# Joining channel with mother
peer channel join -b billchannel.block

# Joining channel with mediamarkt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mediamarkt.efi.com/users/Admin@mediamarkt.efi.com/msp CORE_PEER_ADDRESS=peer0.mediamarkt.efi.com:7051 CORE_PEER_LOCALMSPID="MediaMarktMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mediamarkt.efi.com/peers/peer0.mediamarkt.efi.com/tls/ca.crt peer channel join -b billchannel.block

#Joining channel with aldi
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/aldi.efi.com/users/Admin@aldi.efi.com/msp CORE_PEER_ADDRESS=peer0.aldi.efi.com:7051 CORE_PEER_LOCALMSPID="AldiMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/aldi.efi.com/peers/peer0.aldi.efi.com/tls/ca.crt peer channel join -b billchannel.block

# Update each peer anchor
peer channel update -o orderer.efi.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/MotherMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/efi.com/orderers/orderer.efi.com/msp/tlscacerts/tlsca.efi.com-cert.pem

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mediamarkt.efi.com/users/Admin@mediamarkt.efi.com/msp CORE_PEER_ADDRESS=peer0.mediamarkt.efi.com:7051 CORE_PEER_LOCALMSPID="MediaMarktMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mediamarkt.efi.com/peers/peer0.mediamarkt.efi.com/tls/ca.crt peer channel update -o orderer.efi.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/MediaMarktMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/efi.com/orderers/orderer.efi.com/msp/tlscacerts/tlsca.efi.com-cert.pem

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/aldi.efi.com/users/Admin@aldi.efi.com/msp CORE_PEER_ADDRESS=peer0.aldi.efi.com:7051 CORE_PEER_LOCALMSPID="AldiMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/aldi.efi.com/peers/peer0.aldi.efi.com/tls/ca.crt peer channel update -o orderer.efi.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/AldiMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/efi.com/orderers/orderer.efi.com/msp/tlscacerts/tlsca.efi.com-cert.pem

# Deploy chaincode
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mediamarkt.efi.com/users/Admin@mediamarkt.efi.com/msp CORE_PEER_ADDRESS=peer0.mediamarkt.efi.com:7051 CORE_PEER_LOCALMSPID="MediaMarktMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/mediamarkt.efi.com/peers/peer0.mediamarkt.efi.com/tls/ca.crt peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/aldi.efi.com/users/Admin@aldi.efi.com/msp CORE_PEER_ADDRESS=peer0.aldi.efi.com:7051 CORE_PEER_LOCALMSPID="AldiMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/aldi.efi.com/peers/peer0.aldi.efi.com/tls/ca.crt peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

# instantiate chaincode
peer chaincode instantiate -o orderer.efi.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/efi.com/orderers/orderer.efi.com/msp/tlscacerts/tlsca.efi.com-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('MotherMSP.member','MediaMarktMSP.member','AldiMSP.member')"

# query chaincode
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

# invoke chaincode
peer chaincode invoke -o orderer.efi.com:7050  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/efi.com/orderers/orderer.efi.com/msp/tlscacerts/tlsca.efi.com-cert.pem  -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
