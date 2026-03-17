#!/usr/bin/env python3
import json, sys, hashlib
from pathlib import Path
if len(sys.argv)<3:
  y=Path('contract/rexce-contract.yml'); j=Path('contract/rexce-contract.json')
else:
  y=Path(sys.argv[1]); j=Path(sys.argv[2])
if not y.exists() or not j.exists():
  print('missing'); sys.exit(1)
if json.loads(y.read_text())!=json.loads(j.read_text()):
  print('mismatch'); sys.exit(1)
print('pass')
sys.exit(0)
