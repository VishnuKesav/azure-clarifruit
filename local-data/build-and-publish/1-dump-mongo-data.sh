: "${MONGODB_USERNAME:?You must set the environment variable MONGODB_USERNAME to your MongoDB Atlas username. e.g. luke}" && \
: "${MONGODB_PASSWORD:?You must set the environment variable MONGODB_PASSWORD to your MongoDB Atlas password. e.g. password123}" && \
: "${INSPECTION_WEEKS:?You must set the environment variable INSPECTION_WEEKS to the number of weeks of inspection data history to dump. e.g. 1.}" && \

set -e

SECONDS=0
echo "$(date): Dumping MongoDB configs and inspection data (last $INSPECTION_WEEKS weeks of inspections)..."

rm -rf ./dbdata/mongo/dump
mkdir -p ./dbdata/mongo/dump

echo "$(date): Dumping clarifruitConfigs records..."
mongodump --db="clarifruitConfigs" --out="./dbdata/mongo/dump" --uri="mongodb+srv://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@xavier-dev-pl-0.xygsf.mongodb.net/clarifruitConfigs?retryWrites=true&w=majority&socketTimeoutMS=30000&connectTimeoutMS=30000"

echo "$(date): Dumping clarifruitStats records..."
mongodump --db="clarifruitStats" --out="./dbdata/mongo/dump" --uri="mongodb+srv://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@xavier-dev-pl-0.xygsf.mongodb.net/clarifruitStats?retryWrites=true&w=majority&socketTimeoutMS=30000&connectTimeoutMS=30000"

CREATION_DATE_FROM_QUERY=$(mongo "mongodb+srv://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@xavier-dev-pl-0.xygsf.mongodb.net/clarifruitInspections?retryWrites=true&w=majority&socketTimeoutMS=30000&connectTimeoutMS=30000" --eval "new Date(new Date().getTime() - ($INSPECTION_WEEKS * 7 * 24 * 60 * 60 * 1000)).toISOString()" |  grep -E -o "^$(date +%Y).*$")
for COLLECTION in inspection photo; do
  echo "$(date): Dumping clarifruitInspections.${COLLECTION} records..."
  mongodump --db="clarifruitInspections" --collection="${COLLECTION}" --query "{ \"createdDate\":{ \"\$gte\": { \"\$date\": \"$CREATION_DATE_FROM_QUERY\" } } }" --out="./dbdata/mongo/dump" --uri="mongodb+srv://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@xavier-dev-pl-0.xygsf.mongodb.net/clarifruitInspections?retryWrites=true&w=majority&socketTimeoutMS=30000&connectTimeoutMS=30000"
done

echo "$(date): Done!"
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
