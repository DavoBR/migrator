;NSIS Modern User Interface

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General
  !define APPNAME "CA API Gateway Migrator"
  !define COMPANYNAME "David Berroa"
  !define DESCRIPTION "Another migration utility for CA API Gateway"
  !define VERSIONMAJOR 1
  !define VERSIONMINOR 0
  !define VERSIONBUILD 0
  !define HELPURL "https://github.com/DavoBR/migrator" # "Support Information" link
  !define UPDATEURL "https://github.com/DavoBR/migrator/releases" # "Product Updates" link
  !define ABOUTURL "https://github.com/DavoBR/migrator" # "Publisher" link

  ;Name and file
  Name "${APPNAME}"
  OutFile "CA_API_Gateway_Migrator_v${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}.exe"
  Unicode True

  ;Default installation folder
  InstallDir "$LOCALAPPDATA\${APPNAME}"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\${APPNAME}" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "..\LICENSE.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

  LangString DESC_InstallFiles ${LANG_ENGLISH} "Install files"
  LangString DESC_DesktopShortcut ${LANG_ENGLISH} "Create a shortcut to program in Desktop folder"
  LangString DESC_StartMenuShortcut ${LANG_ENGLISH} "Create a shortcut to program in Start Menu folder"

;--------------------------------
;Installer Sections

Section "Install Files" InstallFiles
  SetOutPath "$INSTDIR"

  ; Files
  File "..\build\windows\runner\Release\migrator.exe"
  File "..\build\windows\runner\Release\flutter_windows.dll"
  File "..\build\windows\runner\Release\url_launcher_windows_plugin.dll"
  File /r "..\build\windows\runner\Release\data"
  File "deps\VC_redist.x64.exe"

  ; Install Visual Studio Runtime
  ExecWait '"$INSTDIR\VC_redist.x64.exe" /quiet /norestart'
  Delete "$INSTDIR\VC_redist.x64.exe"

  ;Store installation folder
  WriteRegStr HKCU "Software\${APPNAME}" "" $INSTDIR
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

Section "Desktop Shortcut" DesktopShortcut
  SetShellVarContext current
  CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\migrator.exe"
SectionEnd

Section "Start Menu Shortcut" StartMenuShortcut
  SetShellVarContext current
  CreateDirectory  "$SMPROGRAMS\${APPNAME}"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\migrator.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

;--------------------------------
;Functions

Function .onInit
  SectionSetFlags ${InstallFiles} 17
FunctionEnd

;--------------------------------
;Descriptions

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${InstallFiles} $(DESC_InstallFiles)
    !insertmacro MUI_DESCRIPTION_TEXT ${DesktopShortcut} $(DESC_DesktopShortcut)
    !insertmacro MUI_DESCRIPTION_TEXT ${StartMenuShortcut} $(DESC_StartMenuShortcut)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  # Remove Start Menu launcher
	RMDir /r "$SMPROGRAMS\${APPNAME}"

   # Remove Desktop launcher
  Delete "$DESKTOP\${APPNAME}.lnk"

  Delete "$INSTDIR\uninstall.exe"
  RMDir /r /REBOOTOK "$INSTDIR"


  DeleteRegKey /ifempty HKCU "Software\${APPNAME}"

SectionEnd