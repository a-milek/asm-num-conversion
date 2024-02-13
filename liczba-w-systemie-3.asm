_code segment
assume  cs:_code, ds:_data, ss:_stack

start:	mov	ax,_data
	mov	ds,ax
	mov	ax,_stack
	mov	ss,ax
	mov	sp,offset top
        
;=========START========

lea dx, msg1
call wypisz

mov ah,0Ah
mov dx, offset liczba
int 21h      
      
call znajdzKoniec
call naWartosc
mov [init_value], bp

call newLine
lea dx, msg2
call wypisz 

            
mov [base], 10
lea si,[lancuch] ;zaladowanie adresu pod ktorym ma byc zapisywany wynik 
call zamiana          
lea dx,lancuch
call wypisz      
    
call newLine
lea dx, msg3
call wypisz
           
mov bp,[init_value]
mov [base], 2  
lea si,[lancuch]   ;zaladowanie adresu pod ktorym ma byc zapisywany wynik 
call zamiana    
lea dx,lancuch
call wypisz
  

jmp koniec 

;========FUNKCJE========


znajdzKoniec:                   ;ustalenia konca wpisanego lancucha
    mov si,1
    znajdzKoniecPetla:
    cmp liczba[si+1],0dh
	je koniecLiczby	 
	inc si     
	jmp znajdzKoniecPetla
	
	koniecLiczby:	
    ret

naWartosc:                      ;zamiana wprowadzanego lancucha na wartosc
    mov cx,0 
    mov bp, 0d 
    
    naWartoscPetla:
    xor bx,bx
    
    cmp liczba[si],'F'          ;
    ja   call blad              ;
    cmp liczba[si],'A'          ;
    jae [A-F]                   ;
                                ; sprawdzenie zgodnosci wpisanych liczb
    cmp liczba[si],'9'          ; z zakresem 0-9, A-F
    ja  call blad               ;
    cmp liczba[si],'0'          ;
    jae [0-9]                   ;
    call blad                   ;
	
	[A-F]:                      ;wlasciwa zamiana na wartosc
	sub liczba[si],55d	
	jmp suma	
	
	[0-9]:
	sub liczba[si],48d
 
	
	suma:
	mov bl,liczba[si] 
    rol bx, cl
    add cl ,4
    add bp, bx
    
	dec si    
	cmp si,1
	jne naWartoscPetla       
    ret 
    
zamiana:         
    mov [num_counter],0
    jmp warunek         ;while   
    petla:       
        mov ax, bp
        xor dx,dx
        div [base] ;wynik w ax,reszta z dzielenia w dx
        mov bp, ax  
        push dx 
        inc [num_counter] 
                  
    warunek: cmp bp,0     ;warunek do while
             jne petla
        
          
    
    jmp warunek2         ;while  
    petla2:
        pop     dx                 
        add     dl,"0"   
        mov [si],dx        ;zapisywanie skonwertowanej liczby w podanym miejscu
        inc si            
        dec [num_counter]    
                     
    warunek2: mov bx,[num_counter]
              cmp bx,0     
              jne petla2
             
ret                          
    
wypisz_znak:	
    mov ah,02h
	int 21h
	ret    
	                                
wypisz:
	mov ah,09h
	int 21h
	ret

newLine:
	mov ah,02h 
	mov dx,10
	int 21h  
	    
	mov dx,13
	int 21h
	ret	   
	
blad:
	call NewLine
	mov ah,09h
	lea dx, msg_b
	int 21h		    
	
koniec:	
	mov	ah,4ch
	mov	al,0
	int	21h 	
	
_code ends

_data segment
	; your data goes here
	
	msg1 DB "Podaj liczbe w systemie szesnastkowym: $" 
	msg2 DB "Podana liczba w systemie dziesietnym: $" 
	msg3 DB "Podana liczbe w systemie binarnym: $" 
	msg_b db "Znak nie jest cyfra!$" 
	lancuch DB "$$$$$$$$$$$$$$$$$$"
	
	liczba  DB 5
	num_counter DW 0	  
	base DW 0 
	init_value DW 0      
	
	
	
	       
_data ends

_stack segment stack
	dw	100h dup(0)
top	Label word
_stack ends

end start