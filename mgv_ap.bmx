SuperStrict

' Only the essentials
Framework brl.standardio
Import brl.stream
Import brl.linkedlist
Import maxgui.drivers
Import maxgui.proxygadgets
Import brl.eventqueue

' Set the window title
Const VERSION:String = "1.0"
AppTitle = "METAL GEAR SURVIVE - Aspect Ratio Patcher v" + VERSION

' Set the mouse cursor to the loading cursor
SetPointer( POINTER_WAIT )

' Make sure we have the METAL GEAR SURVIVE executable
Local mgvExe:TMgvExe = New TMgvExe()

' Create a simple window using MaxGUI
Local Window:TGadget = CreateWindow( AppTitle, 0, 0, 340, 220, Desktop(), WINDOW_TITLEBAR | WINDOW_CENTER | WINDOW_CLIENTCOORDS | WINDOW_HIDDEN )
SetMinWindowSize( Window, GadgetWidth( Window ), GadgetHeight( Window ) )
Local InfoPanel:TGadget = CreatePanel( 16, 0, ClientWidth( Window ) - 32, 100, Window, PANEL_GROUP )
SetGadgetLayout( InfoPanel, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED )
Local InfoLabel:TGadget = CreateLabel( "Your primary monitor is:~n" + DesktopWidth() + "x" + DesktopHeight(), 0, 0, ClientWidth( InfoPanel ), ClientHeight( InfoPanel ), InfoPanel, LABEL_CENTER )
SetGadgetLayout( InfoLabel, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
Local AspectRatioLabel:TGadget = CreateLabel( "Game aspect ratio:", 16, GadgetY( InfoPanel ) + GadgetHeight( InfoPanel ) + 16 + 4, 128 - 8, 32 - 4, Window, LABEL_RIGHT )
SetGadgetLayout( AspectRatioLabel, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_CENTERED )
Local AspectRatioComboBox:TGadget = CreateComboBox( 128 + 16, GadgetY( InfoPanel ) + GadgetHeight( InfoPanel ) + 16, ClientWidth( Window ) - 16 - 128 - 16 - 24, 32, Window )
SetGadgetLayout( AspectRatioComboBox, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED )
Local ApplyButton:TGadget = CreateButton( "Apply", 16, ClientHeight( Window ) - 16 - 32 - 16, ClientWidth( Window ) - 32, 32, Window, BUTTON_OK )
SetGadgetLayout( ApplyButton, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED )
Local CreditsLabel:TGadget = CreateHyperlink( "https://hezkore.com", 16, ClientHeight( Window ) - 24, ClientWidth( Window ) - 32, 24, Window, LABEL_CENTER, "By Hezkore" )
SetGadgetLayout( CreditsLabel, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED )

' Add aspect ratios to the combo box
AddAspectRatio( AspectRatioComboBox, "5:4", 1067450368 )
AddAspectRatio( AspectRatioComboBox, "4:3", 1068149419 )
AddAspectRatio( AspectRatioComboBox, "3:23", 1069547520 )
AddAspectRatio( AspectRatioComboBox, "16:10", 1070386381 )
AddAspectRatio( AspectRatioComboBox, "15:9", 1070945621 )
AddAspectRatio( AspectRatioComboBox, "16:9", 1071877689 )
AddAspectRatio( AspectRatioComboBox, "1.85:1", 1072483533 )
AddAspectRatio( AspectRatioComboBox, "21:9 (2560x1080)", 1075295270 )
AddAspectRatio( AspectRatioComboBox, "21:9 (3440x1440)", 1075372942 )
AddAspectRatio( AspectRatioComboBox, "2.39:1", 1075377603 )
AddAspectRatio( AspectRatioComboBox, "21:9 (3840x1600)", 1075419546 )
AddAspectRatio( AspectRatioComboBox, "2.76:1", 1076929495 )
AddAspectRatio( AspectRatioComboBox, "32:10", 1078774989 )
AddAspectRatio( AspectRatioComboBox, "32:9", 1080266297 )
AddAspectRatio( AspectRatioComboBox, "3x5:4", 1081081856 )
AddAspectRatio( AspectRatioComboBox, "3x4:3", 1082130432 )
AddAspectRatio( AspectRatioComboBox, "3x16:10", 1083808154 )
AddAspectRatio( AspectRatioComboBox, "3x15:9", 1084227584 )
AddAspectRatio( AspectRatioComboBox, "3x16:9", 1084926635 )

' Get the users desktop aspect ratio
SetGadgetText( InfoLabel, GadgetText( InfoLabel ) + "~n~nRecommended aspect ratio:~n" + GetAspectRatioName( DesktopWidth(), DesktopHeight() ) )

' Set the combo box to the games current aspect ratio
If Not SetComboBoxAspectFromValue( AspectRatioComboBox, mgvExe.CurrentFullscreenAspect ) Then
	Notify( "The METAL GEAR SURVIVE executable is using an unknown aspect ratio!~nIt is very likely that this tool will not work.", True )
EndIf

' Reset the mouse cursor
SetPointer( POINTER_DEFAULT )

' Show the window
ShowGadget( Window )
ActivateWindow( Window )
ActivateGadget( AspectRatioComboBox )

' Main event loop
While WaitEvent()
	Select EventID()
		' Closing the window
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			Exit
		
		' Applying aspect ratio
		Case EVENT_GADGETACTION
			Select EventSource()
				Case ApplyButton
					mgvExe.ApplyAspectRatio( GetComboBoxAspect( AspectRatioComboBox ).Value )
			EndSelect
	EndSelect
Wend
End

' === Types ===

' Aspect ratio type
Type TAspectRatio
	Global Available:TList = CreateList()
	
	Field Name:String
	Field Value:Int
	Field Index:Int
	
	Method New( name:String, value:Int )
		Self.Name = name
		Self.Value = value
		Self.Index = Available.Count()
		Available.AddLast( Self )
	EndMethod
EndType

' METAL GEAR SURVIVE executable type
Type TMgvExe
	
	Const BackupName:String = "\mgv.exe.bak"
	Const ExpectVersion:String = "1.18_20211018"
	Const ExpectedMD5:String = "" ' TODO
	
	' The below offsets seem to be correct
	' But one oddity is that the "fullscreen" offset always needs to be set
	' Otherwise the window and borderless aspect ratios are ignored(?)
	' So best set them all to the same value for now
	Const BorderlessOffset:Int = 1966200 ' Borderless
	Const WindowOffset:Int = 1966951 ' Window
	Const FullscreenOffset:Int = 33904560 ' Fullscreen
	
	' Searches in order
	Field PossiblePaths:String[] = [ ".\mgv.exe", "C:\Program Files (x86)\Steam\steamapps\common\METAL GEAR SURVIVE\mgv.exe" ]
	Field Path:String
	Field BackupPath:String
	Field Bank:TBank
	Field CurrentWindowAspect:Int
	Field CurrentBorderlessAspect:Int
	Field CurrentFullscreenAspect:Int
	
	Method New()
		' Search for the executable in the known paths
		ChangeDir( AppDir )
		For Local i:Int = 0 Until PossiblePaths.Length
			If FileType( PossiblePaths[ i ] ) = FILETYPE_FILE Then
				Self.Path = PossiblePaths[ i ]
				Exit
			EndIf
		Next
		
		' Did we get a path?
		If Self.Path Then
			Print( "Found METAL GEAR SURVIVE executable at: " + Self.Path )
			Self.BackupPath = ExtractDir( Self.Path ) + BackupName
		Else
			Notify( "METAL GEAR SURVIVE executable not found!~nPlease place this tool in the game's directory.", True )
			End
		EndIf
		
		' Load the bank
		Self.Bank = LoadBank( Self.Path )
		If Not Self.Bank Then
			Notify( "Failed to load the METAL GEAR SURVIVE executable!", True )
			End
		EndIf
		
		' Make sure the bank is big enough!
		If BankSize( Self.Bank ) <= Self.FullscreenOffset Then
			Notify( "The METAL GEAR SURVIVE executable is too small!", True )
			End
		EndIf
		
		' Get the currently used aspect ratios
		Self.CurrentBorderlessAspect = PeekInt( Self.Bank, Self.BorderlessOffset )
		Self.CurrentWindowAspect = PeekInt( Self.Bank, Self.WindowOffset )
		Self.CurrentFullscreenAspect = PeekInt( Self.Bank, Self.FullscreenOffset )
		
		' TODO: Get the MD5 for the bank with the aspect ratio locations zeroed out
	EndMethod
	
	Method ApplyAspectRatio:Int( fullscreenAspect:Int, windowAspect:Int = -1, borderlessAspect:Int = -1 )
		' First, we check if there's a backup
		Local didBackup:Int = False
		If Not FileType( Self.BackupPath ) = FILETYPE_FILE Then'
			' There is none, let's make one!
			SaveBank( Self.Bank, Self.BackupPath )
			' Make sure the backup was created
			If Not FileType( Self.BackupPath ) = FILETYPE_FILE Then
				Notify( "Failed to create a backup of the METAL GEAR SURVIVE executable!~nIt is not safe to continue.", True )
				Return False
			Else
				' Make sure the size is correct
				If FileSize( Self.BackupPath ) <> FileSize( Self.Path ) Then
					Notify( "The backup of the METAL GEAR SURVIVE executable is the wrong size!~nIt is not safe to continue.", True )
					Return False
				Else
					Print( "Created a backup of the METAL GEAR SURVIVE executable." )
					didBackup = True
				EndIf
			EndIf
		Else
			Print( "Backup of the METAL GEAR SURVIVE executable found.~nLet's hope it's correct..." )
		EndIf
		
		' Did we get a window or bordeless aspect ratio?
		If borderlessAspect = -1 Then borderlessAspect = fullscreenAspect
		If windowAspect = -1 Then windowAspect = fullscreenAspect
		
		' Now we can try to write to the bank and actually save the executable
		PokeInt( Self.Bank, Self.BorderlessOffset, borderlessAspect )
		PokeInt( Self.Bank, Self.WindowOffset, windowAspect )
		PokeInt( Self.Bank, Self.FullscreenOffset, fullscreenAspect )
		If Not SaveBank( Self.Bank, Self.Path ) Then
			Notify( "Failed to patched the METAL GEAR SURVIVE executable!~nMake sure the game is not running and no other program is using it.", True )
			Return False
		Else
			If didBackup Then
				Notify( "Successfully patched the METAL GEAR SURVIVE executable!~nA backup was created.", False )
			Else
				Notify( "Successfully patched the METAL GEAR SURVIVE executable!", False )
			EndIf
		EndIf
	EndMethod
EndType

' === Helper functions ===

' Get the aspect ratio from the combo box
Function GetComboBoxAspect:TAspectRatio( comboBox:TGadget )
	Return TAspectRatio( GadgetItemExtra( comboBox, SelectedGadgetItem( comboBox ) ) )
EndFunction

' Set the combo box to the aspect ratio with the given value
Function SetComboBoxAspectFromValue:Int( comboBox:TGadget, value:Int )
	For Local ar:TAspectRatio = EachIn TAspectRatio.Available
		If ar.Value = value Then
			SelectGadgetItem( comboBox, ar.Index )
			Return True
		EndIf
	Next
	Return False
EndFunction

' Add an aspect ratio to the combo box and the aspect ratio list
Function AddAspectRatio( comboBox:TGadget, name:String, value:Int, tooltip:String = "" )
	Local ra:TAspectRatio = New TAspectRatio( name, value )
	AddGadgetItem( comboBox, name, 0, -1, tooltip, ra )
EndFunction

' Get the aspect ratio name from a width and height
Function GetAspectRatioName:String( width:Int, height:Int )
    Local gcd:Int = GCD( width, height )
    Return width / gcd + ":" + height / gcd
EndFunction

' Calculate the greatest common divisor (GCD)
Function GCD:Int(a: Int, b: Int)
	If (a = 0) Then Return b
	Return GCD( b Mod a, a )
EndFunction