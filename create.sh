# generate certificates
cryptogen generate --config=./crypto-config.yaml

# create genesis block
export FABRIC_CFG_PATH=$PWD
mkdir channel-artifacts
configtxgen -profile EfiChannel -outputBlock ./channel-artifacts/genesis.block

# create channel
export CHANNEL_NAME=billChannel
configtxgen -profile EfiChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

# create peers
configtxgen -profile EfiChannel -outputAnchorPeersUpdate ./channel-artifacts/MotherMSPanchors.tx -channelID $CHANNEL_NAME -asOrg MotherMSP
configtxgen -profile EfiChannel -outputAnchorPeersUpdate ./channel-artifacts/AldiMSPanchors.tx -channelID $CHANNEL_NAME -asOrg AldiMSP
configtxgen -profile EfiChannel -outputAnchorPeersUpdate ./channel-artifacts/MediaMarktMSPanchors.tx -channelID $CHANNEL_NAME -asOrg MediaMarktMSP
