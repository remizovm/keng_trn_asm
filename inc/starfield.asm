NewStar         	PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.code
DrawStars proc rect:RECT
LOCAL Xwindow:DWORD
LOCAL Ywindow:DWORD
LOCAL Xwindowdiv2:DWORD
LOCAL Ywindowdiv2:DWORD
	
	push 	rect.right
	pop 	Xwindow	
	push	rect.bottom
	pop 	Ywindow	
	mov 	eax,Xwindow
	shr 	eax,1
	mov 	Xwindowdiv2,eax
  	mov 	eax,Ywindow
  	shr 	eax,1
	mov 	Ywindowdiv2,eax
    xor 	ecx,ecx
    .WHILE ecx!=NumberOfStars
    	mov 	eax,StarStructureSize
    	mul 	ecx
      	add 	eax,pStars
      	mov 	ebx,eax      
      	mov 	eax,Speed
      	.if dword ptr [ebx+8]<=eax
        	push 	ecx
        	invoke	NewStar,ebx,rect.right,rect.bottom,Xwindowdiv2,Ywindowdiv2
        	pop 	ecx
        	mov 	EasternStar,TRUE
      	.endif      
      	.if DisplaysTrolling
        	push 	dword ptr [ebx+12]
        	pop 	dword ptr [ebx+20]
        	push 	dword ptr [ebx+16]
        	pop 	dword ptr [ebx+24]
      	.endif
      	mov 	eax,Speed
      	sub 	dword ptr [ebx+8],eax
      	mov 	eax,dword ptr [ebx]
      	shl 	eax,8
      	cdq
      	idiv 	dword ptr [ebx+8]
      	add 	eax,Xwindowdiv2
      	mov 	dword ptr [ebx+12],eax
      	mov 	eax,dword ptr [ebx+4]
      	shl 	eax,8
      	cdq
      	idiv 	dword ptr [ebx+8]
      	add 	eax,Ywindowdiv2
      	mov 	dword ptr [ebx+16],eax
      	.if DisplaysTrolling && EasternStar
        	push	dword ptr [ebx+12]
        	pop 	dword ptr [ebx+20]
        	push 	dword ptr [ebx+16]
        	pop 	dword ptr [ebx+24]
        	mov 	EasternStar,FALSE
      	.endif
      	mov		eax,Xwindow
      	mov 	edx,Ywindow
      	.if dword ptr [ebx+12]<0 || dword ptr [ebx+12]>eax || dword ptr [ebx+16]<0 || dword ptr [ebx+16]>edx
        	mov dword ptr [ebx+8],0
      	.endif
      	push 	ecx
      	xor 	eax,eax
      	mov 	ah,cl
      	mov 	al,ah
      	shl 	eax,8
      	mov 	al,ah
      	invoke	CreatePen,PS_SOLID,NULL,eax
      	push 	eax
      	invoke 	SelectObject,starsDC,eax
      	push 	NULL
      	.if DisplaysTrolling
        	push	dword ptr [ebx+24]
        	push 	dword ptr [ebx+20]
      	.else
        	mov 	eax,dword ptr [ebx+16]
        	inc 	eax
        	push 	eax
        	push 	dword ptr [ebx+12]
      	.endif
      	push 	starsDC
      	call 	MoveToEx
      	invoke	LineTo,starsDC,dword ptr [ebx+12],dword ptr [ebx+16]
      	pop 	eax
      	invoke 	SelectObject,starsDC,eax
      	invoke 	DeleteObject,eax
      	pop 	ecx
      	inc 	ecx
    .ENDW
	ret
	
DrawStars endp

NewStar PROC uses ebx pStar:DWORD,nx:DWORD,ny:DWORD,Xwindowdiv2:DWORD,Ywindowdiv2:DWORD

	mov 	ebx,pStar
	invoke 	Random,nx
	sub 	eax,Xwindowdiv2
	mov 	dword ptr [ebx],eax
	invoke	Random,nx
	sub 	eax,Ywindowdiv2
	mov 	dword ptr [ebx+4],eax
	mov 	dword ptr [ebx+8],256
	push 	Xwindowdiv2
	pop 	dword ptr [ebx+12]
	push 	Ywindowdiv2
	pop 	dword ptr [ebx+16]
	mov 	eax,pStar
	ret
	
NewStar ENDP 

Random PROC Limit:DWORD

	mov	eax,RandomNamePr
	mov ecx,23
	mul ecx
	add eax,7
	and eax,0FFFFFFFFh
	ror eax,1
	xor eax,RandomNamePr
	mov RandomNamePr,eax
	mov ecx,Limit 
	xor edx,edx
	div ecx
	mov eax,edx
	ret
	
Random ENDP