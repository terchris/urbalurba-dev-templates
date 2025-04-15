#!/bin/bash
# file: .devcontainer/dev/dev-template.sh
# Description: This script downloads the selected template and sets up the project
# Usage: ./dev-template.sh [template-name]
#        If template-name is provided, that template will be used
#        If no template-name is provided, available templates will be listed for selection
#------------------------------------------------------------------------------
set -e

echo ""
echo "🛠️  Urbalurba Developer Platform - Project Initializer"
echo "This script will set up your project with the necessary files and configurations."
echo "---------------------------------------------------------------------------------"

# Detect GitHub username and repo
GITHUB_REMOTE=$(git remote get-url origin)
GITHUB_USERNAME=$(echo "$GITHUB_REMOTE" | sed -n 's/.*github.com[:/]\(.*\)\/.*/\1/p')
REPO_NAME=$(basename -s .git "$GITHUB_REMOTE")

if [[ -z "$GITHUB_USERNAME" || -z "$REPO_NAME" ]]; then
  echo "❌ Could not determine GitHub username or repo name"
  exit 1
fi

echo "✅ GitHub user: $GITHUB_USERNAME"
echo "✅ Repo name: $REPO_NAME"

# Template variables
TEMPLATE_OWNER="terchris"
TEMPLATE_REPO_NAME="urbalurba-dev-templates"
TEMPLATE_REPO_URL="https://github.com/$TEMPLATE_OWNER/$TEMPLATE_REPO_NAME"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Cloning template repository to temp folder: $TEMP_DIR"
cd "$TEMP_DIR"

# Clone the template repository
echo "Cloning from $TEMPLATE_REPO_URL..."
git clone $TEMPLATE_REPO_URL

# Check if the templates directory exists
if [ ! -d "$TEMPLATE_REPO_NAME/templates" ]; then
  echo "❌ Templates directory not found in repository."
  echo "Removing template repository folder: $TEMP_DIR"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Get a list of available templates
