./lambda/oauth_validation/build.sh
echo "Provisioning with following config"
jq < ./default.auto.tfvars.json
terraform apply