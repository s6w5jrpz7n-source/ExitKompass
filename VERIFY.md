# VERIFY.md – Manuelle Verifikation der Golden-Cases

## ✅ Status: verifiziert am 2026-07-05

Der Abgleich gegen den **BMF-Lohn-/Einkommensteuerrechner** und den
**ALG-Rechner der Bundesagentur für Arbeit** (Screenshots vom Nutzer)
ist erfolgt. Ergebnis:

| Fall | Größe | Engine | offizieller Rechner | Δ |
|---|---|---|---|---|
| G1 | Lohnsteuer 60 k/I | 9.389,00 € | BMF 9.389,00 € | **exakt** |
| G1 | ALG/Monat | 1.903,80 € | BA 1.902,60 € | +1,20 € (0,06 %) |
| G2 | Lohnsteuer 90 k/III | 12.310,00 € | BMF 12.310,00 € | **exakt** |
| G2 | Kirchensteuer | 847,62 € | BMF 847,62 € | **exakt** |
| G2 | ALG/Monat 67 % | 3.286,80 € | BA 3.296,70 € | −9,90 € (0,30 %) |
| G3-Var. | Lohnsteuer 130 k/I+Ki | 35.969,00 € | BMF 35.969,00 € | **exakt** |
| G3-Var. | Soli / KiSt | 1.858,66 / 3.237,21 € | BMF idem | **exakt** |
| G3 | ALG/Monat (10.833 €/M) | 2.807,40 € | BA 2.810,10 € | −2,70 € (0,10 %) |
| G5 | Lohnsteuer 45 k/V | 10.494,00 € | BMF 10.494,00 € | **exakt** |
| G5 | Kirchensteuer (V, BY) | 839,52 € | BMF 839,52 € | **exakt** |
| G6 | ESt zvE 55/67/115 k | 12.347 / 17.018 / 37.164 € | BMF idem | **exakt** |

**Alle Steuerwerte treffen den BMF-Rechner exakt; alle ALG-Monatsbeträge
liegen unter 0,3 % Abweichung** (Spec-§5-Ziel: ±2 %). Die
`unverified`-Tags wurden entfernt; die BMF-Werte sind zusätzlich als
feste Referenztests in `test/m1_income_tax_test.dart` verankert.

### Dabei gefundener und behobener Fehler (fix in `m1`)

Der erste Abgleich zeigte bei G1 eine Abweichung von 61 € (9.328 statt
9.389 €). Ursachen in der Vorsorgepauschale:
1. Der KV-Teilbetrag muss mit dem **ermäßigten** Beitragssatz gerechnet
   werden (14,0 %/2 = 7,0 % statt 7,3 %), § 39b Abs. 2 S. 5 Nr. 3 EStG.
2. Die Vorsorgepauschale wird **einmal als Summe** auf volle Euro
   aufgerundet, nicht je Teilbetrag.
Zusätzlich wird die Kirchensteuer in StKl V/VI auf die **volle**
Lohnsteuer berechnet (dort gibt es keine Kinderfreibetragszähler).

---

Die folgende Checkliste (exakte Eingaben je Fall) bleibt zur
**Nachvollziehbarkeit** erhalten – z. B. um nach einer Parameter-
aktualisierung 2027 erneut abzugleichen.

## Rechner

- **BMF-Lohn- und Einkommensteuerrechner:** <https://www.bmf-steuerrechner.de>
  – „Berechnung der Lohnsteuer" (Jahr 2026) bzw. „Berechnung der
  Einkommensteuer" (Tarif 2026).
