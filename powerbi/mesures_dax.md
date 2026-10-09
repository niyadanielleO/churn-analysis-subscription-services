# Power BI — préparation et mesures

## A. Power Query (Accueil > Transformer les données)

1. **Obtenir les données > Texte/CSV** → `data/WA_Fn-UseC_-Telco-Customer-Churn.csv`. Renommer la requête : `clients`.
2. Colonne `TotalCharges` : **Remplacer les valeurs** ` ` (un espace) par `0`, puis **Type de données > Nombre décimal**.
3. Colonne `SeniorCitizen` : **Type > Texte**, puis remplacer `1` par `Oui` et `0` par `Non`.
4. **Ajouter une colonne > Colonne conditionnelle**, nom `Tranche ancienneté` :
   - si `tenure` ≤ 6 → `1. 0-6 mois` ; ≤ 12 → `2. 7-12 mois` ; ≤ 24 → `3. 13-24 mois` ; ≤ 48 → `4. 25-48 mois` ; sinon `5. 49 mois et +`
5. **Ajouter une colonne > Colonne conditionnelle**, nom `Churn (0/1)` : si `Churn` = `Yes` → `1`, sinon `0`. Type : **Nombre entier**.
6. **Fermer et appliquer**.

## B. Mesures DAX (Modélisation > Nouvelle mesure)

```DAX
Nb clients = COUNTROWS ( clients )

Nb churners = SUM ( clients[Churn (0/1)] )

Taux de churn = DIVIDE ( [Nb churners], [Nb clients] )

MRR total = SUM ( clients[MonthlyCharges] )

MRR perdu =
CALCULATE ( [MRR total], clients[Churn] = "Yes" )

MRR actif =
CALCULATE ( [MRR total], clients[Churn] = "No" )

Part du MRR perdu = DIVIDE ( [MRR perdu], [MRR total] )

Écart au churn moyen =
[Taux de churn]
    - CALCULATE ( [Taux de churn], ALL ( clients ) )
```

Formats : `Taux de churn`, `Part du MRR perdu`, `Écart au churn moyen` → **Pourcentage, 1 décimale** ; MRR → **Devise $, 0 décimale**.

## C. Maquette du dashboard

**Page 1 — Vue d'ensemble**
- 4 cartes : `Nb clients` · `Taux de churn` · `MRR perdu` · `Part du MRR perdu`
- Histogramme : `Taux de churn` par `Contract`
- Courbe : `Taux de churn` par `Tranche ancienneté`
- Barres : `Taux de churn` par `PaymentMethod`

**Page 2 — Segments à risque**
- Matrice : lignes `Contract`, colonnes `Tranche ancienneté`, valeur `Taux de churn` (mise en forme conditionnelle > échelle de couleurs)
- Nuage de points : axe X `Taux de churn`, axe Y `MRR actif`, détails `Contract` + `Tranche ancienneté`
- Segments (slicers) : `InternetService`, `OnlineSecurity`, `TechSupport`
