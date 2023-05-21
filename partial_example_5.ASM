! inicijalizacija simulacije
dc x.4000, x.2000
dc x.2, x.2001
dc x.2100, x.2002
dc x.5000, x.2100
dc x.3, x.2101
dc x.2200, x.2102
dc x.6000, x.2200
dc x.4, x.2201
dc x.0, x.2202
ondma x.1, x.1
dmareg 1, r0, x.a
dmareg 1, r1, x.b
dmareg 1, r2, x.c
dmareg 1, r3, x.d
dmareg 1, interrupt, x.1
reg pc, x.1000
reg ivtp, x.0
dc x.3000, x.1
! kraj inicijalizacije

! resenje
! glavni program
org x.1000
! inicijalizacija DMA1.1
ldimm x.2000, r0		! adresa prve strukture u r0
loop:ldrid [r0]x.0, r1		! u r1 adresa od koje treba smestati podatke u memoriju, polje address se nalazi na adresi r0+0h
stmem x.f006, r1		! uspis u destinacioni adresni registar AR2 DMA
ldrid [r0]x.1, r1		! sledece polje strukture (size) se nalazi na adresi r0+1h
				! koja se dobija sabiranje r0 i pomeraja 1h
				! u r1 se ucitava broj koliko treba podataka preneti
stmem x.f004, r1		! upis u count registar DMA
clr r2			! pocetna vrednost semafora nula, koristi se r2 registar kao semafor
ldimm x.8f, r1		! vrednost za startovanje DMA kontrolera
stmem x.f000, r1		! upis vrednosti u kontrolni registar DMA

! ceka se da DMA zavrsi obradu jednog zahteva
ldimm x.1, r1		! jedinica za testiranje semafora
wait: cmp r1, r2		! da li je semafor postao jedan, da li je u r2 upisana jedinica
bneq wait			! ako nije nazad na wait

! prelazi se na sledeci zahtev
ldrid [r0]x.2, r0		! u r0 se smesta vrednost next polja, adresa polja next se dobija kao r0+2h
				! jer se u r0 nalazi adresa upravo obradjenog zahteva
clr r1			! u r1 nula
cmp r1, r0			! da li je r0 nula, to znaci da je polje next jednako nuli i da nema vise zahteva
bneq loop			! ako nije nula prelazi se na obradu sledeceg zahteva


halt				! kraj programa

! prekidna rutina DMA
org x.3000
push r0			! koristi se r0 pa se njegova vrednost cuva na steku
ldimm x.1, r2		! u r2 ide jedinica, postavlja se semafor
clr r0			! nula za kontrolni registar DMA za iskljucivanje
stmem x.f000, r0		! upis u kontrolni registar
pop r0			! vracanje stare vrednosti r0
rti				! povratak iz prekidne rutine


