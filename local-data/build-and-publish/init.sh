set -e

SECONDS=0
echo "$(date): Extracting dumped MongoDB configs and inspection data..."

for DATABASE in clarifruitConfigs clarifruitInspections clarifruitStats; do
  echo "$(date): Extracting dumped MongoDB database ${DATABASE}..."
  mongorestore -d "${DATABASE}" "mongodb://localhost" "/dump/${DATABASE}"
done

echo "$(date): Done!"
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
