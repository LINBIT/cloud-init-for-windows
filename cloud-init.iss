; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
; Use iscc to compile this (in your innosetup program directory)

#define MyAppName "LINBIT Simple Incomplete Cloud For Windows"
#define MyAppPublisher "Linbit"
#define MyAppURL "http://www.linbit.com/"
#define MyAppURLDocumentation "https://www.linbit.com/user-guides/"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{865f660f-aa7a-4500-9aad-2c110fb24140}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppCopyright=GPL
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ChangesEnvironment=yes
DefaultDirName={pf}\{#MyAppName}
DisableDirPage=auto
DefaultGroupName={#MyAppName}
; LicenseFile={#WindrbdSource}\LICENSE.txt
; InfoBeforeFile={#WindrbdSource}\inno-setup\about-windrbd.txt
OutputDir=.
OutputBaseFilename=install-cloud-init-{#MyAppVersion}
PrivilegesRequired=admin
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
; SetupIconFile=windrbd.ico
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "greek"; MessagesFile: "compiler:Languages\Greek.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "serbiancyrillic"; MessagesFile: "compiler:Languages\SerbianCyrillic.isl"
Name: "serbianlatin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
; Name: modifypath; Description: &Add application directory to your environmental path;

[Dirs]
Name: "{app}\drbd-resources"

[Files]
Source: "virter-parse-cloud-init.sh"; DestDir: "C:\WinDRBD"
Source: "cloud-init.bat"; DestDir: "C:\WinDRBD"

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\View {#MyAppName} Tech Guides"; Filename: "{#MyAppURLDocumentation}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Run]

Filename: "schtasks.exe"; Parameters: "/create /sc onstart /tn ""Simple Incomplete Cloud Init For Windows"" /tr C:\WinDRBD\cloud-init.bat /ru Administrator /rp LIN:BIT!23 /f"; Flags: runascurrentuser waituntilterminated shellexec runhidden

[UninstallRun]

Filename: "schtasks.exe"; Parameters: "/delete /tn ""Simple Incomplete Cloud Init For Windows"" /f"; Flags: runascurrentuser waituntilterminated shellexec runhidden

[Registry]

[Code]

