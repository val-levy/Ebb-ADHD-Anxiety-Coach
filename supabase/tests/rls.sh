#!/bin/sh
# RLS check: two anonymous users; B must not see A's reset. Usage: supabase/tests/rls.sh [api_url] [anon_key]
set -e
API=${1:-http://127.0.0.1:54421}; KEY=${2:?anon key}
tok() { curl -s "$API/auth/v1/signup" -H "apikey: $KEY" -H 'Content-Type: application/json' -d '{}' | sed -E 's/.*"access_token":"([^"]+)".*/\1/'; }
A=$(tok); B=$(tok)
curl -sf "$API/rest/v1/resets" -H "apikey: $KEY" -H "Authorization: Bearer $A" -H 'Content-Type: application/json' -d '{"kind":"sigh","helped":true}'
curl -sf "$API/rest/v1/calm_sessions" -H "apikey: $KEY" -H "Authorization: Bearer $A" -H 'Content-Type: application/json' -d '{"program":"panic","intensity_before":7}'
curl -sf "$API/rest/v1/nudge_events" -H "apikey: $KEY" -H "Authorization: Bearer $A" -H 'Content-Type: application/json' -d '{"origin":"planned","outcome":"shown"}'
[ "$(curl -s "$API/rest/v1/calm_sessions?select=id" -H "apikey: $KEY" -H "Authorization: Bearer $B")" = "[]" ] || { echo "FAIL: B sees A's calm session"; exit 1; }
[ "$(curl -s "$API/rest/v1/nudge_events?select=id" -H "apikey: $KEY" -H "Authorization: Bearer $B")" = "[]" ] || { echo "FAIL: B sees A's nudge event"; exit 1; }
SEEN_A=$(curl -s "$API/rest/v1/resets?select=id" -H "apikey: $KEY" -H "Authorization: Bearer $A")
SEEN_B=$(curl -s "$API/rest/v1/resets?select=id" -H "apikey: $KEY" -H "Authorization: Bearer $B")
[ "$SEEN_A" != "[]" ] || { echo "FAIL: A can't read own row"; exit 1; }
[ "$SEEN_B" = "[]" ]  || { echo "FAIL: B sees A's rows: $SEEN_B"; exit 1; }
echo "PASS: rows isolated per user"
