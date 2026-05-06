#!/usr/bin/env bash
set -euo pipefail

cat > .env <<EOF
API_BASE_URL=${API_BASE_URL:-https://rms.oceztra.com/api/}
AUTH_ENABLED=${AUTH_ENABLED:-true}
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-expensestracker-487f6}
FIREBASE_DATABASE_URL=${FIREBASE_DATABASE_URL:-https://expensestracker-487f6-default-rtdb.asia-southeast1.firebasedatabase.app/}
FIREBASE_API_KEY=${FIREBASE_API_KEY:-AIzaSyCn4WpWhzJ74RWa9Hfrs1728_7osPJBRFI}
FIREBASE_APP_ID=${FIREBASE_APP_ID:-1:621954520255:web:b58277499393856d46620a}
FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID:-621954520255}
FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN:-expensestracker-487f6.firebaseapp.com}
FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET:-expensestracker-487f6.firebasestorage.app}
EOF

if [ ! -d flutter ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

./flutter/bin/flutter config --enable-web
./flutter/bin/flutter pub get
./flutter/bin/flutter build web --release
