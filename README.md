# 🔐 Pourquoi les abonnés partent — et lesquels retenir en premier

> Analyse du churn d'une base de 7 043 abonnés à des services numériques (connectivité, sécurité en ligne, sauvegarde, support technique). Objectif : identifier les profils à risque, chiffrer le revenu menacé et prioriser un plan de rétention.

![Statut](https://img.shields.io/badge/statut-en%20cours-yellow) ![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?logo=powerbi&logoColor=black) ![SQL](https://img.shields.io/badge/SQL-336791?logo=postgresql&logoColor=white) ![Python](https://img.shields.io/badge/Python-pandas-3776AB?logo=python&logoColor=white)

---

## 1. Contexte business

Dans un modèle par abonnement — opérateur télécom, fournisseur cloud ou éditeur SaaS — **conserver un client coûte bien moins cher que d'en acquérir un nouveau**. Le revenu récurrent mensuel (MRR) dépend directement du taux d'attrition.

Le jeu de données reprend la base clients d'un fournisseur de services numériques. Sa structure est la même que celle d'un catalogue cloud/cyber : un abonnement principal, des **options de sécurité** (sécurité en ligne, protection des appareils, sauvegarde), un **support technique**, un **type d'engagement** (mensuel, 1 an, 2 ans) et un mode de facturation.

## 2. Problématique

> **Quels clients risquent de résilier, pourquoi, et combien de revenu mensuel est en jeu ?**

Sous-questions :
1. Quel est le taux de churn global et quel MRR est perdu ?
2. Le type de contrat, l'ancienneté et le mode de paiement influencent-ils le churn ?
3. Les clients équipés d'options de **sécurité** et de **support technique** partent-ils moins ?
4. Quels segments faut-il cibler en priorité dans une campagne de rétention ?

## 3. Source des données

| Élément | Détail |
|---|---|
| Jeu de données | *Telco Customer Churn* (jeu d'exemple IBM) |
| Lien | https://www.kaggle.com/datasets/blastchar/telco-customer-churn |
| Fichier | `WA_Fn-UseC_-Telco-Customer-Churn.csv` |
| Volume | 7 043 clients × 21 colonnes |
| Variables clés | `tenure` (ancienneté en mois), `Contract`, `PaymentMethod`, `OnlineSecurity`, `TechSupport`, `MonthlyCharges`, `TotalCharges`, `Churn` |

⚠️ Le fichier CSV n'est pas versionné dans ce dépôt (licence Kaggle) : le télécharger et le placer dans `data/`.

## 4. Méthodologie

| Étape | Ce que je fais | Outil principal | Alternative |
|---|---|---|---|
| 1. Import | Chargement du CSV | Power Query | Python (pandas) |
| 2. Nettoyage | `TotalCharges` en texte → nombre ; 11 lignes vides (clients à 0 mois d'ancienneté) | Power Query | Python |
| 3. Enrichissement | Tranches d'ancienneté (0-6, 7-12, 13-24, 25-48, 49+ mois), nombre d'options de sécurité, churn en 0/1 | Colonnes calculées / SQL `CASE WHEN` | Python |
| 4. Analyse exploratoire | Taux de churn par contrat, ancienneté, paiement, options | SQL (`sql/churn_queries.sql`) | Python (notebook) |
| 5. Revenu à risque | MRR perdu et MRR des segments les plus exposés | Mesures DAX (`powerbi/mesures_dax.md`) | SQL |
| 6. Restitution | Dashboard 2 pages : vue d'ensemble + segments à risque | Power BI | Graphiques Python |

## 5. Stack technique

- **Power BI Desktop** : Power Query (nettoyage), DAX (mesures), dashboard
- **SQL** (SQLite / DB Browser for SQLite, gratuit) : requêtes de segmentation
- **Python / pandas** (facultatif) : notebook d'exploration commenté ligne à ligne
- **Excel** : contrôles croisés via tableaux croisés dynamiques

## 6. Résultats clés

| Indicateur | Valeur |
|---|---|
| Taux de churn global | **26,5 %** — 1 869 clients partis sur 7 043 |
| MRR perdu (clients partis) | **139 131 $ / mois**, soit **30,5 %** du MRR total (456 117 $) |
| Churn — contrat mensuel vs contrat 2 ans | **42,7 %** vs **2,8 %** (15 fois plus) — contrat 1 an : 11,3 % |
| Poids des contrats mensuels dans les départs | **≈ 89 %** des clients partis |
| Churn — clients de 0 à 6 mois d'ancienneté | **52,9 %**, contre 9,5 % au-delà de 4 ans ; ≈ 42 % des départs ont lieu dans les 6 premiers mois |
| Churn — 0 option sécurité/support vs 4 options¹ | **56,7 %** vs **5,3 %** ; chaque option supplémentaire fait baisser le churn (38,9 % → 23,8 % → 12,4 %) |
| Churn — paiement par chèque électronique | **45,3 %**, contre 15 à 17 % en paiement automatique (≈ 3 fois plus) |
| Segment le plus à risque | **Mensuel × 0-6 mois** — 1 413 clients, **55,2 %** de churn, 29 273 $ de MRR encore actif |
| Plus gros MRR exposé | **Mensuel × 25-48 mois** — 802 clients, 32,9 % de churn, **38 347 $** de MRR actif |

¹ Parmi les 5 517 clients abonnés à Internet (options : sécurité en ligne, sauvegarde, protection des appareils, support technique).

**Lecture :** le churn se concentre sur trois facteurs qui se cumulent : l'**absence d'engagement**, les **premiers mois de la relation** et la **faible adoption des options**. Les contrats mensuels représentent à eux seuls 136 447 $ de MRR encore actif, soit 43 % du revenu restant à protéger.

**Limites :** il s'agit de corrélations, pas de causalités. Par exemple, les clients équipés de 4 options sont aussi plus souvent engagés sur de longues durées. Un test contrôlé serait nécessaire pour mesurer l'effet propre de chaque levier.

📊 Captures du dashboard : `visuals/`

## 7. Recommandations business

1. **Convertir les contrats mensuels à l'engagement** — cible prioritaire : les 802 clients mensuels de 25 à 48 mois (38 347 $ de MRR actif, 32,9 % de churn). Ils sont déjà fidèles dans les faits : une offre de bascule vers l'engagement annuel (1 mois offert) peut ramener leur risque vers les 10-11 % observés sur les contrats d'un an.
2. **Sécuriser les 6 premiers mois** — plus d'un client mensuel récent sur deux part (55,2 %). Mettre en place un parcours d'onboarding : appel de bienvenue à J+7, point d'usage à J+30, revue à J+90 avec une proposition d'engagement.
3. **Faire des options sécurité/support un levier de rétention** — le churn passe de 56,7 % sans option à 23,8 % avec deux options. Proposer un bundle « sécurité + support » à prix d'appel aux 1 267 clients sans aucune option, avec un argumentaire et une battlecard pour les équipes commerciales.
4. **Migrer le chèque électronique vers le prélèvement automatique** — 2 365 clients, 45,3 % de churn. Proposer une incitation à l'activation, par exemple une remise sur la première facture.
5. **Piloter un score de risque mensuel** (contrat × ancienneté × nombre d'options × mode de paiement) dans le dashboard, pour que le Customer Success traite en priorité les comptes à fort MRR et fort risque.

## 8. Structure du dépôt

```
churn-analysis-subscription-services/
├── README.md
├── data/
│   └── WA_Fn-UseC_-Telco-Customer-Churn.csv   ← à télécharger (non versionné)
├── sql/
│   └── churn_queries.sql                       ← requêtes de segmentation commentées
├── powerbi/
│   ├── mesures_dax.md                          ← étapes Power Query + mesures DAX
│   └── churn_dashboard.pbix                    ← à ajouter
├── notebooks/
│   └── 01_analyse_churn.ipynb                  ← option Python, commentée ligne à ligne
└── visuals/
    └── (captures du dashboard)
```

---

**Danielle OUATTARA** · [LinkedIn](https://www.linkedin.com/in/niyadanielleouattara/) · [Mes autres projets](https://github.com/niyadanielleO)
