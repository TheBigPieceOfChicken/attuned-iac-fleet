<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadContent</key>
            <dict>
                <key>com.jamf.connect.license</key>
                <dict>
                    <key>Forced</key>
                    <array>
                        <dict>
                            <key>mcx_preference_settings</key>
                            <dict>
                                <key>DateIssued</key>
                                <string>${date_issued}</string>
                                <key>Edition</key>
                                <string>${edition}</string>
                                <key>Email</key>
                                <string>${email}</string>
                                <key>ExpirationDate</key>
                                <string>${expiration_date}</string>
                                <key>LicenseKey</key>
                                <string>${license_key}</string>
                                <key>MajorVersion</key>
                                <integer>${major_version}</integer>
                                <key>Name</key>
                                <string>${name}</string>
                                <key>NumberOfClients</key>
                                <integer>${num_clients}</integer>
                                <key>Product</key>
                                <string>Jamf Connect</string>
                                <key>Signature</key>
                                <data>${signature}</data>
                            </dict>
                        </dict>
                    </array>
                </dict>
            </dict>
            <key>PayloadDisplayName</key>
            <string>Jamf Connect License</string>
            <key>PayloadIdentifier</key>
            <string>com.jamf.connect.license.settings</string>
            <key>PayloadType</key>
            <string>com.apple.ManagedClient.preferences</string>
            <key>PayloadUUID</key>
            <string>1888E687-A072-4F79-83DB-6E8877B705B0</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>PayloadDescription</key>
    <string>Jamf Connect license for ${organization}</string>
    <key>PayloadDisplayName</key>
    <string>Jamf Connect License</string>
    <key>PayloadIdentifier</key>
    <string>com.jamf.connect.license</string>
    <key>PayloadOrganization</key>
    <string>${organization}</string>
    <key>PayloadScope</key>
    <string>System</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>25387E89-632F-4E8E-8A9E-DD1CC50A5A09</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
</plist>
