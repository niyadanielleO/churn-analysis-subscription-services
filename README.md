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

> *À compléter après l'analyse.*

| Indicateur | Valeur |
|---|---|
| Taux de churn global | `[XX,X] %` |
| MRR perdu (clients partis) | `[XX XXX] $ / mois` |
| Churn — contrat mensuel vs contrat 2 ans | `[XX] %` vs `[X] %` |
| Churn — clients < 6 mois d'ancienneté | `[XX] %` |
| Churn — sans option sécurité vs avec | `[XX] %` vs `[XX] %` |
| Churn — paiement par chèque électronique | `[XX] %` |
| Segment le plus à risque | `[à compléter]` — `[XXX]` clients, `[XX XXX] $` de MRR |

📊 Captures du dashboard : `visuals/`

## 7. Recommandations business

> *À ajuster selon les résultats obtenus.*

1. **Migrer les contrats mensuels vers l'engagement annuel** : offre de bascule (mois offert, remise de `[X] %`) ciblée sur les clients mensuels de plus de 6 mois.
2. **Sécuriser les 6 premiers mois** : parcours d'onboarding (appel de bienvenue J+7, point d'usage J+30, revue J+90).
3. **Vendre la sécurité comme levier de fidélisation** : bundle « sécurité + support » proposé aux clients non équipés à fort MRR — argumentaire et battlecard pour les commerciaux.
4. **Pousser le prélèvement automatique** : incitation au changement de mode de paiement pour les clients au chèque électronique.
5. **Piloter un score de risque mensuel** dans Power BI pour que le Customer Success traite en priorité les comptes à fort MRR et fort risque.

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
