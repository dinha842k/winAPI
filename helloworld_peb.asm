
;note: 
;when write x64 -> kernel32.dll or any dll is 64 bit version
;first link -> ntdll.dll
;second link -> kernelbase.dll
;third link -> kernel32.dll 	

.data
pointer_to_base_addr dq ?
pointer_to_export dq ?
pointer_to_name_func dq ?
pointer_to_ordinal dq ?
pointer_to_addr_func dq ?

GetStdHandle dq ?
GetStdHandle_text db "GetStdHandle",0

WriteFile dq ?
WriteFile_text db "WriteFile",0

lstrlenA dq ?
lstrlenA_text db "lstrlenA",0


ExitProcess dq ?
ExitProcess_text db "ExitProcess",0

msg db "hello world !",0

.code
main proc
	push rbp
	mov rbp,rsp
	sub rsp,8
	
	mov rax,gs:[60h] 			;peb
	mov rax,[rax + 18h]         ;ldr 		
	;ldr 0x7fff0973a4c0
	; flink 0x2eb754c2ac
	mov rax,[rax + 30h]     	;link l1
	mov rax,[rax] 				;link l2
	mov rax,[rax]
	mov rax,[rax + 10h]
	mov rbx,qword ptr[rax]     	;
	mov [pointer_to_base_addr],rax
	
	xor rcx,rcx
	mov ecx,dword ptr[rax + 60] ;	pointer to pe pe 
	mov rsi,[pointer_to_base_addr]
	add rsi,rcx
	xor rdi,rdi
	mov edi,dword ptr[rsi + 136]
	add rdi,[pointer_to_base_addr]	
	mov [pointer_to_export],rdi
	xor rax,rax
	mov eax,dword ptr[rdi+32]
	add rax,[pointer_to_base_addr]
	mov [pointer_to_name_func],rax
	xor rax,rax
	mov eax,dword ptr[rdi+36]
	add rax,[pointer_to_base_addr]
	mov [pointer_to_ordinal],rax
	xor rax,rax
	mov eax,dword ptr[rdi+28]
	add rax,[pointer_to_base_addr]
	mov [pointer_to_addr_func],rax
	
	lea rcx,GetStdHandle_text
	call Find_Function_Addr
	mov [GetStdHandle],rax
	
	lea rcx,WriteFile_text
	call Find_Function_Addr
	mov [WriteFile],rax

	lea rcx,lstrlenA_text
	call Find_Function_Addr
	mov [lstrlenA],rax
	
	lea rcx,ExitProcess_text
	call Find_Function_Addr
	mov [ExitProcess],rax
	
	lea rcx,msg
	call WriteOut
	
	mov rcx,0
	;mov rax,[ExitProcess]
	;call rax
	call [ExitProcess]
	leave
	ret
main endp

Find_Function_Addr proc
	push rbp
	mov rbp,rsp
	sub rsp,32
	mov [rbp-8],rcx
	mov rsi,[pointer_to_export]
	xor rcx,rcx
	mov ecx,dword ptr[rsi + 24]
	mov [rbp-16],rcx
	mov rsi,[pointer_to_name_func]
	mov [rbp-24],rsi
	mov rsi,[pointer_to_ordinal]
	mov [rbp-32],rsi
L1:	
	mov rcx,[rbp-16]
	cmp rcx,1
	jb QUIT_FAIL
	mov rsi,[rbp-24]
	xor rax,rax
	mov eax,dword ptr[rsi] 			;rva name
	add rax,[pointer_to_base_addr]  ;ascii
	mov rcx,rax
	mov rdx,[rbp-8]
	call Compare
	cmp rax,1
	jnz NEXT_FUNC
	xor rcx,rcx
	mov rsi,qword ptr [rbp-32] 		;ordinal 
	mov cx,[rsi]
	lea rcx,[rcx*4]
	add rcx,[pointer_to_addr_func]
	xor rax,rax
	mov eax,dword ptr [rcx] 		;rva func
	add rax,[pointer_to_base_addr]
	jmp QUIT
NEXT_FUNC:
	add qword ptr[rbp-24],4
	add qword ptr[rbp-32],2
	sub qword ptr[rbp-16],1
	jmp L1

QUIT_FAIL:
	mov rax,0
QUIT:	
	leave
	ret
Find_Function_Addr endp


Compare proc
	push rbp
	mov rbp,rsp
	sub rsp,24
	mov [rbp-8],rcx
	mov [rbp-16],rdx
	mov qword ptr[rbp-24],0 	;len
	mov rsi,[rbp-8]
L1:
	cmp byte ptr[rsi],0
	jz NEXT_LEN

	add qword ptr[rbp-24],1
	add rsi,1
	jmp L1
NEXT_LEN:	
	mov rsi,[rbp-16]
	mov rax,0
L2:
	cmp byte ptr[rsi],0
	jz END_LEN

	add rax,1
	add rsi,1
	jmp L2
END_LEN:
	mov rbx,qword ptr[rbp-24]
	mov rax,rbx
	jz 	CMP_ONEBYONE
	
OUT_:	
	mov rax,-1
	jmp QUIT
CMP_ONEBYONE:
	mov rcx,[rbp-24]
	mov rsi,[rbp-8]
	mov rdi,[rbp-16]
L3:	
	cmp rcx,1
	jb OK
	mov al,byte ptr [rsi]
	mov ah,byte ptr [rdi]
	cmp al,ah
	jnz	OUT_
	sub rcx,1
	add rsi,1
	add rdi,1
	jmp L3	
OK:
	mov rax,1
QUIT:
	leave
	ret
Compare endp




WriteOut proc
	push rbp
	mov rbp,rsp
	sub rsp,16
	mov [rbp-16],rcx		;	store msg to rbp-16
	mov rcx, -11			; stdout
	mov rax,qword ptr[GetStdHandle]
	call rax ;		GetStdHandle(-11) return stdin
	mov [rbp-8], rax		; store handle

	mov rcx, [rbp-16]
	mov rax,qword ptr[lstrlenA]
	call rax
	mov r8, rax
	
	mov rcx, [rbp-8]
	mov rdx, [rbp-16]
	mov r9, 0			;		lpNumberOfBytesWritten 	,	NULL pointer for normal case
	push 0				;		lpOverlapped	set to 0 for normal case
	push 0
	push 0
	push 0
	push 0
	push 0
	push 0
	;mov rax,qword ptr [WriteFile]
	;call rax ;		WriteFile(handle, msg, len,0,0)
	call WriteFile
	leave
	ret
WriteOut endp




END




