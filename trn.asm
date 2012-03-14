.386
.model flat, stdcall  
option casemap :none  

include gdi32.inc
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include inc\ufmod.inc
include inc\image.inc

include \masm32\include\msimg32.inc

includelib \masm32\lib\msimg32.lib
includelib gdi32.lib
includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib lib\ufmod.lib
includelib winmm.lib
includelib lib\image.lib


OPTIONSTRUCT struct
	pattern 		dd 0 
	pattern_mask 	dd 0 
	module 			dd 0 
	bytecode 		dd 0 
	cave_bytecode 	dd 0 
	flag 			dd 0
	buffer 			dd 0 
	aF 				dd 0
	aT 				dd 0
	bSize			dd 0
	oSize			dd 0
	pSize			dd 0
OPTIONSTRUCT ends

DlgProc 			PROTO :HWND,:UINT,:WPARAM,:LPARAM
InitCaveProc 		PROTO :DWORD,:DWORD
WriteCave 			PROTO :DWORD,:DWORD,:DWORD
WriteBuffer 		PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetMemoryForCave	PROTO :DWORD
InitOption 			PROTO :OPTIONSTRUCT
TrnThread 			PROTO
PaintText 			PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawStars			PROTO :RECT

Random          	PROTO :DWORD

.const
IDT_STARS			equ 101
NumberOfStars 		equ 1000
StarStructureSize	equ 28

.data
;######################################################
gameName 		db "StarDefender4.exe",0
;######################################################
hCursor   		dd 0
fontname		db "Terminal",0
GameText		db "Star Defender 4 +4 trn by keng",0
OptionText1 	db "F1  - Activate trn",0
Option1Text 	db "F2  - Toggle infinite lives on\off"
Option2Text 	db "F3  - Toggle infinite ammo on\off"
Option3Text 	db "F4  - Toggle infinite shield on\off"
Option4Text 	db "F5  - Toggle flicker mode on\off"
Option5Text 	db "END - Back to normal"
GameRunning 	db "Game found",0
GameNotRunning	db "Start game",0
urlText			db "GameHackLab[RU]",0
;######################################################
;infinite lives
option1_pattern 			db 083h,0E9h,001h,08Bh,055h,0FCh,089h,08Ah,000h,000h,000h,000h
option1_mask 				db "xxxxxxxx0000"
option1_module				db "StarDefender4.exe",0
option1_original_bytecode	db 083h,0E9h,001h,08Bh,055h,0FCh
option1_cave_bytecode		db 08Bh,055h,0FCh,0C3h
option1_flag 				db 0
option1_buffer 				dd 0
option1_aF 					dd 0
option1_aT 					dd 0

option1 OPTIONSTRUCT <offset option1_pattern,\
					   offset option1_mask,\
					   offset option1_module,\
					   offset option1_original_bytecode,\
					   offset option1_cave_bytecode,\
					   0,\
					   offset option1_buffer,\
					   offset option1_aF,\
					   offset option1_aT,\
					   4,\
					   6,\
					   12>
;######################################################

;######################################################
option2_pattern 			db 02Bh,051h,040h,08Bh,045h,0ECh,089h,010h
option2_mask 				db "xxxxxxxx"
option2_module				db "StarDefender4.exe",0
option2_original_bytecode	db 02Bh,051h,040h,08Bh,045h,0ECh
option2_cave_bytecode		db 08Bh,045h,0ECh,0C3h
option2_flag 				db 0
option2_buffer 				dd 0
option2_aF 					dd 0
option2_aT 					dd 0

option2 OPTIONSTRUCT <offset option2_pattern,\
					   offset option2_mask,\
					   offset option2_module,\
					   offset option2_original_bytecode,\
					   offset option2_cave_bytecode,\
					   0,\
					   offset option2_buffer,\
					   offset option2_aF,\
					   offset option2_aT,\
					   4,\
					   6,\
					   8>
;######################################################
option3_pattern 			db 089h,041h,030h,0EBh,00Ah,08Bh,055h,0F4h
option3_mask 				db "xxxxxxxx"
option3_module				db "StarDefender4.exe",0
option3_original_bytecode	db 089h,041h,030h,0EBh,00Ah
option3_cave_bytecode		db 0B8h,0BCh,002h,000h,000h,089h,041h,030h,0E9h,0F2h,0F8h,018h,000h
option3_flag 				db 0
option3_buffer 				dd 0
option3_aF 					dd 0
option3_aT 					dd 0

