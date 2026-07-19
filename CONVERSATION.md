Najvarnejša pot je, da mentorju najprej potrdiš **Opcijo 1**, nato pa pripraviš tri zahtevane elemente. Spodaj imaš osnutek odgovora in že skoraj pripravljen delovni predlog.

## 1. Osnutek odgovora mentorju

**Zadeva: Izbira usmeritve diplomske naloge – Opcija 1**

Pozdravljeni,

hvala za podrobne povratne informacije in predlagane usmeritve.

Po pregledu vseh treh možnosti bi izbral **Opcijo 1: Merilni okvir za organizacijo multi-environment IaC**. Ta možnost mi je najbližja, ker ohranja prvotno področje Terraform/OpenTofu in Terragrunt, hkrati pa raziskovalni prispevek premakne od postavljanja infrastrukture k zasnovi ponovljive metodologije in merljivemu vrednotenju različnih pristopov.

Bolj se vidim v analitično-metodološki vlogi kot v razvoju samostojnega orodja za analizo HCL oziroma grafov odvisnosti. V okviru naloge bi zato pripravil enoten referenčni scenarij, ga primerljivo implementiral s tremi pristopi in nato s skriptami izvedel vnaprej določen nabor sprememb ter izmeril podvajanje konfiguracije, change amplification, izolacijo stanja oziroma blast radius in zahtevnost dodajanja novega okolja.

Realna večregijska infrastruktura ne bi bila potrebna. Vrednotenje bi temeljilo predvsem na statični analizi, izhodih `plan` in avtomatiziranih meritvah. Po potrebi bi za preverjanje uporabil lokalno oziroma simulirano okolje.

Do naslednjega srečanja bom pripravil:

1. enostranski opis obsega,
2. podroben referenčni scenarij,
3. operacionaliziran seznam metrik in sprememb za vrednotenje.

Lep pozdrav,
Marko

---

# 2. Enostranski opis obsega

## Delovni naslov

**Merilni okvir za vrednotenje organizacije konfiguracije v večokoljskih rešitvah Infrastructure as Code**

Alternativno, bolj konkretno:

**Primerjalno vrednotenje organizacije večokoljske IaC-konfiguracije s Terraform workspaces, Terragruntom in OpenTofujem**

## Problem

Pri upravljanju infrastrukture za več okolij je mogoče konfiguracijo organizirati na različne načine. Pristopi se razlikujejo glede podvajanja kode, izolacije stanja, propagacije sprememb, zahtevnosti dodajanja okolij in operativnega tveganja. Obstoječe primerjave so pogosto opisne, vezane na posamezna orodja ali brez ponovljive metodologije.

## Namen naloge

Namen naloge je zasnovati **ponovljiv merilni okvir** za vrednotenje organizacije večokoljske IaC-konfiguracije ter ga uporabiti na treh pristopih:

1. Terraform workspaces,
2. Terragrunt,
3. OpenTofu z uporabo mehanizmov za konfiguracijo in zgodnje vrednotenje spremenljivk.

Poudarek ne bo na vzpostavitvi produkcijske infrastrukture, temveč na merljivih lastnostih konfiguracijske strukture in propagaciji sprememb.

## Raziskovalno vprašanje

> Kako izbira pristopa za organizacijo večokoljske IaC-konfiguracije vpliva na podvajanje konfiguracije, obseg sprememb, izolacijo stanja in zahtevnost upravljanja okolij?

Podvprašanja:

- Kateri pristop zahteva najmanj podvajanja konfiguracije?
- Kako se med pristopi razlikuje change amplification pri tipičnih spremembah?
- Kako organizacija state-a vpliva na potencialni blast radius?
- Koliko korakov in novih konfiguracij je potrebnih za dodajanje okolja ali regije?
- V katerih okoliščinah je posamezen pristop najprimernejši?

## Metoda

Definiran bo en referenčni infrastrukturni scenarij, implementiran funkcionalno enakovredno v vseh treh pristopih. Pred izvedbo bodo določeni:

- kriteriji in metrike,
- pravila štetja,
- katalog tipičnih sprememb,
- postopek izvedbe eksperimentov.

Meritve bodo avtomatizirane s skriptami. Za vsako spremembo bo scenarij ponastavljen na enako začetno stanje, izvedena bo sprememba, nato pa bodo analizirani:

- Git diff,
- število spremenjenih datotek in vrstic,
- število prizadetih konfiguracijskih oziroma deployment enot,
- rezultati `plan`,
- meje state-a in število potencialno prizadetih virov.

## Pričakovani rezultat

Rezultat naloge bo:

- ponovljiv merilni okvir,
- tri primerljive implementacije,
- katalog standardiziranih sprememb,
- avtomatizirani rezultati meritev,
- primerjalna analiza,
- odločitveni vodnik za izbiro pristopa glede na značilnosti projekta.

