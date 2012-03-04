format	    PE GUI 4.0
entry	    start

include     'win32a.inc'
include     'inc\trn_engine.inc'
include     'inc\sigscan.inc'
include     'inc\structures.inc'


section '.data' data readable writable
	hinst	     dd 0
	hDC	     dd 0
	memDC	     dd 0
	Handler      dd 0
	hFont	     dd 0
	hEd	     dd 0
	flag	     db 0
	himg	     dd 0
	info_flag    db 0
	font	     db "Terminal",0
	phandle      dd 0
	trn_flag     dd 0
	;scanner
	ScanPattern  dd _ScanPattern
	;scanner
	Text1		db 'Coded by keng.',0
	text_sz=$-Text1
;-----------------------Change stuff here---------------------
	wCaption	db 'Call of Duty',0
	;addie           dd 0x10fac95
	;valon           db 0x90,0x90,0x90
	;valoff          db 0x29,0x5e,0x00
;-----------------------Change stuff here---------------------
option1_pattern 	db 0xFF,0x8C,0x88,0x00,0x00,0x00,0x00,0xA1,0x00,0x00,0x00,0x00,0x83,0x78,0x70,0x01,0x75,0x0B
option1_mask		db "xxx0000x0000xxxxxx"
option1_module		db 'gamex86.dll',0
;-----------------------Change stuff here---------------------

prcs			PROCESSENTRY32
module			MODULEENTRY32
hSnapshot		dd ?
mSnapshot		dd ?
PrcList 		db 'codsp.exe',0
dllname_addr		dd 0x0005E16C
;buffer_handle           dd ?
;buffer_address          dd ?
;buffer_name             dd ?
pID			dd ?
;-----------------------Change stuff here---------------------





section '.code' code readable writable
  start:
	invoke	GetModuleHandle,0
	mov	[hinst],eax
	invoke	DialogBoxParam,[hinst],37,HWND_DESKTOP,DialogProc,0
	or	eax,eax
	jz	exit
  exit:
	invoke	ExitProcess,0

proc DialogProc,hwnddlg,msg,wparam,lparam
     pushad
     cmp     [msg],WM_INITDIALOG
     je      wminitdialog
     cmp     [msg],WM_CLOSE
     je      wmclose
     cmp     [msg],WM_LBUTTONDOWN
     je      move
     cmp     [msg],WM_RBUTTONUP
     je      wmclose
processed:
     popad
     xor     eax,eax
     ret
wminitdialog:
     push    [hwnddlg]
     pop     [Handler]
     invoke  LoadIcon,[hinst],1
     invoke  SendMessage,[hwnddlg],WM_SETICON,1,eax
     invoke  LoadBitmap,[hinst],12
     mov     [himg],eax
     invoke  CreateFont,8,5,0,0,FW_NORMAL,0,0,0,OEM_CHARSET,0,0,0,0,font
     mov     [hFont],eax
     invoke  SetWindowPos,[hwnddlg],-1, 0, 0, 240, 160,2
     invoke  CreateThread,0,0,TrnThread,0,0,0
     jmp     processed
wmclose:
     invoke  EndDialog,[hwnddlg],0
     jmp     processed
buttonabout:
	cmp	[info_flag],1
	jne	@F
	mov	[info_flag],0
	jmp	processed
	@@:
	mov	[info_flag],1
	jmp	processed
move:
	invoke	SendMessage,[hwnddlg],WM_NCLBUTTONDOWN,2,0
	mov	eax,[lparam]
	mov	edx,eax
	shr	eax,16
	and	edx,0x0000FFFF
	cmp	eax,130
	jle	@F
	cmp	edx,70
	jle	buttonabout
	@@:
	jmp	processed
endp

proc Paint_it
     invoke	GetDC,[Handler]
     mov	[hDC],eax
     invoke	CreateCompatibleDC,[hDC]
     mov	[memDC],eax
     invoke	SelectObject,[memDC],[himg]
     invoke	BitBlt,[hDC],0,0,240,160,[memDC],0,0,SRCCOPY
     call	PaintText
     invoke	DeleteDC,[memDC]
     invoke	ReleaseDC,[Handler],[hDC]
     ret
endp

proc PaintText
     invoke	SelectObject,[hDC],[hFont]
     invoke	SetBkMode,[hDC],TRANSPARENT
     cmp	[info_flag],1
     jne	@F
     invoke	SetTextColor,[hDC],00FFFFFFh
     invoke	TextOut,[hDC],20,20,Text1,text_sz
     ret
     @@:
     invoke	SetTextColor,[hDC],0010101h
     invoke	TextOut,[hDC],20,20,Text1,text_sz
     ret
endp

proc TrnThread
     check:
     call	Paint_it
     invoke	GetAsyncKeyState,VK_F1
     cmp	eax,0
     je 	@F
     call	ActivateTrn
     ;call       GetProcess
     ;call       GetProcessModule
     @@:
     invoke	Sleep,100
     jmp	check
endp



data	    import
library     kernel32,'kernel32.dll',\
	    user32,'user32.dll',gdi32,'gdi32.dll',\
	    shell32,'shell32.dll'

include     '\api\kernel32.inc'
include     '\api\user32.inc'
include     '\api\gdi32.inc'
include     '\api\shell32.inc'
end	    data

section '.rsrc' resource data readable

  directory RT_DIALOG,dialogs,RT_ICON,icons,RT_GROUP_ICON,group_icons,\
	    RT_BITMAP,bitmaps

  resource dialogs,\
	   37,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration

  dialog demonstration,'keng +1 trn',0,0,240,160,WS_POPUP;
  enddialog


resource    icons,1,LANG_NEUTRAL,icon1_data  
resource    group_icons,1,LANG_NEUTRAL,icon1  
  
  icon icon1,icon1_data, ".\res\1.ico"
  
resource    bitmaps,12,LANG_NEUTRAL,bitmap12

bitmap bitmap12,'.\res\bkg.bmp'


  