option3 OPTIONSTRUCT <offset option3_pattern,\
					   offset option3_mask,\
					   offset option3_module,\
					   offset option3_original_bytecode,\
					   offset option3_cave_bytecode,\
					   0,\
					   offset option3_buffer,\
					   offset option3_aF,\
					   offset option3_aT,\
					   13,\
					   5,\
					   8>
;######################################################
option4_pattern 			db 00Fh,0B6h,091h,0B0h,000h,000h,000h,085h,0D2h,075h,021h
option4_mask 				db "xxxxxxxxxxx"
option4_module				db "StarDefender4.exe",0
option4_original_bytecode	db 00Fh,0B6h,091h,0B0h,000h,000h,000h
option4_cave_bytecode		db 0C6h,081h,0B0h,000h,000h,000h,001h,00Fh,0B6h,091h,0B0h,000h,000h,000h,0C3h 
option4_flag 				db 0
option4_buffer 				dd 0
option4_aF 					dd 0
option4_aT 					dd 0

option4 OPTIONSTRUCT <offset option4_pattern,\
					   offset option4_mask,\
					   offset option4_module,\
					   offset option4_original_bytecode,\
					   offset option4_cave_bytecode,\
					   0,\
					   offset option4_buffer,\
					   offset option4_aF,\
					   offset option4_aT,\
					   15,\
					   7,\
					   11>
;######################################################
  
EasternStar 	db FALSE ;Eastern Star Nv
Speed 			dd 10 ;speed
DisplaysTrolling db TRUE ;Drive type displayed or Displays Trolling

.data?
hWnd 			dd ?
hInstance 		dd ?
flag 			db ?
pid 			HANDLE ?
himg			dd ?
bkgDC			dd ?
hFont			dd ?
;######################################################
trn_active 		db ?
info_flag		db ?
game_flag		db ?
music_flag		db ?
music_paused	db ?
;-----------
hFontWindow		HFONT	?
hBgColor    	HBRUSH	?
hmainDC         HDC		?
hLayerDC1		HDC		?
starsDC			HDC		?
textDC			HDC		?
hBmpMain		HBITMAP ?
hBmpLayer1		HBITMAP ?
hBmpLayer2		HBITMAP ?
rScroll			RECT   <?>
hStars 			HANDLE ? ;H Stars
pStars 			dd ? ;P Stars
RandomNamePr 	dd ?
myRect			RECT	<?>
;######################################################
include inc\starfield.asm
include inc\scanner.inc
;######################################################

.code

start:
	invoke 	GetModuleHandle,NULL
	mov 	hInstance,eax	
    invoke 	InitCommonControls
	invoke 	DialogBoxParam,hInstance,101,NULL,addr DlgProc,NULL
	invoke 	ExitProcess,0
	
DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL hDC:HANDLE
LOCAL rect:RECT
LOCAL ps:PAINTSTRUCT
	push 		hWin
	pop 		hWnd
	.if uMsg==WM_INITDIALOG		
		invoke 	SetLayeredWindowAttributes,hWnd,0,180,LWA_ALPHA		
		invoke  BitmapFromResource,hInstance,2
		mov		himg,eax
		invoke  CreateFont,8,5,0,0,FW_NORMAL,0,0,0,OEM_CHARSET,0,0,0,0,addr fontname		
     	mov     [hFont],eax        
        invoke  CreateThread,NULL,NULL,TrnThread,NULL,NULL,NULL   
        invoke 	LoadCursor, hInstance, 1000
      	mov 	hCursor, eax
      	invoke 	SetClassLong, hWnd, GCL_HCURSOR, hCursor	
      	;-------------------------------------------------------	
		INVOKE  GetClientRect,hWnd,ADDR myRect	
	 	invoke 	CreateSolidBrush,TRANSPARENT 
		mov 	hBgColor,eax	
		;-------------------------------------------------------			
		invoke 	GetDC,hWnd
		mov 	hDC,eax ;SCREEN BUFFER
		invoke 	CreateCompatibleDC,hDC
		;-------------------------------------------------------
		mov 	hmainDC,eax    
    	invoke  CreateCompatibleDC,hDC ;BACKGROUND BUFFER
    	mov     bkgDC,eax
    	invoke  SelectObject,bkgDC,[himg]
    	;-------------------------------------------------------		
		invoke 	CreateCompatibleBitmap,hDC,myRect.right,myRect.bottom		
		invoke 	SelectObject,hmainDC,eax ;MAIN BUFFER
		mov 	hBmpMain,eax
		;-------------------------------------------------------
		invoke	CreateCompatibleDC,hDC
		mov 	textDC,eax ;TEXT BUFFER
		invoke	CreateCompatibleBitmap,hDC,myRect.right,myRect.bottom
		invoke 	SelectObject, textDC, eax
		invoke  CreateFont,8,5,0,0,FW_NORMAL,0,0,0,OEM_CHARSET,0,0,0,0,addr fontname
        invoke 	SelectObject, textDC, eax
        mov    	hFont,eax
        ;RGB    	255,255,255
        
        
        invoke 	SetTextColor,textDC,00FFFFFFh
        ;RGB    	0,0,255
        ;invoke  SetBkMode,textDC,eax
        invoke	GetStockObject,BLACK_BRUSH
        invoke	SelectObject,hLayerDC1,eax
        invoke 	DeleteObject,eax
        
        invoke	SetBkColor,textDC,0
                	
        ;-------------------------------------------------------	
		invoke 	CreateCompatibleDC,hDC		
		mov 	starsDC,eax ;STARS BUFFER
		invoke 	CreateCompatibleBitmap,hDC,myRect.right,myRect.bottom
		invoke 	SelectObject,starsDC,eax
		mov 	hBmpLayer2,eax		
		;-------------------------------------------------------
		invoke 	FillRect,starsDC,ADDR myRect,hBgColor
		invoke 	ReleaseDC,hWnd,hDC			
		invoke 	SetTimer,hWnd,IDT_STARS,1,0
		invoke 	GlobalAlloc, GMEM_MOVEABLE or GMEM_ZEROINIT, NumberOfStars * StarStructureSize
		mov 	hStars, eax
		invoke 	GlobalLock, hStars
		mov 	pStars, eax    	
      	mov 	eax,1
		ret  
    .elseif uMsg==WM_PAINT
    	invoke 	BeginPaint,hWnd,addr ps
    	mov 	hDC,eax
    	
    	mov esi,ps.rcPaint.right
		mov edi,ps.rcPaint.bottom
		sub esi,ps.rcPaint.left
		sub edi,ps.rcPaint.top
		invoke  BitBlt,hmainDC,0,0,240,160,bkgDC,0,0,SRCCOPY		
		invoke  BitBlt,hmainDC,10,10,220,120,starsDC,0,0,SRCCOPY
		invoke 	TransparentBlt,hmainDC,ps.rcPaint.left,ps.rcPaint.top,esi,edi,textDC,ps.rcPaint.left,ps.rcPaint.top,esi,edi,0		
		invoke	BitBlt,hDC,0,0,240,160,hmainDC,0,0,SRCCOPY
        invoke 	EndPaint,hWnd,addr ps
	  	mov 	eax,1
	  	ret
	.elseif uMsg == WM_TIMER			
		.if wParam == IDT_STARS						
			invoke 	GetStockObject,BLACK_BRUSH
			invoke 	FillRect,starsDC,ADDR myRect,eax
			invoke 	DrawStars,myRect
			invoke 	InvalidateRect,hWnd,NULL,FALSE			
		.endif
         mov eax,1
         ret
	.elseif uMsg==WM_CLOSE		
		invoke ExitProcess,0	
	.elseif uMsg==WM_LBUTTONDOWN	
		invoke 	SendMessage,hWnd,WM_NCLBUTTONDOWN,HTCAPTION,NULL	
		mov     eax,lParam
        mov     edx,eax
        shr     eax,16
        and     edx,0000FFFFh
        cmp     eax,130
        jle     @F
        cmp     edx,60
        jle     buttonabout
        ret
        buttonabout:
        .if info_flag==0
        	mov info_flag,1        	
        .else
        	mov info_flag,0
        .endif        
        @@:        	   	
	.elseif uMsg==WM_RBUTTONUP		
		invoke 	ExitProcess,0
	.else	
		mov 	eax,FALSE
		ret
	.endif
	mov 		eax,TRUE
	ret
DlgProc endp