Argo CD, Vault in realni EKS ne bodo del kritične poti. Po potrebi se lahko uporabi lokalno ali simulirano okolje za preverjanje izvedljivosti konfiguracij.

---

# 3. Predlog referenčnega scenarija

Priporočam dovolj kompleksen scenarij, da pokaže razlike, vendar brez EKS-a.

## Okolja in regije

- okolja: `dev`, `stage`, `prod`
- regiji: `eu-central-1`, `eu-west-1`

To pomeni največ šest deployment enot:

- `dev/eu-central-1`
- `dev/eu-west-1`
- `stage/eu-central-1`
- `stage/eu-west-1`
- `prod/eu-central-1`
- `prod/eu-west-1`

Če želiš zmanjšati obseg, lahko določiš:

- `dev` in `stage`: ena regija,
- `prod`: dve regiji.

Vendar je popolna matrika \(3 \times 2\) metodološko čistejša in pri uporabi samo `plan` še vedno obvladljiva.

## Logični moduli

Vsaka deployment enota naj vsebuje tri ali štiri module:

1. **Network**
   - omrežje,
   - javni in zasebni segmenti,
   - okoljsko in regijsko odvisni CIDR-i.

2. **Application**
   - aplikacijska storitev,
   - velikost oziroma kapaciteta,
   - število replik,
   - različica aplikacije.

3. **Database**
   - velikost instance,
   - količina prostora,
   - nastavitev visoke razpoložljivosti,
   - varnostno kopiranje.

4. **Monitoring**
   - hramba dnevnikov,
   - alarmi,
   - okoljsko odvisne mejne vrednosti.

Ni nujno, da so to dejanski AWS viri. Možnosti so:

- mock ponudnik oziroma testni mehanizmi,
- `terraform_data` za modeliranje virov,
- LocalStack,
- pravi AWS provider samo za izdelavo plana, kjer je to izvedljivo.

Najpreprostejši in najbolj reproducibilen pristop je modeliranje referenčnih virov brez dejanskega `apply`. Pomembno je, da vse tri implementacije uporabljajo iste module in enake vhodne vrednosti.

## Primer razlik med okolji

| Parameter              |   dev |  stage |   prod |
| ---------------------- | ----: | -----: | -----: |
| Replike aplikacije     |     1 |      2 |      4 |
| Velikost aplikacije    | small | medium |  large |
| Velikost baze          | small | medium |  large |
| Hramba dnevnikov       | 7 dni | 30 dni | 90 dni |
| Visoka razpoložljivost |    ne |     ne |     da |
| Backup retention       | 1 dan |  7 dni | 30 dni |

Tako boš imel:

- deljene privzete vrednosti,
- okoljske override,
- regijske vrednosti,
- produkcijske izjeme.

---

# 4. Predlagane metrike

Ključno je, da za vsako metriko napišeš natančno pravilo merjenja.

## A. Podvajanje konfiguracije

Možne meritve:

- skupno število relevantnih vrstic konfiguracije,
- število deljenih vrstic,
- število okoljsko ali regijsko specifičnih vrstic,
- število podvojenih blokov,
- delež podvajanja.

Primer:

$$
D = \frac{\text{število podvojenih relevantnih vrstic}}
{\text{skupno število relevantnih vrstic}}
$$

Iz štetja izloči:

- prazne vrstice,
- komentarje,
- generirane datoteke,
- lock datoteke,
- dokumentacijo.

Ker je samodejno ugotavljanje semantičnega podvajanja težko, lahko uporabiš kombinacijo:

- orodja za detekcijo podobnih blokov,
- ročne klasifikacije po vnaprej določenih pravilih,
- štetja konfiguracijskih vrednosti, ki se pojavijo na več mestih.

## B. Change amplification

Za vsako standardizirano spremembo meriš:

- število spremenjenih datotek,
- število dodanih, odstranjenih ali spremenjenih vrstic,
- število deployment enot, ki jih je treba ponovno načrtovati,
- število potrebnih ukazov,
- število ločenih plan/apply operacij.

Lahko definiraš sestavljeno metriko, vendar je bolje najprej prikazati posamezne rezultate:

$$
CA_f = \text{število spremenjenih datotek}
$$

$$
CA_l = \text{število spremenjenih vrstic}
$$

$$
CA_d = \text{število prizadetih deployment enot}
$$

## C. Izolacija state-a in blast radius

Meriš:

- število state datotek,
- število okolij v posameznem state-u,
- število regij v posameznem state-u,
- število virov v state-u,
- največje število virov, ki jih lahko prizadene ena napačna operacija,
- ali lahko operacija nad enim okoljem vpliva na drugo okolje.

Predlagana približna metrika:

$$
BR = \max_{s \in S} |R_s|
$$

kjer je \(R_s\) množica virov v posameznem state-u.

Dodatno lahko poročaš:

- **environment isolation:** da/ne,
- **region isolation:** da/ne,
- **module isolation:** da/ne.

