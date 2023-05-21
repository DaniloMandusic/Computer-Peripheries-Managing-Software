! inicijalizacija simulacije
dc x.1, x.9996
dc x.0, x.9998
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.1, r5, x.6
kpreg 1.1, r6, x.7
kpreg 1.1, r7, x.8
kpreg 2.1, r0, x.9
kpreg 2.1, r1, x.a
kpreg 2.1, r2, x.b
kpreg 2.1, r3, x.c
kpreg 2.1, r4, x.d
kpreg 2.1, r5, x.e
kpreg 2.1, r6, x.f
kpreg 2.1, r7, x.10
reg pc, x.4000
reg ivtp, x.4000
reg sp, x.9000
! kraj inicijalizacije

!main
org x.4000

!ivtp set
ldimm x.300,r0
mvrir r0,ivtp
ldimm x.2000,r0
stmem x.300,r0
ldimm x.1500,r0
stmem x.301,r0
ldimm x.2500,r0
stmem x.302,r0
ldimm x.500,r0
stmem x.303,r0
ldimm x.1000,r0
stmem x.304,r0
ldimm x.3000,r0
stmem x.305,r0
!end ivtp set

!start kp1.1
ldimm x.5000,r4 !pocetak gde da se stavlja niz
ldimm x.9,r5 !broj elementata+1
clr ra !semafor jel primljen niz

ldimm x.3,r3 !broj ulaza u iv za kp1.1
stmem x.f102, r3 !ubacivanje u entry registar

ldimm x.f,r3 !konst za start kp1.1
stmem x.f100,r3 !upis u kontrolni reg kp1.1

ldimm x.1, r3 ! za testiranje semafora
wait: and ra, ra, r3
beql wait
!end kp1.2

!start kp2.1
!sve isto kao i za kp1
ldimm x.6000,r4
ldimm x.9,r5
clr ra

ldimm x.1,r3
stmem x.f202,r3

ldimm x.f,r3
stmem x.f200,r3

ldimm x.1,r3
wait1: and ra,ra,r3
beql wait1
!end kp2.1

!sumAll(*arr1, *arr2, n)
ldimm x.5000,r0
push r0
ldimm x.6000,r0
push r0
ldimm x.8,r0
push r0

jsr sumall
stmem x.9999,r0
!end sum all

!inijalizacija dma1.4
ldimm x.8,r0 !count
stmem x.f0c4,r0 
ldimm x.6100,r0 !adresa na koju podaci idu u mem
stmem x.f0c6,r0
ldimm x.5,r0 !entry bit kontrolera
stmem x.f0c2,r0
clr r5 ! za semafor
stmem x.6050,r5
ldimm x.6000,r0 !adresa sa koje podaci idu
stmem x.f0c5,r0

ldimm x.be,r0 !vrednost za startovanje kontrolera
stmem x.f0c0,r0

ldimm x.1,r1
wait2: ldmem x.6050,r5
cmp r1, r5
bneq wait2
!end inicijalizacija dma 1.4

!inicijalizacija dma 1.2
ldimm x.1, r0 !count
stmem x.f044,r0
ldimm x.2,r0 !entry
stmem x.f042,r0
ldimm x.9999,r0 !izvorisna adresa
stmem x.f045,r0
clr r5 !semafor

ldimm x.ae,r0 !vrednost za startovanje kontrolera
stmem x.f040,r0

ldimm x.1234,r2 !debugging
ldimm x.1,r1
wait3:cmp r1, r5
bneq wait3
!end inicijalizacija dma 1.2

!inicijalizacija kp1.2 *******************************************
ldimm x.5000, r0		! pokazivac na niz
ldimm x.9, r1		! brojac + 1, jer se na pocetku pr. rut. radi dekrementiranje
clr r2			! r2 semafor
ldimm x.4, r3		! r3 broj ulaza za KP2
stmem x.f142, r3		! slanje broja KP2 u entry registar
ldimm x.e, r3		! vrednost za pokretanje KP2
stmem x.f140, r3		! upis u kontrolni registar KP2

