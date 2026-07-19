#!/bin/bash
set -euo pipefail

EXPECTED_BRANCH="fd-custom"
CURRENT_BRANCH="$(git branch --show-current)"

if [ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]; then
  echo "ERREUR : branche actuelle = $CURRENT_BRANCH"
  echo "Ce script doit être exécuté uniquement sur fd-custom."
  exit 1
fi

echo "FD-CUSTOM UPDATE"
echo "Branche : $CURRENT_BRANCH"
echo ""

python3 <<'PY'
from pathlib import Path

checks = [
    {
        "label": "JavaScript source",
        "path": Path("trio-oref/lib/determine-basal/determine-basal.js"),
        "originals": [
            "// allow SMBIntervals between 1 and 10 minutes",
            "SMBInterval = Math.min(10,Math.max(1,profile.SMBInterval));",
        ],
        "customized": [
            "// allow SMBIntervals between 1 and 30 minutes",
            "SMBInterval = Math.min(30,Math.max(1,profile.SMBInterval));",
        ],
    },
    {
        "label": "JavaScript bundle",
        "path": Path("Trio/Resources/javascript/bundle/determine-basal.js"),
        "originals": [
            "Math.min(10,Math.max(1,i.SMBInterval))",
        ],
        "customized": [
            "Math.min(30,Math.max(1,i.SMBInterval))",
        ],
    },
    {
        "label": "Swift engine",
        "path": Path("Trio/Sources/APS/OpenAPSSwift/DetermineBasal/DosingEngine.swift"),
        "originals": [
            "smbInterval = min(10, max(1, profile.smbInterval))",
        ],
        "customized": [
            "smbInterval = min(30, max(1, profile.smbInterval))",
        ],
    },
    {
        "label": "Settings UI",
        "path": Path("Trio/Sources/Models/DecimalPickerSettings.swift"),
        "originals": [
            "var smbInterval = PickerSetting(value: 3, step: 1, min: 1, max: 10, type: PickerSetting.PickerSettingType.minute)",
        ],
        "customized": [
            "var smbInterval = PickerSetting(value: 3, step: 1, min: 1, max: 30, type: PickerSetting.PickerSettingType.minute)",
        ],
    },
]

for item in checks:
    path = item["path"]

    if not path.exists():
        raise SystemExit(f"ERREUR : fichier introuvable : {path}")

    content = path.read_text()

    for original, customized in zip(item["originals"], item["customized"]):
        if customized in content:
            continue

        count = content.count(original)

        if count != 1:
            raise SystemExit(
                f"ERREUR : {item['label']} — motif attendu trouvé {count} fois dans {path}. "
                "Le code officiel a probablement changé."
            )

        content = content.replace(original, customized, 1)

    path.write_text(content)
    print(f"✓ {item['label']}")

print("")
print("READY TO BUILD")
PY
