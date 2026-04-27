#!/bin/bash

# --- CONFIGURATION ---
# Define your GU Domains details here to keep the code clean
GU_USER="danakimg"
GU_URL="danakim.georgetown.domains"
GU_PATH="/home/danakimg/public_html/5200-project"
SSH_KEY="~/.ssh/id_rsa"

echo "🚀 Starting build process..."

# 1. PULL LATEST UPDATES
# Ensures you have Emily and Kylie's latest work before you render
git pull 

# 2. START FRESH
# Cleaning out old build files prevents "ghost" versions of deleted files
rm -rf _site
rm -rf .quarto
rm -rf report/closeread_files # Cleaning local render folders

# RE-BUILD WEBSITE
echo "📦 Rendering Quarto project..."
# We just run 'quarto render' now—the _quarto.yml handles the rest!
quarto render

# 4. CLEAN UP 
# Using -delete is faster than a loop for removing .DS_Store junk
find _site -name ".DS_Store" -delete

# 5. SET PERMISSIONS
# This ensures the GU Domains server can actually read and display your files
echo "🔐 Setting file permissions..."
find _site -type f -exec chmod 644 {} +
find _site -type d -exec chmod 755 {} +

# 6. GITHUB SYNC
printf 'Would you like to push to GITHUB? (y/n)? '
read -r answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -p 'ENTER COMMIT MESSAGE: ' message
    git add .
    git commit -m "$message"
    git push origin main
    echo "✅ Pushed to GitHub!"
else
    echo "⏩ Skipping GitHub push."
fi

# 7. PUSH TO GU DOMAINS
printf 'Would you like to push to GU domains? (y/n)? '
read -r answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🌐 Syncing with GU Domains..."
    # --delete ensures that files you deleted locally are also deleted on the server
    rsync -alvr --delete -e "ssh -i $SSH_KEY" _site/ "$GU_USER@$GU_URL:$GU_PATH"
    echo "✅ Website is live at: https://$GU_URL/5200-project"
else
    echo "⏩ Skipping GU Domains push."
fi

echo "🎉 All done!"