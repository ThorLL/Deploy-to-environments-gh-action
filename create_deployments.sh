# Usage: deploy_to_environments.sh <owner/repo> <git ref> <environments regex> <?[excluded regex]>
# Summary: Deploys the git reference to all environments matching the regular expressions
# Help:
# * <owner/repo> the repository to be working within
# * <git ref> git reference to be deployed to environments
# * <environments regex> regular expression which environments must match
# * <?[excluded regex]> regular expressions (seperated by `;`), environments matching any of these will be excluded
#


if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <owner/repo> <git ref> <environments regex> <?[excluded regex]>"
    echo "Example: $0 'ThorLL/Deploy-to-environments-action' 'tags/v1.0.0' '.*Testing.*MyActionSystem' '.*Testing-Prod.*;.*Testing-05.*'"
    exit 1
fi


repo=$1
gitRef=$2
environments_regex=$3
IFS=';' read -ra exclude_environments <<< "$4"


if [ "$gitRef" == "latest_release" ]; then
	gitRef="tags/$(gh api /repos/"$repo"/releases/latest --jq '.tag_name')"
fi

# Fetch all environments
environments=$(
  gh api \
    --paginate \
    --slurp \
    -H "Accept: application/vnd.github.v3+json" \
    /repos/"$repo"/environments \
  | jq -r '.[].environments[] | select(.name | test("'"$environments_regex"'")) | .name'
)

# Check if environments list is empty
if [ -z "$environments" ]; then
  echo "Error: No environments found."
  exit 1
fi

# Filter out excluded environments if any
if [ ${#exclude_environments[@]} -gt 0 ]; then
  environments=$(echo "$environments" | grep -vE "$(IFS='|'; echo "${exclude_environments[*]}")")

  # Check if environments list is empty post filtering
  if [ -z "$environments" ]; then
    echo "Error: No environments left after filtering."
    exit 1
  fi
fi

# Deploy to environments
for environment in $environments; do
  output=$(gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    /repos/"$repo"/deployments \
    -f ref=refs/"$gitRef" \
    -f environment="$environment" \
    -f description="Deploying reference: $gitRef" \
    -F auto_merge=false \
    -F required_contexts[] 2>&1)

  if [ $? -ne 0 ]; then
    echo "Failure: Failed to deploy to $environment"
    echo "Command output: $output"
  else
    echo "Success: Deployed to $environment"
  fi
done