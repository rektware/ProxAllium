; USE THIS PROGRAM AT YOUR OWN RISK
; THIS PROGRAM IS CURRENTLY AT VERY EARLY STAGES - Not suitable for normal use!
#include <Color.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <FontConstants.au3>
#include <GuiEdit.au3>
#include "Tor.au3"

Opt("GUIOnEventMode", 1)

GUI_CreateLogWindow()
GUI_LogOut("Starting ProxAllium... Please wait :)")

Global Const $CONFIG_INI = @ScriptDir & '\config.ini'

Global $g_sTorPath = IniRead($CONFIG_INI, "tor", "path", @ScriptDir & '\Tor\tor.exe')
Global $g_sTorConfigFile = IniRead($CONFIG_INI, "tor", "config_file", @ScriptDir & '\Tor\config.torrc')
Global $g_iOutputPollInterval = Int(IniRead($CONFIG_INI, "proxallium", "output_poll_interval", "250"))

Global $g_aTorVersion = _Tor_SetPath($g_sTorPath)
GUI_LogOut("Detected Tor version: " & $g_aTorVersion[$TOR_VERSION])

GUI_LogOut("Starting Tor...")
Global $g_aTorProcess = _Tor_Start($g_sTorConfigFile)
GUI_LogOut("Started Tor with PID: " & $g_aTorProcess[$TOR_PROCESS_PID])

#Region Tor Output Handler
GUI_CreateTorOutputWindow()

Global $g_sPartialTorOutput = ""
While ProcessExists($g_aTorProcess[$TOR_PROCESS_PID]) ; Loop until the Tor exits
	$g_sPartialTorOutput = StdoutRead($g_aTorProcess[$TOR_PROCESS_PID])
	If Not $g_sPartialTorOutput = "" Then _GUICtrlEdit_AppendText($g_hTorOutput, $g_sPartialTorOutput)
	Sleep($g_iOutputPollInterval) ; Don't kill the CPU
WEnd
#EndRegion Tor Output Handler

GUI_LogOut("Tor exited with exit code: " & _Process_GetExitCode($g_aTorProcess[$TOR_PROCESS_HANDLE]))
GUI_LogOut("Close the window by clicking X to exit ProxAllium!")

While True
	Sleep(1000)
WEnd

#Region GUI
#Region GUI Creation
Func GUI_CreateLogWindow()
	Local Const $eiGuiWidth = 580, $eiGuiHeight = 280
	Global $g_hLogGUI = GUICreate("ProxAllium", $eiGuiWidth, $eiGuiHeight, Default, Default, $WS_OVERLAPPEDWINDOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_Exit")
	Global $g_idLogCtrl = GUICtrlCreateEdit("", 0, 0, $eiGuiWidth, $eiGuiHeight, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
	Global $g_hLogCtrl = GUICtrlGetHandle($g_idLogCtrl) ; Get the handle of the Edit control for future use in GUI_LogOut
	GUICtrlSetFont($g_idLogCtrl, 9, Default, Default, "Consolas")
	GUISetState() ; Make the GUI visible
EndFunc

Func GUI_LogOut($sText)
	_GUICtrlEdit_AppendText($g_hLogCtrl, $sText & @CRLF)
EndFunc

Func GUI_CreateTorOutputWindow()
	Local Const $eiGuiWidth = 580, $eiGuiHeight = 280
	Global $g_hTorGUI = GUICreate("Tor Output", $eiGuiWidth, $eiGuiHeight, Default, Default, $WS_OVERLAPPEDWINDOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_Exit")
	Global $g_idTorOutput = GUICtrlCreateEdit("", 0, 0, $eiGuiWidth, $eiGuiHeight, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
	Global $g_hTorOutput = GUICtrlGetHandle($g_idTorOutput) ; Get the handle of the Edit control for future use in the Tor Output Handler
	GUICtrlSetFont($g_idTorOutput, 9, Default, Default, "Consolas")
	GUICtrlSetBkColor($g_idTorOutput, $COLOR_BLACK)
	Local $aGrayCmdColor[3] = [197, 197, 197] ; CMD Text Color's combination in RGB
	Local Const $iGrayCmdColor = _ColorSetRGB($aGrayCmdColor) ; Get the RGB code of CMD Text Color
	GUICtrlSetColor($g_idTorOutput, $iGrayCmdColor)
	GUISetState() ; Make the GUI visible
EndFunc
#EndRegion

#Region GUI Handlers
Func GUI_Exit()
	ProcessClose($g_aTorProcess[$TOR_PROCESS_PID])
	GUISetState(@SW_HIDE, $g_hTorGUI)
	If @GUI_WinHandle = $g_hLogGUI Then Exit
EndFunc
#EndRegion GUI Handlers
#EndRegion GUI