ActivateTrainer proc

	.if trn_active==0
		mov		trn_active,1			
		invoke	InitOption,option1
		invoke	InitOption,option2
		invoke	InitOption,option3
		invoke	InitOption,option4		
	.endif					
	ret
	
ActivateTrainer endp

WriteBuffer proc t:dword,f:dword,b:dword,s:dword

	push eax
	push ebx
	mov ebx,[b]	
	mov dword ptr [ebx],0E8h	
	mov eax,t
	sub eax,f
	sub eax,5
	mov byte ptr [ebx+1],al
	mov byte ptr [ebx+2],ah
	shr eax,16
	mov byte ptr [ebx+3],al
	mov byte ptr [ebx+4],ah	
	mov eax,s
	sub eax,5	
	cmp eax,0		
	je $+10			
	mov byte ptr [ebx+5],090h
	inc ebx
	dec eax	
	jne $-11	
	pop ebx
	pop eax
	ret
	
WriteBuffer endp

GetProcess proc

LOCAL hSnapshot:dword,processmodule:PROCESSENTRY32	

	invoke CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS,0
   .if (eax != INVALID_HANDLE_VALUE)
       mov hSnapshot,eax
       mov [processmodule.dwSize],SIZEOF processmodule
       invoke Process32First, hSnapshot,ADDR processmodule
       .if (eax)
         @@:
           invoke lstrcmpi, ADDR gameName ,ADDR [processmodule.szExeFile]
           .if (eax == 0)
               	push 	processmodule.th32ProcessID
				pop		pid		
				mov		game_flag,1
				invoke CloseHandle, hSnapshot
				ret
		   .else
				mov 	game_flag,0																			
           .endif
           invoke Process32Next, hSnapshot,ADDR processmodule
           test eax,eax
           jnz @B       
       .endif
       invoke CloseHandle, hSnapshot   
   .endif
   ret	
   
GetProcess endp

GetMemoryForCave proc bsize:dword

LOCAL phndl:dword

	invoke	OpenProcess,PROCESS_ALL_ACCESS,NULL,pid
	.if eax!=0
		mov		phndl,eax				
		invoke 	VirtualAllocEx,phndl,NULL,bsize,MEM_COMMIT,PAGE_EXECUTE_READWRITE		
		push	eax
		invoke	CloseHandle,phndl
		pop		eax
	.endif		
	ret

GetMemoryForCave endp

WriteCave proc aT:dword,bytecode:dword,bsize:dword

LOCAL pHandle:dword
	
	invoke 	OpenProcess,PROCESS_ALL_ACCESS,NULL,pid	
	mov		pHandle,eax							
	invoke	WriteProcessMemory,pHandle,aT,bytecode,bsize,NULL				
	invoke	CloseHandle,pHandle	
	ret

WriteCave endp

InitOption proc structure:OPTIONSTRUCT
	
	invoke 	ScanPattern,structure.pattern,structure.pattern_mask,structure.module,structure.pSize;,pid	
	.if eax!=-1
		mov 	ebx,[structure.aT]
		mov 	[ebx],eax
		mov		structure.aT,eax	
		invoke 	GetMemoryForCave,structure.bSize
		mov 	ebx,[structure.aF]
		mov 	[ebx],eax
		mov		structure.aF,eax			
		invoke	WriteCave,structure.aF,structure.cave_bytecode,structure.bSize	
		invoke 	WriteBuffer,structure.aF,structure.aT,structure.buffer,structure.oSize
	.else
		invoke Beep,200,500
	.endif		
	ret

InitOption endp

TrnThread proc

