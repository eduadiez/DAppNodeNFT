# Deploy

# ACL 
## Add address APP_MANAGER_ROLE on KERNEL
$ aragon dao acl grant lionstake.aragonid.eth 0xce875b9e31917793a189f6dae266911fd9c115a8 APP_MANAGER_ROLE 0x70F264A331a9C3B3248537aCf2470D963be741e3       

it's needed to vote on the UI to grant the permission, and this is the acl result:

$ aragon dao acl lionstake.aragonid.eth --environment rinkeby view
  ⠏ Inspecting DAO Permissions
  ✔ Inspected DAO Permissions of 0xce875b9e31917793a189f6dae266911fd9c115a8

┌────────────────────────┬────────────────────────────┬─────────────────────┬──────────────────┐
│ App                    │ Action                     │ Allowed entities    │ Manager          │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ acl (0x7c15)           │ CREATE_PERMISSIONS_ROLE    │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ kernel (0xce87)        │ APP_MANAGER_ROLE           │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
│                        │                            │ ✅  0x70F264..e741e3 │                  │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ evmreg (0x7cae)        │ REGISTRY_ADD_EXECUTOR_ROLE │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ evmreg (0x7cae)        │ REGISTRY_MANAGER_ROLE      │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ token-manager (0x422f) │ MINT_ROLE                  │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ token-manager (0x422f) │ BURN_ROLE                  │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ vault (0xb0fc)         │ TRANSFER_ROLE              │ ✅  0x9152Fd..226575 │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ finance (0x9152)       │ EXECUTE_PAYMENTS_ROLE      │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ finance (0x9152)       │ MANAGE_PAYMENTS_ROLE       │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ finance (0x9152)       │ CREATE_PAYMENTS_ROLE       │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ voting (0x25c4)        │ MODIFY_QUORUM_ROLE         │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ voting (0x25c4)        │ MODIFY_SUPPORT_ROLE        │ ✅  0x25C4b8..b0BAEC │ 0x25C4b8..b0BAEC │
├────────────────────────┼────────────────────────────┼─────────────────────┼──────────────────┤
│ voting (0x25c4)        │ CREATE_VOTES_ROLE          │ ✅  0x422f5b..d32948 │ 0x25C4b8..b0BAEC │
└────────────────────────┴────────────────────────────┴─────────────────────┴──────────────────┘

## grant address CREATE_PERMISSIONS_ROLE on "ACL permissions"
$ aragon dao acl grant lionstake.aragonid.eth 0x7c1597fe7bfb54be80f7ceeae0d52b54f63554c6 CREATE_PERMISSIONS_ROLE 0x70F264A331a9C3B3248537aCf2470D963be741e3       

it's needed to vote on the UI to grant the permission 

## Install the NFT Token
$ aragon dao install lionstake.aragonid.eth aragonnft.open.aragonpm.eth --environment rinkeby --app-init-args LionStakeNFT LNFT --set-permissions open

## Check installed Apps
aragon dao apps lionstake.aragonid.eth --environment rinkeby --all 

## Publish new version
aragon apm publish patch --environment rinkeby --ipfs-rpc http://ipfs.dappnode:5001#default --ipfs-gateway http://ipfs.dappnode:8080/ipfs/