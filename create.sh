# generate certificates
cryptogen generate --config=./crypto-config.yaml

# create genesis block
export FABRIC_CFG_PATH=$PWD
mkdir channel-artifacts
configtxgen -profile EfiOrdererGenesis -outputBlock ./channel-artifacts/genesis.block

# create channel
export CHANNEL_NAME=billchannel
configtxgen -profile EfiChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

# create peers
configtxgen -profile EfiChannel -outputAnchorPeersUpdate ./channel-artifacts/MotherMSPanchors.tx -channelID $CHANNEL_NAME -asOrg MotherMSP
configtxgen -profile EfiChannel -outputAnchorPeersUpdate ./channel-artifacts/AldiMSPanchors.tx -channelID $CHANNEL_NAME -asOrg AldiMSP
configtxgen -profile EfiChannel -outputAnchorPeersUpdate ./channel-artifacts/MediaMarktMSPanchors.tx -channelID $CHANNEL_NAME -asOrg MediaMarktMSP


# Secret copying
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/mother.efi.com/peers/peer0.mother.efi.com/tls/ca.crt > /tmp/composer/mother/ca-mother.txt
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/mediamarkt.efi.com/peers/peer0.mediamarkt.efi.com/tls/ca.crt > /tmp/composer/mediamarkt/ca-mediamarkt.txt
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/aldi.efi.com/peers/peer0.aldi.efi.com/tls/ca.crt > /tmp/composer/aldi/ca-aldi.txt
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/efi.com/orderers/orderer.efi.com/tls/ca.crt > /tmp/composer/ca-orderer.txt

# Private key copying
export MOTHER=crypto-config/peerOrganizations/mother.efi.com/users/Admin@mother.efi.com/msp

cp -p $MOTHER/signcerts/A*.pem /tmp/composer/mother

cp -p $MOTHER/keystore/*_sk /tmp/composer/mother

export MEDIAMARKT=crypto-config/peerOrganizations/mediamarkt.efi.com/users/Admin@mediamarkt.efi.com/msp

cp -p $MEDIAMARKT/signcerts/A*.pem /tmp/composer/mediamarkt

cp -p $MEDIAMARKT/keystore/*_sk /tmp/composer/mediamarkt

export ALDI=crypto-config/peerOrganizations/aldi.efi.com/users/Admin@aldi.efi.com/msp

cp -p $ALDI/signcerts/A*.pem /tmp/composer/aldi

cp -p $ALDI/keystore/*_sk /tmp/composer/aldi

# Create cards

composer card create -p /tmp/composer/mother/efi-network-mother.json -u PeerAdmin -c /tmp/composer/mother/Admin@mother.efi.com-cert.pem -k /tmp/composer/mother/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@efi-network-mother.card

composer card create -p /tmp/composer/mediamarkt/efi-network-mediamarkt.json -u PeerAdmin -c /tmp/composer/mediamarkt/Admin@mediamarkt.efi.com-cert.pem -k /tmp/composer/mediamarkt/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@efi-network-mediamarkt.card

composer card create -p /tmp/composer/aldi/efi-network-aldi.json -u PeerAdmin -c /tmp/composer/aldi/Admin@aldi.efi.com-cert.pem -k /tmp/composer/aldi/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@efi-network-aldi.card

# Import cards

composer card import -f PeerAdmin@efi-network-mother.card --card PeerAdmin@efi-network-mother

composer card import -f PeerAdmin@efi-network-mediamarkt.card --card PeerAdmin@efi-network-mediamarkt

composer card import -f PeerAdmin@efi-network-aldi.card --card PeerAdmin@efi-network-aldi

# Network creation

composer archive create -t dir -n .

# Network install

composer network install --card PeerAdmin@efi-network-mother --archiveFile efi-network@0.0.1.bna
