Pozdravljen Marko,
hvala za dobro pripravljen predlog. Smer (IaC, organizacija konfiguracije za več okolij, OpenTofu/Terragrunt) je smiselna in aktualna, zato jo ohraniva. Predlagam pa preusmeritev poudarka, ker ima predlog v obstoječi obliki neugodno razmerje: veliko rutinskega dela z infrastrukturo (multi-region EKS + ArgoCD + Vault), ki nosi malo raziskovalne teže, in razmeroma tanek raziskovalni del, ki v veliki meri ponovi primerjalno tabelo iz članka, na katerega se sklicuješ. Za diplomo je to tvegano — komisije čisto primerjave orodij pogosto ocenijo kot šibek prispevek.
Ključni premik v razmišljanju je tale: predmet tvoje raziskave je organizacija konfiguracije in propagacija sprememb, NE poganjanje realne cloud infrastrukture. Ko to ločiš, ugotoviš, da za odgovor na raziskovalno vprašanje sploh ne potrebuješ dragega multi-region EKS klastra. Večino lahko narediš z terraform/tofu plan, statično analizo kode in kvečjemu enim majhnim lokalnim klastrom (kind/k3d) ali LocalStackom. S tem odpade približno 80 % rutinskega dela, prispevek pa se premakne z "postavil sem infrastrukturo" na "definiral in izmeril sem". ArgoCD in Vault v vseh spodnjih opcijah postaneta neobvezna priloga za realističnost demonstracije, ne kritična pot.
Spodaj so tri možne oblike teme, urejene po naraščajočem programerskem tveganju. Preberi vse tri in premisli, katera ti je najbližja glede na to, kje se počutiš močnejšega (analiza in metodologija vs. razvoj orodja).
── OPCIJA 1: Merilni okvir za organizacijo multi-environment IaC ── (najbližje tvojemu izvirnemu predlogu, najmanj tveganja)
Obdržiš svojo trojico pristopov — Terraform workspaces, Terragrunt in OpenTofu z zgodnjim vrednotenjem spremenljivk. Razlika je v prispevku: ta ni več "primerjal sem tri orodja", ampak "zasnoval sem ponovljivo metodologijo vrednotenja z merljivimi metrikami in jo apliciral na en fiksen referenčni scenarij". To je bistvena razlika za obranljivost pred komisijo.
Definiraš en referenčni scenarij (npr. ista aplikacija, 3 okolja: dev/stage/prod, opcijsko 2 regiji) in ga implementiraš v vseh treh pristopih. Nato meriš po vnaprej določenih, merljivih metrikah, med drugim:
podvajanje / DRY: delež okoljsko-specifičnih vrstic proti deljenim;
change amplification: za nabor tipičnih sprememb (dvigni velikost instance v prod; dodaj novo okolje; dodaj regijo; zamenjaj deljeno vrednost) izmeriš, koliko datotek/vrstic/apply-enot se moraš dotakniti v vsakem pristopu;
izolacija state-a / blast radius: kaj vse lahko en napačen apply poruši;
kognitivna kompleksnost onboardinga: koliko konceptov, orodij in ukazov mora obvladati nekdo, da doda novo okolje.
Rezultat diplome je merilni "harness", reproducibilne številke in odločitveni vodnik ("glede na velikost ekipe / število okolij / potrebo po deljenju podatkov med moduli izberi pristop X"). Delo z infro je minimalno, večinoma prek plan in statične analize.
── OPCIJA 2: Orodje za analizo change-impact / blast-radius ── (pravi programerski prispevek, praktično brez infre - zelo zanimivo!)
Zgradiš manjše orodje, ki iz plan-a, state-a oz. grafa odvisnosti samodejno izračuna blast radius in change amplification, in ga ovrednotiš na istem scenariju čez vse tri pristope. To je "pravi" računalniški prispevek — parsiranje HCL, gradnja grafa odvisnosti, analiza vpliva sprememb — in je skoraj popolnoma neodvisen od realne infrastrukture.
Prednost: močnejši, izviren prispevek. Slabost: večje programersko tveganje in več dela izven cone udobja. To opcijo priporočam le, če se pri razvoju počutiš samozavestnega; sicer je Opcija 1 varnejša pot do istega cilja.
── OPCIJA 3: Guardrails / policy-as-code čez okolja ── (alternativa, prav tako infra-light)
Raziskovalno vprašanje obrneš: kako organizacija konfiguracije vpliva na uveljavljivost varnostnih/skladnostnih politik in na zaznavo drifta med okolji. Uporabiš policy-as-code orodja (OPA/Conftest, Checkov, tfsec) čez tri pristope in meriš pokritost politik, lažne pozitive in enostavnost vzdrževanja pravil. Sorodna varianta iste ideje je testljivost modulov (tofu test / Terratest) — dokaj podrazvito področje z lepim prostorom za prispevek.
V vseh treh primerih velja isto glede metodologije, kar pričakujem od diplome (in ne od tutoriala):
kriterije/metrike vrednotenja definiraš VNAPREJ, ne za nazaj;
isti referenčni scenarij mora biti implementiran enako v vseh pristopih, da je primerjava poštena;
rezultati morajo biti reproducibilni (skripte, ne ročni koraki);
zaključek bo najverjetneje niansiran ("odvisno od konteksta") — ne pričakuj čistega zmagovalca, ker ga ni. OpenTofu var-files je močnejši pri manj podvajanja in izolaciji, Terragrunt pri deljenju podatkov med moduli in sočasnem apply-ju več modulov. Članek, na katerega se sklicuješ, je dobro izhodišče, a ga moraš neodvisno preveriti, ne prepisati — upoštevaj tudi, da je avtor iz Gruntworka (ki stoji za Terragruntom), zato vir ni nevtralen.
Prosim, preuči te tri možnosti in mi sporoči, katera ti je najbližja in zakaj — zanima me predvsem, ali se vidiš bolj v analitično-metodološki vlogi (Opcija 1 ali 3) ali v razvoju orodja (Opcija 2). Na podlagi tega dorečeva natančen obseg.
Ko mi odpišeš izbiro, te prosim, da prideš pripravljen z:
(a) enostranskim opisom obsega izbrane opcije,
(b) konkretnim referenčnim scenarijem (koliko okolij, koliko regij, katere storitve),
(c) osnutkom seznama metrik/kriterijev vrednotenja.
Lep pozdrav,

