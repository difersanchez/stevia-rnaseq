#!/bin/bash
set -euo pipefail

mkdir -p refs/custom_lists

cat > refs/custom_lists/bacteria_genera.txt <<'EOF'
Agrobacterium,Clavibacter,Dickeya,Erwinia,Pantoea,Pectobacterium,Pseudomonas,Ralstonia,Xanthomonas,Xylella
EOF

cat > refs/custom_lists/fungi_genera.txt <<'EOF'
Alternaria,Botrytis,Colletotrichum,Fusarium,Rhizoctonia,Sclerotinia,Sclerotium,Stagonosporopsis,Septoria
EOF

cat > refs/custom_lists/stevia_priority_watchlist.tsv <<'EOF'
taxon	group	priority_reason
Septoria steviae	fungus	widely described stevia pathogen
Alternaria alternata	fungus	reported stevia leaf spot
Fusarium oxysporum	fungus	reported stevia wilt
Rhizoctonia solani	fungus	reported disease in stevia
Sclerotium rolfsii	fungus	reported stem rot in stevia
Stagonosporopsis pogostemonis	fungus	recent stevia disease note
Candidatus Phytoplasma asteris	bacterium	Asteraceae-associated phytoplasma
Pseudomonas syringae	bacterium	broad plant pathogen
Xanthomonas campestris	bacterium	broad plant pathogen
Ralstonia solanacearum	bacterium	broad plant pathogen
EOF
