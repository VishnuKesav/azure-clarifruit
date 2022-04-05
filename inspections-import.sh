: "${MONGODB_IMPORT_URI:?You must set the environment variable MONGODB_IMPORT_URI to the URI of the MongoDB to import e.g. mongodb://localhost.}"

set -euo pipefail

cat inspections-export/photos-*.json > photos-export.json
time mongoimport --uri="${MONGODB_IMPORT_URI}" --db clarifruitInspections --collection photo --type=json --file=photos-export.json --drop --numInsertionWorkers=10

cat inspections-export/inspections-*.json > inspections-export.json
time mongoimport --uri="${MONGODB_IMPORT_URI}" --db clarifruitInspections --collection inspection --type=json --file=inspections-export.json --drop --numInsertionWorkers=10