TEMPLATES=()
for dir in "$TEMPLATE_REPO_NAME/templates"/*; do
  if [ -d "$dir" ]; then
    TEMPLATE_NAME=$(basename "$dir")
    TEMPLATES+=("$TEMPLATE_NAME")
  fi
done

if [ ${#TEMPLATES[@]} -eq 0 ]; then
  echo "❌ No templates found in repository."
  echo "Removing template repository folder: $TEMP_DIR"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# If a template name is provided as a parameter, use it
# Otherwise, list available templates and let the user select one
if [ -n "$1" ]; then
  TEMPLATE_NAME="$1"
  # Check if the specified template exists
  if [ ! -d "$TEMPLATE_REPO_NAME/templates/$TEMPLATE_NAME" ]; then
    echo "❌ Template '$TEMPLATE_NAME' not found in repository."
    echo "Available templates:"
    for i in "${!TEMPLATES[@]}"; do
      echo "  $(($i + 1)). ${TEMPLATES[$i]}"
    done
    echo "Removing template repository folder: $TEMP_DIR"
    rm -rf "$TEMP_DIR"
    exit 1
  fi
else
  # No template specified, show list
  echo "Available templates:"
  for i in "${!TEMPLATES[@]}"; do
    echo "  $(($i + 1)). ${TEMPLATES[$i]}"
  done
  
  # Ask user to select a template
  while true; do
    echo ""
    read -p "Select template (1-${#TEMPLATES[@]}): " TEMPLATE_SELECTION
    
    # Check if the input is a number
    if [[ "$TEMPLATE_SELECTION" =~ ^[0-9]+$ ]]; then
      # Check if the number is in range
      if [ "$TEMPLATE_SELECTION" -ge 1 ] && [ "$TEMPLATE_SELECTION" -le ${#TEMPLATES[@]} ]; then
        # Convert selection to array index (0-based)
        TEMPLATE_INDEX=$(($TEMPLATE_SELECTION - 1))
        TEMPLATE_NAME="${TEMPLATES[$TEMPLATE_INDEX]}"
        break
      fi
    fi
    
    echo "❌ Invalid selection. Please enter a number between 1 and ${#TEMPLATES[@]}."
  done
fi

echo "Selected template: $TEMPLATE_NAME"

# Check required template directories and files
echo "Verifying template structure..."

# Check for required directories in the template
TEMPLATE_PATH="$TEMPLATE_REPO_NAME/templates/$TEMPLATE_NAME"

# Check for the manifests directory
if [ ! -d "$TEMPLATE_PATH/manifests" ]; then
  echo "❌ Required directory 'manifests' not found in template."
  echo "Removing template repository folder: $TEMP_DIR"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Check for deployment.yaml
if [ ! -f "$TEMPLATE_PATH/manifests/deployment.yaml" ]; then
  echo "❌ Required file 'manifests/deployment.yaml' not found in template."
  echo "Removing template repository folder: $TEMP_DIR"
  rm -rf "$TEMP_DIR"
  exit 1
fi

echo "✅ Required template structure verified"

echo "Extracting template $TEMPLATE_NAME"
# Copy all visible files and directories
cp -r "$TEMPLATE_PATH/"* "$OLDPWD/"

# Handle special directories that might be hidden
# Create .github directory if needed
if [ -d "$TEMPLATE_PATH/.github" ]; then
  echo "Setting up .github directory and workflows..."
  
  # Create .github/workflows directory if it doesn't exist
  mkdir -p "$OLDPWD/.github/workflows"
  
  # Copy all files from .github directory preserving structure
  cp -r "$TEMPLATE_PATH/.github"/* "$OLDPWD/.github/"
  echo "✅ Added GitHub files and workflows"
else
  # Check if there's a common workflows directory in the template repo
  if [ -d "$TEMPLATE_REPO_NAME/.github/workflows" ]; then
    echo "Setting up common GitHub workflows..."
    mkdir -p "$OLDPWD/.github/workflows"
    cp -r "$TEMPLATE_REPO_NAME/.github/workflows"/* "$OLDPWD/.github/workflows/"
    echo "✅ Added common GitHub workflows"
  fi
fi

# Handle .gitignore merging
if [ -f "$TEMPLATE_PATH/.gitignore" ]; then
  echo "Merging .gitignore files..."
  
  # Check if destination .gitignore exists
  if [ -f "$OLDPWD/.gitignore" ]; then
    echo "Existing .gitignore found, merging with template .gitignore"
    
    # Create temporary files
    TEMP_MERGED=$(mktemp)
    
    # Copy existing .gitignore entries to temp file
    cat "$OLDPWD/.gitignore" > "$TEMP_MERGED"
    
    # Add a newline to ensure separation
    echo "" >> "$TEMP_MERGED"
    
    # Add template .gitignore entries that don't already exist
    echo "# Added from template $TEMPLATE_NAME" >> "$TEMP_MERGED"
    
    while IFS= read -r line; do
      # Skip empty lines and comments
      if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
        # Check if this entry already exists in the destination .gitignore
        if ! grep -Fxq "$line" "$OLDPWD/.gitignore"; then
          echo "$line" >> "$TEMP_MERGED"
        fi
      fi
    done < "$TEMPLATE_PATH/.gitignore"
    
    # Replace the existing .gitignore with the merged file
    # Use cat instead of mv to avoid permission issues
    if cat "$TEMP_MERGED" > "$OLDPWD/.gitignore"; then
        echo "✅ Successfully merged .gitignore files"
        # Clean up temp file
        rm -f "$TEMP_MERGED"
    else
        echo "❌ Failed to update .gitignore file: Permission denied"
        rm -f "$TEMP_MERGED"
        exit 1
    fi
  else
    echo "No existing .gitignore, copying template .gitignore"
    cp "$TEMPLATE_PATH/.gitignore" "$OLDPWD/"
  fi
fi

# Navigate back to the project directory
cd "$OLDPWD"

# Process template files - replace placeholders
echo "Processing template files..."

# Function to replace placeholders in a file
replace_placeholders() {
  local file=$1
  local temp_file=$(mktemp)
  
  if [ -f "$file" ]; then
    cat "$file" | \
      sed -e "s|{{GITHUB_USERNAME}}|$GITHUB_USERNAME|g" \
          -e "s|{{REPO_NAME}}|$REPO_NAME|g" > "$temp_file"
    
    if cat "$temp_file" > "$file"; then
      echo "✅ Updated $(basename "$file")"
    else
      echo "❌ Failed to update $(basename "$file")"
      return 1
    fi
    rm "$temp_file"
  else
    echo "⚠️ File not found: $file"
    return 1
  fi
  
  return 0
}

# Update deployment.yaml
replace_placeholders "manifests/deployment.yaml"

# Look for ingress.yaml and update if it exists
if [ -f "manifests/ingress.yaml" ]; then
  replace_placeholders "manifests/ingress.yaml"
fi

# Update GitHub Actions workflow if it exists
if [ -f ".github/workflows/urbalurba-build-and-push.yaml" ]; then
  replace_placeholders ".github/workflows/urbalurba-build-and-push.yaml"
fi

# Check for any additional files that might need placeholder replacement
# This could include Dockerfiles, README files, etc.
if [ -f "Dockerfile" ]; then
  replace_placeholders "Dockerfile"
fi

# Cleanup
echo "Removing template repository folder: $TEMP_DIR"
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Template setup complete! Next steps:"
echo "1. Review the files that were created"
echo "2. Run any setup commands specified in the template's README"
echo "3. Commit and push your project to GitHub"
echo ""