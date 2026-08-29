---

## (a) Enostranski opis obsega

### Problem

Pri upravljanju infrastrukture za več okolij je konfiguracijo mogoče organizirati na različne načine. Pristopi se razlikujejo glede podvajanja kode, izolacije stanja, propagacije sprememb, zahtevnosti dodajanja okolij in operativnega tveganja. Obstoječe primerjave so pogosto opisne, pristranske, vezane na posamezna orodja ali brez ponovljive metodologije.

### Namen

Zasnovati **ponovljiv merilni okvir** in ga aplicirati na tri pristope:

1. **Terraform workspaces** — en korenski modul, ločitev prek workspace + var-files
2. **Terragrunt** — DRY layout z `include` / `dependency`, ločen state na modul × deployment enoto
3. **OpenTofu** — ločeni rooti po deployment enoti, zgodnje vrednotenje lokalov/spremenljivk, brez Terragrunta

Poudarek: merljive lastnosti **organizacije konfiguracije**, ne vzpostavitev produkcijske infrastrukture.

### Raziskovalno vprašanje

> Kako izbira pristopa za organizacijo večokoljske IaC-konfiguracije vpliva na podvajanje konfiguracije, obseg sprememb, izolacijo stanja in zahtevnost upravljanja okolij?

### Metoda (na kratko)

- isti referenčni scenarij v vseh treh pristopih (skupni moduli, enake vhodne vrednosti),
- metrike in pravila štetja definirana **vnaprej**,
- katalog standardiziranih sprememb; vsaka meritev iz istega baseline commit-a,
- avtomatizacija: Git diff, štetje datotek/vrstic, število prizadetih deployment enot, `plan`, meje state-a.

### Pričakovani rezultat

Merilni harness, tri primerljive implementacije, reproducibilni rezultati, primerjalna analiza in **odločitveni vodnik** (niansiran, ne absolutni zmagovalec).

---

## (b) Referenčni scenarij

### Okolja in regije

| Okolje  | Regije                                                           |
| ------- | ---------------------------------------------------------------- |
| `dev`   | `eu-central-1` (EU)                                              |
| `stage` | `eu-central-1` (EU)                                              |
| `prod`  | `eu-central-1` (EU), `us-east-1` (USA), `ap-southeast-1` (Azija) |

Skupaj **5 deployment enot**:

- `dev/eu-central-1`
- `stage/eu-central-1`
- `prod/eu-central-1`
- `prod/us-east-1`
- `prod/ap-southeast-1`

### Logični moduli (skupni za vse pristope)

> **Osnutek.** Nabor modulov in natančna sestava virov se lahko med izvedbo še prilagodi; spodnje je delovni predlog za pošteno primerjavo pristopov.

| Modul         | Vsebina (AWS)                                                                                    |
| ------------- | ------------------------------------------------------------------------------------------------ |
| `network`     | VPC, javne/zasebne podmreže, CIDR po okolju/regiji                                               |
| `edge`        | S3 + Route53; **CloudFront samo v prod**                                                         |
| `application` | EKS cluster + managed node group                                                                 |
| `database`    | **tri** RDS PostgreSQL instance (users, metadata, favorites), usklajeno z arhitekturo aplikacije |
| `monitoring`  | CloudWatch logi + CPU alarm                                                                      |

### Primer parametrov po okoljih

| Parameter                         |   dev |  stage |  prod |
| --------------------------------- | ----: | -----: | ----: |
| Št. vozlišč EKS (`replica_count`) |     1 |      2 |     4 |
| Velikost vozlišč                  | small | medium | large |
| Velikost RDS (vse tri baze)       | small | medium | large |
| HA baz                            |    ne |     ne |    da |
| Retention logov (dni)             |     7 |     30 |    90 |
| CDN (CloudFront)                  |    ne |     ne |    da |

### Način vrednotenja infrastrukture

Razmisljam o uporabi **dejanskega AWS** (ne samo mock/`plan`-only). Izolacija računov je pomemben del izolacije okolij in ohranja scenarij realističen. Stroške nameravam držati nizko tako, da infrastruktura **ne bo dolgo vklopljena** — `apply` za preverjanje / meritve, nato hitro uničenje. Glavni poudarek diplome ostaja merjenje organizacije konfiguracije (diff, state meje, število prizadetih enot), ne dolgotrajno obratovanje.

### Trije pristopi (poštena primerjava)

| Pristop              | Organizacija                                            | State                                                                                      |
| -------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Terraform workspaces | En root + workspace + tfvars na enoto                   | 1 state na workspace (= 1 na deployment enoto)                                             |
| Terragrunt           | Direktorij na modul × enoto, `_envcommon`, `dependency` | 1 state na **modul na deployment enoto** (npr. `prod/eu-central-1/network` ima svoj state) |
| OpenTofu             | Root na enoto, shared locals z zgodnjim vrednotenjem    | 1 state na deployment enoto (vsi moduli skupaj)                                            |

Vsi uporabljajo **iste module** in **iste vhodne vrednosti**.

---

## (c) Predlagane metrike in katalog sprememb

### Metrike (definirane vnaprej)

**A. Podvajanje / DRY**

Meri:

- skupno št. relevantnih vrstic,
- delež deljenih in okoljsko/regijsko specifičnih vrstic,
- delež podvojenih vrstic ali blokov.

Izloči komentarje, prazne vrstice, lock/state datoteke in generirano vsebino.

**B. Change amplification**

Za vsako spremembo meri:

- št. spremenjenih datotek in vrstic,
- št. mest, kjer je treba spremembo zapisati,
- št. plan/apply enot,
- št. uporabniških ukazov.