Matjaž B. Jurič

MY ANSWER:

Pozdravljeni,

hvala za podrobne povratne informacije in predlagane usmeritve.

Po pregledu vseh treh možnosti bi izbral **Opcijo 1: Merilni okvir za organizacijo multi-environment IaC**. Ta možnost mi je najbližja, ker ohranja prvotno področje Terraform / OpenTofu / Terragrunt, hkrati pa raziskovalni prispevek premakne od postavljanja infrastrukture k zasnovi ponovljive metodologije in merljivemu vrednotenju.

Bolj se vidim v **analitično-metodološki** vlogi kot v razvoju samostojnega orodja za analizo HCL oziroma grafov odvisnosti (Opcija 2). Zato bi v okviru naloge:

- definiral en referenčni scenarij,
- ga funkcionalno enakovredno implementiral s **tremi pristopi** (Terraform workspaces, Terragrunt, OpenTofu z zgodnjim vrednotenjem spremenljivk),
- vnaprej določil metrike in katalog tipičnih sprememb,
- meritve izvedel reproducibilno (skripte, Git diff, `plan`/`apply` na kratkotrajni realni AWS infrastrukturi).

Argo CD in Vault ne bosta del kritične poti. EKS / CloudFront / Route53 / RDS bodo del referenčnega scenarija; poudarek vrednotenja ostaja organizacija konfiguracije in propagacija sprememb, ne dolgotrajno vzdrževanje produkcijske infrastrukture.

Poleg treh OSS pristopov **razmišljam o vključitvi Terraform Stacks** kot četrtega pristopa (glej razdelek spodaj). Trenutno se nagibam k vključitvi, z eksplicitnimi omejitvami, kaj je reproducibilno merljivo.

V nadaljevanju prilagam:

1. enostranski opis obsega,
2. konkreten referenčni scenarij,
3. osnutek metrik in kataloga sprememb,
4. vprašanje glede Terraform Stacks.

Here i attached docs/archive/ATTACHMENT.md

HIS ANSWER:

