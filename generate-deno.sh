#!/usr/bin/env bash

replaceTsPath(){
	grep -R "from '$1'" ./deno/*|grep '.ts:'|cut -d ":" -f 1|sort|uniq|xargs -I___ sed -i -e "s+from '$1'+from '$2'+g" ___
}

# Remove TS files
find ./deno -iname '*.ts' -delete

# Create subdirectories based on src structure
find ./src -type d |sed "s/^.\/src/deno/g"|xargs -I___ mkdir -p ___

# Copy TS files from ./src to ./deno
find ./src -iname '*.ts'|sed "s/^.\/src//g"|xargs -I___ cp ./src___ ./deno___

# Transform TS / Deno paths (import / export)
replaceTsPath '../' '../index.ts'
replaceTsPath './types' './types/index.ts'
replaceTsPath './types/xumm-api' './types/xumm-api/index.ts'
replaceTsPath './utils' './utils.ts'
replaceTsPath './xumm-api' './xumm-api/index.ts'
replaceTsPath './SubscriptionCallbackParams' './SubscriptionCallbackParams.ts'
replaceTsPath './ApplicationDetails' './ApplicationDetails.ts'

replaceTsPath './Storage' './Storage.ts'
replaceTsPath './Payload' './Payload.ts'
replaceTsPath './Meta' './Meta.ts'

# Transform TS / Deno paths globally in type export 
sed -i -e "s+from './\(.*\)/\([a-zA-Z]*\)'+from './\1/\2.ts'+g" ./deno/types/index.ts

sed -i -e "s+: WebSocket.MessageEvent+: MessageEvent+g" ./deno/Payload.ts
sed -i -e "s+: WebSocket.CloseEvent+: CloseEvent+g" ./deno/Payload.ts

# Replace SDK user agent
packageVersion=$(cat package.json|grep version|cut -d '"' -f 4)
sed -i -e "s+'User-Agent': .*+'User-Agent': 'xumm-sdk/deno:${packageVersion}',+g" deno/Meta.ts

# Remove/replace TS specific packages
sed -i -e "/import.*'node-fetch'/d" ./deno/Meta.ts
sed -i -e "/import.*'os'/d" ./deno/Meta.ts
sed -i -e "/import.*'..\/package.json'/d" ./deno/Meta.ts

sed -i -e "s+.*from 'dotenv'+import 'https://deno.land/x/dotenv/load.ts'+g" ./deno/index.ts

# Remove ws lib. import / namespace
sed -i -e "/import type WebSocket from 'ws'/d" ./deno/types/Payload/PayloadSubscription.ts
sed -i -e "/import WebSocket from 'ws'/d" ./deno/Payload.ts

# Update WS connection (skip mock)
sed -i -e "/.*global as any.*MockedWebSocket.*/d" ./deno/Payload.ts
sed -i -e "s+  : \(new WebSocket.*\)+const socket = \1+g" ./deno/Payload.ts

# Deno specific Debug
replaceTsPath 'debug' 'https://deno.land/x/debug/mod.ts'

# Clean OSX sed backup files:
find ./deno -iname '*.ts-e' -delete