! inicijalizacija simulacije
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.2, r0, x.6
kpreg 1.2, r1, x.7
kpreg 1.2, r2, x.8
kpreg 1.2, r3, x.9
kpreg 1.2, r4, x.a
reg pc, x.1000
reg sp, x.500
! kraj inicijalizacije

! resenje
! glavni program
org x.1000

! postavljanje IV tabele
clr r0
mvrir r0, ivtp 		! ivtp = 0
ldimm x.2000, r0
stmem x.2, r0 		! postavljanje vrednosti 2000h u ulaz 1 IV tabele

! pokretanje KP1.1
ldimm x.100, r0 		! r0 pokazivac gde treba smestiti niz A
ldimm x.5, r1		! r1 brojac koliko je jos elemenata niza A preostalo
ldimm x.5, r3
stmem x.f100, r3 		! upisivanje vrednosti 5h u kontrolni registar KP1.1

! porketanje KP1.2
ldimm x.2, r3		! broj ulaza u IV za KP1.2
stmem x.f142, r3		! upisivanje broja ulaza u entry registar KP1.2
ldimm x.200, r4		! r4 pokazivac gde treba smestiti niz B
ldimm x.6, r5		! r5 broj + 1 koliko je jos elemenata niza B preostalo
ldimm x.f, r3		! vrednost za starovanje KP1.2
clr ra			! semafor 
stmem x.f140, r3		! upis u kontrolni registar KP1.2

! ispitivanje biti spremnosti KP1.1
ldimm x.1, r3 		! maska za proveru bita spremnosti
loop: ldmem x.f101, rc 		! citanje statusnog registra KP1
      and rc, rc, r3 		! provera statusnog bita
	beql loop			! ako je rezultat prethodne and instrukcije 0, znaci da bit spremnosti nije postavljen i ponovo se ispituje
! bit spremnosti je postavljen
	ldmem x.f103, r7		! u r7 se prebacuje podatak sa periferije KP1
	stri [r0], r7		! smesta primljeni podatak u memoriju
	inc r0			! povecava se pokazivac
	dec r1			! smanjuje se brojac
	bneq loop			! ako nije stigao do nule ima jos podataka za slanje
! iskljucivanje KP1
clr r0
stmem x.f100, r0

! cekanje da se sigurno primi niz B
ldimm x.1, r3		! za testiranje semafora
wait:	and ra, ra, r3
	beql wait

jsr saberi

! pokretanje KP2
ldimm x.300, r0 		! r0 pokazivac gde se nalazi niz C
ldimm x.5, r1		! r1 brojac koliko je jos elemenata niza C preostalo
ldimm x.4, r3
stmem x.f200, r3 		! upisivanje vrednosti 4h u kontrolni registar KP2

ldimm x.1, r3 		! maska za proveru bita spremnosti
loop2: ldmem x.f201, r4 		! citanje statusnog registra KP1
      and r4, r4, r3 		! provera statusnog bita
	beql loop2			! ako je rezultat prethodne and instrukcije 0, znaci da bit spremnosti nije postavljen i ponovo se ispituje
! bit spremnosti je postavljen
	ldrid [r0]x.0, r7		! u r7 se prebacuje jedan element niza C
	stmem x.f203, r7		! element se prebacuje u data registar KP2
	inc r0			! povecava se pokazivac
	dec r1			! smanjuje se brojac
	bneq loop2			! ako nije stigao do nule ima jos elemenata za slanje
! iskljucivanje KP2
clr r0
stmem x.f200, r0

! kraj glavnog programa
halt

! procedura saberi
saberi:
push r0 		! cuvanje registara koji se menjaju
push r1
push r2
push r3
push r5
push r6
push r7
ldimm x.100, r0
ldimm x.200, r1
ldimm x.300, r2
ldimm x.5, r3

loop3: ldrid [r0]x.0, r5
	 ldrid [r1]x.0, r6
	 add r7, r5, r6
	 stri [r2], r7
       inc r0
	 inc r1
	 inc r2
	 dec r3
	 bneq loop3

! povratak iz potprograma (procedure)
pop r7
pop r6
pop r5
pop r3
pop r2
pop r1
pop r0
rts

! prekidna rutina KP1.2, nalazi u memoriji od adrese 2000h
org x.2000
dec r5		! smanjivanje brojaca
bneq prenos
stmem x.f140, r5	! iskljucivanje periferike KP2, svi podaci poslati
ldimm x.1, ra	! postavljanje semafora da je sve poslato
jmp back
prenos:
ldmem x.f143, rb 	! element niza B u rb
stri [r4], rb	! smestanje elementa niza u memorju
inc r4		! povecavanje pokazivaca
back:
rti ! izlazak iz pr. rut