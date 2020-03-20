[Setup]
AppName= DCI Registry Defrag 2012
AppVerName=2.0
AppPublisher=Design, Create & Implement LLC
AppPublisherURL=http://dci-software.com/defrag.html
AppSupportURL=http://dci-software.com/defrag.html
AppUpdatesURL=http://dci-software.com/defrag.html
DefaultDirName={pf}\Registry Defrag 2012
OutputDir=Out
DefaultGroupName=DCI Registry Defrag 2012
OutputBaseFilename=defrag
Compression=lzma
SolidCompression=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "Program Files\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Registry Defrag 2012"; Filename: "{app}\RegDefrag.exe"
Name: "{group}\{cm:UninstallProgram, Registry Defrag 2012}"; Filename: "{uninstallexe}"



[Run]
Filename: "{app}\RegDefrag.exe"; Description: "{cm:LaunchProgram, Registry Defrag 2012}"; Flags: nowait postinstall skipifsilent