**C. Izolacija state-a / blast radius**

Meri:

- št. state datotek,
- največje št. virov v enem state-u,
- največje št. okolij, regij in modulov, ki jih lahko prizadene en napačen apply.

Število state-ov je opisna metrika: več state-ov pomeni boljšo izolacijo, vendar tudi več koordinacije.

**D. Dodajanje okolja ali regije**

Meri:

- nove/spremenjene datoteke in vrstice,
- ročne korake,
- nove state/backend enote,
- št. ukazov in plan/apply enot.

Čas naj bo samo dopolnilna metrika.

**E. Kognitivna kompleksnost**

Namesto zgolj »kompleksnosti orodne verige« meri:

- št. orodij in formatov,
- št. ključnih konceptov,
- št. korakov in ukazov za osnovne operacije ter dodajanje okolja.

### Katalog tipičnih sprememb (osnutek)

1. Povečaj velikost aplikacije / vozlišč **samo v prod**
2. Spremeni nastavitev **samo za eno regijo** (npr. `us-east-1`)
3. Spremeni deljeno privzeto vrednost v IaC (npr. privzeta oznaka / skupni lokal), ki se propagira čez enote
4. Sprememba skupnega modula (npr. obvezna oznaka na vseh virih)
5. Dodaj okolje `test`
6. Dodaj novo regijo v prod (npr. dodatna azijska regija)
7. Produkcijska izjema (npr. HA ali CDN samo v prod)
8. Strukturna sprememba (npr. nova zmožnost monitoringa)

Vsaka sprememba se izvede iz istega baseline-a ločeno (ne kumulativno), da so meritve primerljive.

---

## (d) Terraform Stacks — predlog vključitve + vprašanje

Terraform Stacks so HashiCorpov novejši model za večkratno nameščanje iste komponente čez okolja/regije (`*.tfcomponent.hcl` + `*.tfdeploy.hcl`). Tematsko se zelo ujemajo z raziskovalnim vprašanjem (organizacija multi-environment konfiguracije in propagacija sprememb).

**Želel bi jih vključiti v primerjavo zaradi popolnosti in relevantnosti**, vsaj kot četrti pristop z jasnimi metodološkimi zadržki — ne kot tiho enakovreden OSS CLI layout.

### Skrb: vezava na HCP Terraform

Ključna omejitev: Stacka **ni mogoče planirati/applyati lokalno**. Lokalno so na voljo predvsem `terraform stacks init` / `validate` / `fmt`; deployment plan teče v **HCP Terraform**.

Možnosti, ki jih vidim:

1. ustvariti HCP račun in za Stacks meriti tudi oddaljene plane (npr. izvoz / pregled plana iz HCP),
2. Stacks meriti predvsem prek **statične analize konfiguracije** (diff, štetje, struktura deploymentov), HCP plan pa le kot dopolnilni / opcijski korak.

Nagibam se k **vključitvi Stacks v primerjavo**, z eksplicitno tabelo, katere metrike so offline reproducibilne in katere zahtevajo HCP.

V repozitoriju že imam začetno skico: `implementations/terraform-stacks/` (isti moduli; deploymenti se bodo uskladili s 5 enotami scenarija).

### Kaj od metrik je (ne)reproducibilno za Stacks

| Metrika                                                      | Offline / lokalno | Potrebuje HCP       | Opomba                                                                     |
| ------------------------------------------------------------ | ----------------- | ------------------- | -------------------------------------------------------------------------- |
| **A. DRY (D1–D4)**                                           | da                | ne                  | Štetje `*.tfcomponent.hcl` / `*.tfdeploy.hcl` + deljeni moduli             |
| **B. CA1 / CA2** (datoteke, vrstice)                         | da                | ne                  | Git diff ob katalogu sprememb                                              |
| **B. CA3** (mesta zapisa)                                    | da                | ne                  | Iz strukture `deployment` blokov / kateri inputi se spremenijo             |
| **B. CA4 / CA5** (plan/apply enote, ukazi)                   | delno             | da (za realen plan) | Offline lahko _ocenimo_ št. deployment planov; dejanski plan samo v HCP    |
| **C. BR1** (št. state-ov)                                    | delno             | da (za preverbo)    | Model: 1 state / deployment; lokalno state ni na disku                     |
| **C. BR2** (max virov v state-u)                             | ne                | da                  | Brez HCP plana / state listinga                                            |
| **C. BR3–BR5** (max okolij/regij/modulov pri napačnem apply) | da (konceptualno) | opcijsko            | Iz modela Stacks; empirično potrdilo prek HCP                              |
| **D. AE\*** (dodajanje okolja/regije)                        | večinoma da       | delno               | Nova `deployment` enota merljiva; nove state/backend in HCP koraki dodatno |
| **E. Kognitivna kompleksnost (CC\*)**                        | da                | ne                  | Vključuje HCP kot dodatno orodje/koncept — del rezultata                   |

**Predlagani pristop k merjenju:** Stacks vključim kot četrti pristop; metrike A, CA1–CA3, AE (konfiguracijski del), E in konceptualni BR3–BR5 merim enako kot pri OSS pristopih; CA4/CA5 in BR2 označim kot _HCP-odvisne_ (ali jih izvedem prek HCP računa in to jasno dokumentiram kot omejitev reproducibilnosti).

### Vprašanje

Ali se strinjate, da Terraform Stacks vključim v primerjavo kot **četrti pristop z zgoraj navedenimi omejitvami**, ali raje:

- jih obravnavam le v razdelku _related work_ / razprava, ali
- jih vključim polno (vključno z HCP plani kot obveznim delom meritev)?

---
