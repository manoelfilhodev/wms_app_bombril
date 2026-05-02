#!/bin/bash
# Script para automatizar commits no Git

if [ -z "$1" ]; then
  echo "⚠️  Você precisa passar uma mensagem de commit."
  echo "👉 Exemplo: ./git-update.sh 'Adiciona tela de login'"
  exit 1
fi

echo "📦 Adicionando arquivos..."
git add .

echo "📝 Criando commit..."
git commit -m "$1"

echo "⬆️  Enviando para o repositório remoto..."
git push origin main

echo "✅ Commit enviado com sucesso!"
