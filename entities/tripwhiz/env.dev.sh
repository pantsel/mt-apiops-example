# Get folder name
FOLDER_NAME=$(basename $PWD)

export DECK_CONFIG_OIDC_ISSUER="https://$FOLDER_NAME-dev.auth.example.com/auth/realms/master/.well-known/openid-configuration"