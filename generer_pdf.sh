#!/bin/bash
# Script pour générer le rapport en PDF depuis Markdown

echo "📄 Génération du rapport PDF..."

# Vérifier si pandoc est installé
if ! command -v pandoc &> /dev/null; then
    echo "❌ Pandoc n'est pas installé."
    echo "Installation:"
    echo "  - Windows: choco install pandoc"
    echo "  - Linux: sudo apt install pandoc texlive-latex-base texlive-fonts-recommended"
    echo "  - Mac: brew install pandoc basictex"
    exit 1
fi

# Générer le PDF
pandoc RAPPORT_FINAL.md \
    -o Rapport_TP_OpenTelemetry_OumarMarame.pdf \
    --pdf-engine=xelatex \
    --toc \
    --toc-depth=3 \
    --number-sections \
    -V geometry:margin=2.5cm \
    -V fontsize=11pt \
    -V documentclass=article \
    -V lang=fr \
    --highlight-style=tango

if [ $? -eq 0 ]; then
    echo "✅ PDF généré: Rapport_TP_OpenTelemetry_OumarMarame.pdf"
else
    echo "❌ Erreur lors de la génération du PDF"
    echo ""
    echo "Alternative: Convertir manuellement avec:"
    echo "  1. Ouvrir RAPPORT_FINAL.md dans VS Code"
    echo "  2. Installer l'extension 'Markdown PDF'"
    echo "  3. Ctrl+Shift+P → 'Markdown PDF: Export (pdf)'"
fi