## D. Zahtevnost dodajanja novega okolja

Izogni se izrazu »kognitivna kompleksnost«, če ne boš izvajal uporabniške študije. Bolje je uporabiti **operativna in konfiguracijska zahtevnost**.

Meriš:

- število novih datotek,
- število spremenjenih obstoječih datotek,
- število novih vrstic,
- število ročnih korakov,
- število ukazov,
- število konceptov, specifičnih za uporabljeno orodje,
- čas izvedbe, če lahko postopek dovolj strogo nadzoruješ.

Čas ene osebe je šibkejša metrika, zato naj bo dopolnilna, ne glavna.

## E. Kompleksnost orodne verige

Meriš:

- število potrebnih orodij,
- število konfiguracijskih jezikov oziroma formatov,
- število različnih ukazov,
- dodatne odvisnosti,
- količino pristopu specifične konfiguracije,
- število konceptov, potrebnih za osnovne operacije.

---

# 5. Katalog standardiziranih sprememb

Pripravi približno 8 sprememb. Za vse pristope morajo biti izvedene iz iste začetne različice.

1. **Sprememba samo v enem okolju**
   Povečaj velikost aplikacije samo v `prod`.

2. **Sprememba v eni regiji**
   Spremeni nastavitev samo za `eu-west-1`.

3. **Globalna sprememba**
   Spremeni privzeto različico aplikacije v vseh okoljih.

4. **Sprememba skupnega modula**
   Dodaj obvezno oznako oziroma parameter vsem virom.

5. **Dodajanje novega okolja**
   Dodaj okolje `test`.

6. **Dodajanje nove regije**
   Dodaj `eu-north-1`.

7. **Produkcijska izjema**
   Omogoči visoko razpoložljivost samo v `prod`.

8. **Sprememba strukture**
   Dodaj nov modul za monitoring vsem okoljem.

Za vsako spremembo ustvari ločen Git commit ali vejo. Skripta lahko nato primerja začetni in končni commit.

---

# 6. Kako zagotoviti pošteno primerjavo

Pred implementacijo napiši pravila:

- vsi pristopi uporabljajo enake logične module,
- vsi proizvedejo enak končni nabor logičnih virov,
- vhodne vrednosti so enake,
- imenovanje virov je enako,
- meje deployment enot so vnaprej določene,
- različice orodij so fiksirane,
- meritve izvaja ista skripta,
- spremembe se izvajajo v enakem vrstnem redu,
- vsaka meritev se začne iz istega Git commita,
- generirane datoteke se ne štejejo kot ročno vzdrževana konfiguracija, vendar se poročajo ločeno.

Zelo pomembno: ne prilagajaj vsake implementacije tako, da umetno favorizira njene prednosti. Vnaprej določi, kaj pomeni »idiomatska, vendar funkcionalno enakovredna implementacija«.

---

# 7. Predlagana struktura repozitorija

```text
thesis-iac-comparison/
├── README.md
├── methodology/
│   ├── metrics.md
│   ├── counting-rules.md
│   ├── change-catalog.md
│   └── reference-scenario.md
├── modules/
│   ├── network/
│   ├── application/
│   ├── database/
│   └── monitoring/
├── implementations/
│   ├── terraform-workspaces/
│   ├── terragrunt/
│   └── opentofu/
├── experiments/
│   ├── change-01-prod-size/
│   ├── change-02-region-setting/
│   └── ...
├── scripts/
│   ├── validate.sh
│   ├── plan.sh
│   ├── measure-diff.py
│   └── generate-report.py
└── results/
    ├── raw/
    └── reports/
```

---

# 8. Naslednji konkretni koraki

1. Mentorju pošlji odgovor z izbiro Opcije 1.
2. Potrdi natančno definicijo treh primerjanih pristopov.
3. Dokončno določi scenarij: priporočam 3 okolja, 2 regiji in 4 module.
4. Napiši `counting-rules.md`, še preden začneš implementacijo.
5. Izberi 6–8 standardiziranih sprememb.
6. Izdelaj minimalen prototip vsakega pristopa samo za en modul.
7. Preveri, ali lahko za vse tri avtomatizirano izdelaš primerljiv `plan`.
8. Šele nato implementiraj celoten scenarij.
9. Meritve avtomatiziraj; rezultatov ne zbiraj ročno.
10. Iz rezultatov pripravi odločitveni vodnik, ne lestvice absolutnega zmagovalca.

Najpomembnejše vprašanje za naslednje srečanje z mentorjem je, **kaj natančno šteje kot vsak od treh pristopov**. To mora biti jasno opredeljeno, ker Terraform workspaces rešujejo predvsem izbiro state-a, medtem ko Terragrunt in OpenTofu lahko vplivata tudi na strukturo konfiguracije. Če tega ne omejiš vnaprej, primerjava ne bo povsem poštena.
