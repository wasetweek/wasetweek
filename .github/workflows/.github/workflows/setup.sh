#!/bin/bash

echo "🚀 Налаштування динамічного GitHub профілю..."

# Запитуємо дані користувача
echo "Введіть ваш GitHub username:"
read github_username

echo "Введіть ваше ім'я для відображення:"
read display_name

echo "Введіть ваш LinkedIn профіль (без https://linkedin.com/in/):"
read linkedin_username

echo "Введіть ваш Telegram username (без @):"
read telegram_username

echo "Введіть вашу email адресу:"
read email_address

# Створюємо директорію для workflows
mkdir -p .github/workflows

# Замінюємо плейсхолдери в README
sed -i.bak "s/YOUR_USERNAME/$github_username/g" README.md
sed -i.bak "s/\[Ваше Ім'я\]/$display_name/g" README.md
sed -i.bak "s/YOUR_LINKEDIN/$linkedin_username/g" README.md
sed -i.bak "s/YOUR_TELEGRAM/$telegram_username/g" README.md
sed -i.bak "s/your.email@gmail.com/$email_address/g" README.md

# Видаляємо backup файл
rm README.md.bak

echo "✅ README.md налаштовано!"

# Створюємо workflow файл
cat > .github/workflows/update-readme.yml << 'EOF'
name: Update README

on:
  schedule:
    - cron: '0 0 * * *'
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  update-readme:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Update README
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      run: |
        current_date=$(date +'%d.%m.%Y')
        current_time=$(date +'%H:%M:%S UTC')
        
        quote=$(curl -s "https://api.quotable.io/random" | jq -r '.content // "Keep coding, keep growing! 🚀"')
        
        github_user="${{ github.repository_owner }}"
        
        repo_stats=$(curl -s "https://api.github.com/users/$github_user")
        public_repos=$(echo $repo_stats | jq -r '.public_repos // "N/A"')
        
        sed -i "s/{CURRENT_DATE}/$current_date/g" README.md
        sed -i "s/{CURRENT_TIME}/$current_time/g" README.md
        sed -i "s/{QUOTE_OF_DAY}/$quote/g" README.md
        sed -i "s/{PUBLIC_REPOS}/$public_repos/g" README.md
        
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add README.md
        git diff --staged --quiet || git commit -m "🤖 Auto update README - $(date +'%Y-%m-%d %H:%M:%S')"
        git push
EOF

echo "✅ GitHub Action налаштовано!"

echo "🎉 Налаштування завершено!"
echo ""
echo "📋 Наступні кроки:"
echo "1. Додайте всі файли до git: git add ."
echo "2. Зробіть коміт: git commit -m 'Add dynamic README profile'"
echo "3. Відправте на GitHub: git push"
echo "4. Перейдіть в Actions вашого репозиторію та запустіть workflow вручну"
echo ""
echo "💡 Ваш профіль буде автоматично оновлюватися щодня!"
