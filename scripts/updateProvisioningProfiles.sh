#!/bin/bash

if (( $# != 1 ))
then
  echo "Usage: ./updateProfisioningProfiles.sh <option>"
  echo ""
  echo "Available options:"
  echo "	read - just downloads newest provisioning profiles from git repo"
  echo "	new_devices - regenerates provisioning profiles, looking for new devices in the apple developer portal"
  echo "	nuke - removes all provisioning profiles and certificates from the git repo, and developer portal"
  exit 1
fi

numArgs=$#
lastArg="${!numArgs}"

dev_team_id="MT2B94Q7N6"
stg_team_id="MT2B94Q7N6"
prod_team_id="MT2B94Q7N6"
dev_app_id="pl.gov.anna.dev"
stg_app_id="pl.gov.anna.stg"
prod_app_id="pl.gov.anna.prod"
certs_repo_url="ssh://git@gitlab.polidea.com/ProteGO/fastlane-certificates.git"

case $lastArg in
    "read" )
		bundle exec fastlane match development -a $dev_app_id --team_id $dev_team_id --readonly true --git_url $certs_repo_url
		bundle exec fastlane match adhoc -a $dev_app_id --team_id $dev_team_id --readonly true --git_url $certs_repo_url
		bundle exec fastlane match development -a $stg_app_id --team_id $stg_team_id --readonly true --git_url $certs_repo_url
		bundle exec fastlane match appstore -a $stg_app_id --team_id $stg_team_id --readonly true --git_url $certs_repo_url
		bundle exec fastlane match development -a $prod_app_id --team_id $prod_team_id --readonly true --git_url $certs_repo_url
		bundle exec fastlane match appstore -a $prod_app_id --team_id $prod_team_id --readonly true --git_url $certs_repo_url
		;;
    "new_devices" )
		bundle exec fastlane match development -a $dev_app_id --team_id $dev_team_id --force_for_new_devices --git_url $certs_repo_url
	  	bundle exec fastlane match adhoc -a $dev_app_id --team_id $dev_team_id --force_for_new_devices --git_url $certs_repo_url
		bundle exec fastlane match development -a $stg_app_id --team_id $stg_team_id --force_for_new_devices --git_url $certs_repo_url
		bundle exec fastlane match appstore -a $stg_app_id --team_id $stg_team_id --force_for_new_devices --git_url $certs_repo_url
		bundle exec fastlane match development -a $prod_app_id --team_id $prod_team_id --force_for_new_devices --git_url $certs_repo_url
		bundle exec fastlane match appstore -a $prod_app_id --team_id $prod_team_id --force_for_new_devices --git_url $certs_repo_url
		;;
    "nuke" )
		bundle exec fastlane match nuke development -a $dev_app_id --team_id $dev_team_id --git_url $certs_repo_url
		bundle exec fastlane match nuke development -a $stg_app_id --team_id $stg_team_id --git_url $certs_repo_url
		bundle exec fastlane match nuke development -a $prod_app_id --team_id $prod_team_id --git_url $certs_repo_url
		bundle exec fastlane match nuke distribution -a $dev_app_id --team_id $dev_team_id --git_url $certs_repo_url
		bundle exec fastlane match nuke distribution -a $stg_app_id --team_id $stg_team_id --git_url $certs_repo_url
		bundle exec fastlane match nuke distribution -a $prod_app_id --team_id $prod_team_id --git_url $certs_repo_url
		;;
esac