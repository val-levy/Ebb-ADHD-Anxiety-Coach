# Ebb

```
apps/ios/     SwiftUI app (project generated from project.yml by XcodeGen)
supabase/     migrations, config, tests
```

## Run locally
```sh
supabase start                       # local DB on :54421 (ports shifted to avoid other local projects)
cd apps/ios
cp Config.example.xcconfig Config.xcconfig   # paste ANON_KEY from `supabase status`
xcodegen generate && open Ebb.xcodeproj
```

## Check
`supabase/tests/rls.sh http://127.0.0.1:54421 <anon_key>`: verifies users can't read each other's rows.

## Deploy DB
`supabase link --project-ref <ref> && supabase db push`, then put that project's URL and anon key in `Config.xcconfig`.
Enable **Anonymous sign-ins** in the dashboard (Auth → Providers).
