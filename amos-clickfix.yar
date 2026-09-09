rule AMOS_ClickFix_packed_macho
{
    meta:
        description = "Packed Mach-O carrying an encrypted run-only AppleScript, AMOS ClickFix chain"
        reference   = "https://bazaar.abuse.ch/sample/4903c40fbdb96cf39f35ed592a886a39d230564b26dd80aef3fa6c58bc501551/"
        malware     = "osx.amos"
        // The packer encrypts its strings, so this keys on structure and on the
        // signing identifier pattern, which is stable across builds while the
        // hashes rotate hourly.

    strings:
        // Ad-hoc signing identifier: "setup-" followed by 40 lowercase hex chars.
        $sigid = /setup-[0-9a-f]{40}/ ascii

        // Constant left in the clear by the packer in both observed builds.
        $pad = "6666666666666666\\\\\\\\\\\\\\\\" ascii

    condition:
        // Fat Mach-O header, two architectures (x86_64 + arm64).
        uint32be(0) == 0xcafebabe and uint32be(4) == 2
        and filesize > 250KB and filesize < 500KB
        and all of them
}

rule AMOS_ClickFix_applescript
{
    meta:
        description = "Run-only AppleScript payload, AMOS ClickFix chain"
        reference   = "https://bazaar.abuse.ch/sample/8f12396cfb1ac4d52b3c0fad997b2cf83839bc464cfa43e43959239a3016d287/"
        malware     = "osx.amos"
        // Strings inside a compiled AppleScript are UTF-16 big-endian, which YARA's
        // "wide" modifier does not cover (it is little-endian), so they are written
        // out as byte sequences.

    strings:
        $magic = "FasdUAS " ascii

        // "teamid:EQHXZ8M8AV"
        $team  = { 00 74 00 65 00 61 00 6d 00 69 00 64 00 3a 00 45 00 51 00 48 00 58 00 5a 00 38 00 4d 00 38 00 41 00 56 }
        // "set-generic-password-partition-list"
        $part  = { 00 73 00 65 00 74 00 2d 00 67 00 65 00 6e 00 65 00 72 00 69 00 63 00 2d 00 70 00 61 00 73 00 73 00 77 00 6f 00 72 00 64 00 2d 00 70 00 61 00 72 00 74 00 69 00 74 00 69 00 6f 00 6e 00 2d 00 6c 00 69 00 73 00 74 }
        // "/zxc/appex.zip"
        $zxc   = { 00 2f 00 7a 00 78 00 63 00 2f 00 61 00 70 00 70 00 65 00 78 00 2e 00 7a 00 69 00 70 }
        // ".com.apple.accountsd"
        $acct  = { 00 2e 00 63 00 6f 00 6d 00 2e 00 61 00 70 00 70 00 6c 00 65 00 2e 00 61 00 63 00 63 00 6f 00 75 00 6e 00 74 00 73 00 64 }
        // "masterpass-chrome"
        $mpass = { 00 6d 00 61 00 73 00 74 00 65 00 72 00 70 00 61 00 73 00 73 00 2d 00 63 00 68 00 72 00 6f 00 6d 00 65 }

    condition:
        $magic at 0 and 2 of ($team, $part, $zxc, $acct, $mpass)
}