Opcijo 1 in analitično-metodološko usmeritev potrjujem. Lahko začneš pisati.
Trije OSS pristopi (workspaces / Terragrunt / OpenTofu z zgodnjim vrednotenjem), raziskovalno vprašanje, katalog sprememb iz istega baseline-a (nekumulativno), izločitev ArgoCD/Vault iz kritične poti - potrjujem. Metrike A–E so dobro zastavljene; "št. mest, kjer moraš spremembo zapisati" (CA3) je jedro cele naloge — tam je prava DRY-korist.
Tri odločitve, ki jih vgradi v metodologijo

1. Merilni substrat je plan + statična analiza + git diff, ne realni apply.
   To ni le stvar stroškov. Cel tvoj prispevek stoji na reproducibilnosti; rezultati realnega apply-ja niso reproducibilni (stanje AWS, timing, drift), zato ne morejo biti podlaga meritev. Skoraj vse, vključno z BR2 (št. virov v state-u), dobiš iz plan-a in konfiguracije backendov. Realni apply omeji na eno validacijsko serijo (ena reprezentativna enota na pristop, enkrat) za realizem in empirično potrditev meja state-a — ne kot vir primerjalnih številk. Applyati 5 enot × vse pristope × vse spremembe (15 RDS instanc) je natanko tisto rutinsko delo, od katerega bežimo, in brez raziskovalne teže.
2. Poštenost primerjave moraš eksplicitno nasloviti.
   Granularnost state-a v tvoji tabeli je delno tvoja izbira layouta, ne intrinzična lastnost orodja: Terragruntu si dodelil state na modul×enoto, OpenTofu pa vse module skupaj — zato bo Terragrunt izpadel najbolje na izolaciji po konstrukciji. Obranljivo je samo, če v metodologiji jasno zapišeš, da primerjaš idiomatske, reprezentativne layoute za vsako orodje, in vsakega utemeljiš kot idiomatskega — ne orodij pri maksimalni fleksibilnosti. Sama razlika v granularnosti je lahko ena od ugotovitev, dokler je poimenovana kot predpostavka.
3. Pravila štetja fiksiraj vnaprej; poročaj avtorske IN razširjene vrstice.
   Pred prvo meritvijo določi kanonični formatter (fmt), kaj se šteje, kaj se izloči. Ker Terragrunt (in Stacks) generirata HCL, poročaj oboje — avtorske vrstice (kar napišeš) in efektivne/razširjene (kar dejansko obstaja). Razmerje med njima je del DRY-zgodbe, ne šum. Nabor konceptov za kognitivno kompleksnost (E) fiksiraj vnaprej, da ne uvajaš pristranskosti za nazaj.
   Terraform Stacks
   Vključi jih kot četrti pristop.
   Ena asimetrija ostaja in jo obravnavaj kot problem označevanja, ne izključitve: lokalno tečejo init/validate/create/list, dejanski plan/apply pa v HCP. Praktično:
   konfiguracijske metrike (A, CA1–CA3, E, strukturni BR3–BR5) meri head-to-head enako kot pri OSS — polno offline-reproducibilno;
   execution-level metrike (dejanske plan/apply enote, BR2) požene na HCP (brezplačni/RUM tier), dokumentiraj okolje in te celice v tabeli eksplicitno označi kot HCP-substrat.
   Isto načelo kot pri odločitvi 1 (meriš iz plana, ne iz vzdrževanja žive infre) — le da je pri OSS lokus lokalni plan, pri Stacks HCP run. Konsistentno, dokler je jasno poimenovano.
   (a) sam izvedbeni kompromis obravnavaj kot ugotovitev ("Stacks zamenja lokalno reproducibilnost za upravljano orkestracijo"), ne le kot omejitev — to je legitimen del organizacije multi-env konfiguracije. (b) Delaj izključno po GA dokumentaciji in pripni verzijo Terraform CLI-ja: med beto in GA je bila nezdružljiva sprememba sintakse (tfcomponent.hcl, deployment_group/auto_approve_checks), zato je vse beta-dobo gradivo zastarelo. Preveri, da tvoja skica implementations/terraform-stacks/ ni pisana po stari sintaksi.
   Za spremembo #2 (regijsko-specifična nastavitev) imaš naravno realistično možnost: ACM certifikat za CloudFront mora obstajati v us-east-1. Lepo pokaže regijsko posebnost brez umetnega primera.