ldimm x.1, r3		! za testiranje semafora
wait12:	and r2, r2, r3
	beql wait12		! ako je r2 nula jos uvek prenos nije zavrsen
!end inicijalizacija kp1.2 ****************************************
ldimm x.5555,r9 !debugging

halt
!end main

!sumAll
sumall:
mvrpl r4, sp ! u r4 sp, na steku imamo sada
! r4, retPC, array i size

ldrid [r4]x.1, r3 
ldrid [r4]x.3, r2 
ldrid [r4]x.2, r1

clr r4
clr r0
loop:
cmp r4,r3
beql kraj
dec r3
ldrid [r2]x.0,r5
add r0,r0,r5
ldrid [r1]x.0,r5
add r0,r0,r5
inc r2
inc r1
jmp loop

kraj:
rts
!end sumAll

!dma1.4 prekidna rutina
org x.3000
!push r0
ldimm x.1,r5 !1 za semafor
stmem x.6050,r5
clr r0 !0 za iskljucivanje dma
stmem x.f0c0,r0
!pop r0
rti
!end dma 1.4 prekidna rutina

!dma1.2 prekidna rutina
org x.2500
!push r0
ldimm x.1,r5 !1 za semafor
!stmem x.6050,r5
clr r0 !0 za iskljucivanje dma
stmem x.f0c0,r0
!pop r0
rti
!end dma 1.2 prekidna rutina

! prekidna rutina KP1.2 -----------------------------------------------
org x.1000
dec r1		! smanjivanje brojaca
bneq prenos12
stmem x.f140, r1	! iskljucivanje periferike KP2, svi podaci poslati
ldimm x.1, r2	! postavljanje semafora da je sve poslato
jmp back12
prenos12:
ldrid [r0]x.0, r4 ! element niza u r4
stmem x.f143, r4	! upisavanje elementa u data registar KP2
inc r0		! povecavanje pokazivaca
back12:
rti ! izlazak iz pr. rut
!end prekidna rutina KP1.2 -----------------------------------------------

!prekidna rutina kp1.1
org x.500
dec r5 !smanjivanje brojaca
bneq prenos
stmem x.f100, r5
ldimm x.1, ra
jmp back

prenos:
ldmem x.f103, rb
stri [r4],rb
inc r4
back:
rti
!end prekidna rutina kp1.1

!prekidna rutina kp2.1
org x.1500
dec r5 !smanjivanje brojaca
bneq prenos1
stmem x.f200, r5
ldimm x.1, ra
jmp back1

prenos1:
ldmem x.f203, rb
stri [r4],rb
inc r4
back1:
rti
!end prekidna rutina kp2.1






! ucitavanje sa KP1
!ldimm x.1000, r0 ! r0 pokazivac gde treba smestiti ucitan podatak
!ldimm x.a, r1 ! r1 brojac koliko je jos podataka preostalo
!ldimm x.5, r3
!stmem x.f100, r3 ! upisivanje vrednosti 5h u kontrolni registar KP1
! ispitivanje biti spremnosti
!ldimm x.1, r3 ! maska za proveru bita spremnosti
!loop: ldmem x.f101, r4 ! citanje statusnog registra KP1
!and r4, r4, r3 ! provera statusnog bita
!beql loop ! ako je rezultat prethodne and instrukcije 0,
! znaci da bit spremnosti nije postavljen
! i ponovo se ispituje
! bit spremnosti je postavljen
!ldmem x.f103, r5 ! u r5 se prebacuje podatak sa periferije KP1
!stri [r0], r5 ! smesta primljeni podatak u memoriju
!inc r0 ! povecava se pokazivac
!dec r1 ! povecava se brojac
!bneq loop ! ako nije stigao do nule
! ima jos podataka za slanje
! iskljucivanje KP1
!clr r0
!stmem x.f100, r1