check:
	call 	Paint_it	
	call 	GetProcess	
		
	invoke	GetAsyncKeyState,VK_F1
		.if eax
			invoke	Beep,1000,100
			call ActivateTrainer
		.endif
	invoke	GetAsyncKeyState,VK_F2
		.if eax						
			invoke	Beep,1000,100
			.if option1_flag==0			
				mov 	option1_flag,1
				invoke  WriteCave,option1_aT,addr option1_buffer,lengthof option1_original_bytecode 												
			.else
				mov option1_flag,0
				invoke  WriteCave,option1_aT,addr option1_original_bytecode,lengthof option1_original_bytecode								
			.endif
		.endif
	invoke	GetAsyncKeyState,VK_F3
		.if eax						
			invoke	Beep,1000,100
			.if option2_flag==0			
				mov 	option2_flag,1
				invoke  WriteCave,option2_aT,addr option2_buffer,lengthof option2_original_bytecode												
			.else
				mov option1_flag,0
				invoke  WriteCave,option2_aT,addr option2_original_bytecode,lengthof option2_original_bytecode								
			.endif
		.endif
	invoke	GetAsyncKeyState,VK_F4
		.if eax						
			invoke	Beep,1000,100
			.if option3_flag==0			
				mov 	option3_flag,1
				invoke  WriteCave,option3_aT,addr option3_buffer,lengthof option3_original_bytecode												
			.else
				mov option3_flag,0
				invoke  WriteCave,option3_aT,addr option3_original_bytecode,lengthof option3_original_bytecode								
			.endif
		.endif
	invoke	GetAsyncKeyState,VK_F5
		.if eax						
			invoke	Beep,1000,100
			.if option4_flag==0			
				mov 	option4_flag,1
				invoke  WriteCave,option4_aT,addr option4_buffer,lengthof option4_original_bytecode												
			.else
				mov option4_flag,0
				invoke  WriteCave,option4_aT,addr option4_original_bytecode,lengthof option4_original_bytecode								
			.endif
		.endif	
	invoke	GetAsyncKeyState,VK_END
		.if eax						
			invoke	Beep,1000,100
			.if option1_flag==1
				mov option1_flag,0
				invoke  WriteCave,option1_aT,addr option1_original_bytecode,lengthof option1_original_bytecode
			.elseif option2_flag==1
				mov option1_flag,0
				invoke  WriteCave,option2_aT,addr option2_original_bytecode,lengthof option2_original_bytecode
			.elseif option3_flag==1
				mov option3_flag,0
				invoke  WriteCave,option3_aT,addr option3_original_bytecode,lengthof option3_original_bytecode
			.elseif option4_flag==1
				mov option4_flag,0
				invoke  WriteCave,option4_aT,addr option4_original_bytecode,lengthof option4_original_bytecode	
			.endif			
		.endif	
	.if game_flag==0
		.if music_flag==0			
			.if music_paused == 1
				invoke  uFMOD_Resume	
			.else
				invoke	uFMOD_PlaySong,123,hInstance,XM_RESOURCE		
			.endif
			mov music_flag,1
		.endif		
	.elseif game_flag==1
		.if music_flag==1						
			invoke  uFMOD_Pause
			mov music_paused,1
			mov music_flag,0			
		.endif		
	.endif
    invoke     Sleep,100    
    jmp        check
TrnThread endp

Paint_it proc 
	
    .if info_flag==1    
    	invoke  SetTextColor,textDC,00FFFFFFh	
    	invoke	PaintText,addr GameText,sizeof GameText,10,10
     	invoke	PaintText,addr OptionText1,sizeof OptionText1,10,30
     	invoke	PaintText,addr Option1Text,sizeof Option1Text,10,40
     	invoke	PaintText,addr Option2Text,sizeof Option2Text,10,50
     	invoke	PaintText,addr Option3Text,sizeof Option3Text,10,60
     	invoke	PaintText,addr Option4Text,sizeof Option4Text,10,70
     	invoke	PaintText,addr Option5Text,sizeof Option5Text,10,80
     	invoke	PaintText,addr urlText,sizeof urlText,140,120
    .else
    	invoke  SetTextColor,textDC,00000000h
    	invoke	PaintText,addr GameText,sizeof GameText,10,10
     	invoke	PaintText,addr OptionText1,sizeof OptionText1,10,30
     	invoke	PaintText,addr Option1Text,sizeof Option1Text,10,40
     	invoke	PaintText,addr Option2Text,sizeof Option2Text,10,50
     	invoke	PaintText,addr Option3Text,sizeof Option3Text,10,60
     	invoke	PaintText,addr Option4Text,sizeof Option4Text,10,70
     	invoke	PaintText,addr Option5Text,sizeof Option5Text,10,80
     	invoke	PaintText,addr urlText,sizeof urlText,140,120
    .endif
    
    .if game_flag==1
    	invoke	PaintText,addr GameRunning,sizeof GameRunning,80,140
    .else
    	invoke	PaintText,addr GameNotRunning,sizeof GameNotRunning,80,140
    .endif
    
    ret
Paint_it endp

PaintText proc text:dword,len:dword,x:dword,y:dword
		   
    invoke  TextOut,textDC,x,y,text,len
	ret

PaintText endp

end start
