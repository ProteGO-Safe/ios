# run sh locales/scripts/upload.sh -i PROJECT_ID -t PROJECT_TOKEN
while getopts i:t:l: flag
do
    case "${flag}" in
        i) id=${OPTARG};;
        t) token=${OPTARG};;
    esac
done

curl -X POST https://api.poeditor.com/v2/projects/upload \
     -F api_token="$token" \
     -F id="$id" \
     -F language="pl" \
     -F updating="terms_translations" \
     -F file=@"`dirname "$0"`/safesafe/Resources/translations/pl.strings" \
     -F fuzzy_trigger="1" \
