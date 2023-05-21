! inicijalizacija simulacije
onkp false, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
dmareg 1, r0, x.a
dmareg 1, r1, x.b
dmareg 1, r2, x.c
dmareg 1, r3, x.d
dmareg 1, r4, x.e
dmareg 1, r5, x.f
dmareg 1, r6, x.10
dmareg 1, r7, x.11
dmareg 1, r8, x.12
dmareg 1, r9, x.13
reg pc, x.1000
reg ivtp, x.0
dc x.2000, x.1
dc x.2100, x.2
dmareg 1, interrupt, x.1
dmareg 2, interrupt, x.2
! kraj inicijalizacije

! resenje
! glavni program
org x.1000
! inicijalizacija DMA1.1
ldimm x.a, r0		! koliko podataka treba preneti u r0
stmem x.f004, r0		! upis u count registar DMA1.1
ldimm x.3000, r0		! adresa od koje se smestaju podaci u memoriju
stmem x.f006, r0		! upis u destinacioni adresni registar AR2 DMA1.1
clr r0			! pocetna vrednost semafora nula
stmem x.4000, r0		! odabrana slobodna lokacija x.4000 da cuva vrednost semafora
				! moze se koristiti i neki registar da se cuva vrednost semafora
ldimm x.8f, r0		! vrednost za startovanje DMA1.1 kontrolera
stmem x.f000, r0		! upis vrednosti u kontrolni registar DMA1.1

! ceka se da DMA1.1 zavrsi slanje
ldimm x.1, r1		! jedinica za testiranje semafora
wait1: ldmem x.4000, r0	! cita se vrednost semafora
cmp r1, r0			! da li je semafor postao jedan
bneq wait1			! ako nije nazad na wait1

! inicijalizacija DMA1.2
ldimm x.a, r0		! koliko podataka treba preneti u r0
stmem x.f044, r0		! upis u count registar DMA1.2
ldimm x.3000, r0		! adresa od koje DMA1.2 cita iz memorije podatke
stmem x.f045, r0		! upis u izvorisni adresni registar AR1 DMA1.2
clr r0			! pocetna vrednost semafora nula
stmem x.4000, r0		! odabrana slobodna lokacija x.4000 da cuva vrednost semafora, 
				! nema veze sto je ista kao za DMA1.1 posto DMA1.1 je sada iskljucen
				! moze se koristiti i neki registar da se cuva vrednost semafora
ldimm x.0e, r0		! vrednost za startovanje DMA1.2 kontrolera
stmem x.f040, r0		! upis vrednosti u kontrolni registar DMA1.2

! ceka se da DMA1.2 zavrsi slanje
ldimm x.1, r1		! jedinica za testiranje semafora
wait2: ldmem x.4000, r0	! cita se vrednost semafora
cmp r1, r0			! da li je semafor postao jedan
bneq wait2			! ako nije nazad na wait2


halt				! kraj programa

! prekidna rutina DMA1.1
org x.2000
push r0			! koristi se r0 pa se njegova vrednost cuva na steku
ldimm x.1, r0		! jedinica za semafor
stmem x.4000, r0		! postavljanje semafora
clr r0			! nula za kontrolni registar DMA za iskljucivanje
stmem x.f000, r0		! upis u kontrolni registar
pop r0			! vracanje stare vrednosti r0
rti				! povratak iz prekidne rutine

! prekidna rutina DMA1.2
org x.2100
push r0			! koristi se r0 pa se njegova vrednost cuva na steku
ldimm x.1, r0		! jedinica za semafor
stmem x.4000, r0		! postavljanje semafora
clr r0			! nula za kontrolni registar DMA za iskljucivanje
stmem x.f040, r0		! upis u kontrolni registar
pop r0			! vracanje stare vrednosti r0
rti				! povratak iz prekidne rutine