- **ALG-Rechner der Bundesagentur für Arbeit (Selbstinformation):**
  <https://www.arbeitsagentur.de/arbeitslosengeld-rechner>
  (bzw. <https://www.pub.arbeitsagentur.de>) – Leistung ab 2026.

## Gemeinsame BMF-Eingaben (Lohnsteuer, alle Fälle)

| Feld | Wert |
|---|---|
| Abrechnungszeitraum | Jahr 2026 |
| Lohnzahlungszeitraum | jährlich, voller Jahresbruttolohn |
| Geburtsjahr | so wählen, dass das Alter dem Fall entspricht (kein Alter ≥ 64 → keine Altersentlastung) |
| Krankenversicherung | gesetzlich, **Zusatzbeitragssatz 2,9 %** |
| Rentenversicherung | gesetzlich (West/Ost egal, BBG 2026 bundeseinheitlich) |
| Freibetrag/Hinzurechnungsbetrag | 0 |
| Bundesland | wie im Fall angegeben (Sachsen: nein) |

Beobachtete Genauigkeit (Stand 2026-07-05): **Lohn-/Einkommensteuer
exakt** deckungsgleich mit dem BMF-Rechner; **ALG < 0,3 %** Abweichung
(Rundungskonventionen der BA, s. ASSUMPTIONS.md A5.2).

---

## ☐ G1 – 60.000 €, StKl I, kinderlos, 30 Jahre, keine Kirche (NW)

**BMF-Lohnsteuer:** Jahresbrutto 60.000 €, StKl I, keine Kinderfreibeträge,
kirchensteuerpflichtig: nein, PV: kinderlos (Zuschlag ja), Bundesland NW.

| Engine-Wert | Erwartung |
|---|---|
| Lohnsteuer | **9.328,00 €** |
| Soli | 0,00 € |
| Kirchensteuer | 0,00 € |

**BA-ALG-Rechner:** Brutto 5.000 €/Monat (12 Monate), StKl I, kein Kind,
keine Kirchensteuer.

| Engine-Wert | Erwartung |
|---|---|
| Leistungsentgelt/Tag | 105,95 € |
| ALG-Tagessatz (60 %) | 63,57 € |
| **ALG/Monat** | **1.907,10 €** |
| Anspruchsdauer (24 Monate versichert, 30 J) | 360 Tage / 12 Monate |

## ☐ G2 – 90.000 €, StKl III, 1 Kind, Kirche 9 %, 40 Jahre (NW)

**BMF-Lohnsteuer:** Jahresbrutto 90.000 €, StKl III, Kinderfreibetragszähler
1,0, kirchensteuerpflichtig: ja (NW, 9 %), PV: 1 Kind (kein Zuschlag, kein
Abschlag), Bundesland NW.

| Engine-Wert | Erwartung |
|---|---|
| Lohnsteuer | **12.246,00 €** |
| Soli | 0,00 € |
| Kirchensteuer | **842,22 €** |

**BA-ALG-Rechner:** Brutto 7.500 €/Monat, StKl III, mit Kind (67 %).

| Engine-Wert | Erwartung |
|---|---|
| ALG-Tagessatz (67 %) | 109,67 € |
| **ALG/Monat** | **3.290,10 €** |

## ☐ G3 – 130.000 €, StKl I, kinderlos, 45 Jahre (über beiden BBGs)

**BMF-Lohnsteuer:** Jahresbrutto 130.000 €, StKl I, keine Kinderfreibeträge,
keine Kirche, PV: kinderlos.

| Engine-Wert | Erwartung |
|---|---|
| Lohnsteuer | **35.704,00 €** |
| Soli | **1.827,12 €** (Milderungszone) |

**BA-ALG-Rechner:** Brutto 10.833 €/Monat (wird an der BBG 8.450 €/Monat
gedeckelt), StKl I, kein Kind.

| Engine-Wert | Erwartung |
|---|---|
| Bemessungsentgelt/Tag (gedeckelt) | 277,80 € |
| ALG-Tagessatz (60 %) | 93,74 € |
| **ALG/Monat (Höchstbetrag kinderlos)** | **2.812,20 €** |

## ☐ G5 – 45.000 €, StKl V, 2 Kinder, Kirche 8 %, 35 Jahre (Bayern)

**BMF-Lohnsteuer:** Jahresbrutto 45.000 €, StKl V, Kinderfreibetragszähler
2,0, kirchensteuerpflichtig: ja (BY, 8 %), PV: 2 Kinder unter 25
(Abschlag für das 2. Kind), Bundesland BY.

| Engine-Wert | Erwartung |
|---|---|
| Lohnsteuer | **10.438,00 €** |
| Soli | 0,00 € |
| Kirchensteuer | **202,24 €** |

## ☐ G6 – Abfindung: Rest-zvE 55.000 € + 60.000 € Abfindung (Grundtarif)

**BMF-Einkommensteuerrechner** (Tarif 2026, Einzelveranlagung) – drei
Abfragen des zvE; die Fünftelregelung ergibt sich per Handrechnung:

| Abfrage | zvE | erwartete ESt |
|---|---|---|
| Basis | 55.000 € | **12.347 €** |
| Regelbesteuerung | 115.000 € | **37.164 €** |
| Basis + 1/5 Abfindung | 67.000 € | **17.018 €** |

Fünftelregelung: 12.347 + 5 × (17.018 − 12.347) = **35.702 €**
→ Ersparnis **1.462 €** (nur über Veranlagung erstattet).

## ☐ G7 (optional) – ALG: 95.000 €, StKl III, 1 Kind, 58 J, 48 Monate versichert

**BA-ALG-Rechner:** Brutto 7.916,67 €/Monat, StKl III, mit Kind, 58 Jahre.

| Engine-Wert | Erwartung |
|---|---|
| ALG-Tagessatz (67 %) | 114,45 € |
| **ALG/Monat** | **3.433,50 €** |
| Anspruchsdauer (48 Monate, 58 J) | 720 Tage / 24 Monate |
| Sperrzeit-Simulation: Minderung | 180 Tage (¼ von 720) → 20.601 € verloren |

## ☐ G8 (optional) – ALG + § 158: 80.000 €, StKl I, 50 J, Abfindung 60.000 €

**BA-ALG-Rechner:** Brutto 6.666,67 €/Monat, StKl I, kein Kind, 50 Jahre.

| Engine-Wert | Erwartung |
|---|---|
| ALG-Tagessatz (60 %) | 79,54 € |
| **ALG/Monat** | **2.386,20 €** |
| Anspruchsdauer (30 Monate, 50 J) | 450 Tage / 15 Monate |
| § 158-Ruhen (25 J Betrieb, Kündigungsfrist 120 Tage unterschritten) | Anteil 25 % → 15.000 € → **68 Tage Ruhen** |

*Hinweis: Das § 158-Ruhen bildet der BA-Online-Rechner nicht ab; hier nur
Plausibilitätsprüfung des Anteils nach § 158 Abs. 2 SGB III (60 % − 5 %-Punkte
je 5 Jahre Betriebszugehörigkeit − 5 %-Punkte je 5 Lebensjahre über 35,
Minimum 25 %).*

---

## Zusätzliches Release-Gate (Spec §5, M1)

Unabhängig von dieser Checkliste verlangt die Spec die Validierung gegen
die offiziellen **Testfälle des BMF-Programmablaufplans (PAP) 2026** als
Golden-Master („ohne diese Validierung kein Release"). Die PAP-PDFs waren
in dieser Session über den Netz-Proxy nicht abrufbar – TODO vor Release
(siehe ASSUMPTIONS.md A0/A1.2).

## Nach dem Abgleich

1. Abweichungen > Toleranz: bitte notieren (Fall, Feld, BMF/BA-Wert) –
   dann wird die Engine korrigiert und neu gepinnt.
2. Bestätigten Abgleich melden → die `unverified`-Tags in
   `golden_test.dart` und der Hinweis in `dart_test.yaml` werden entfernt.
