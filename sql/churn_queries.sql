-- =====================================================================
-- Analyse du churn — requêtes SQL (SQLite / DB Browser for SQLite)
-- Auteure : Danielle OUATTARA
-- Table : clients (import du fichier WA_Fn-UseC_-Telco-Customer-Churn.csv)
-- Import : DB Browser for SQLite > Fichier > Importer > Table depuis un CSV
--          nom de la table : clients, cocher « Noms de colonnes en 1re ligne »
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. Contrôle de l'import
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS nb_clients          -- compte toutes les lignes : on attend 7 043
FROM clients;                          -- table importée depuis le CSV


-- ---------------------------------------------------------------------
-- 1. Nettoyage : vue propre réutilisée par toutes les requêtes suivantes
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS v_clients;                         -- supprime la vue si elle existe déjà
CREATE VIEW v_clients AS                               -- crée une vue (une « table virtuelle »)
SELECT
    customerID,                                        -- identifiant client
    Contract                         AS contrat,       -- Month-to-month / One year / Two year
    PaymentMethod                    AS paiement,      -- mode de paiement
    InternetService                  AS service_internet,
    OnlineSecurity                   AS option_securite,
    TechSupport                      AS support_technique,
    CAST(tenure AS INTEGER)          AS anciennete_mois,       -- ancienneté en mois, en nombre
    CAST(MonthlyCharges AS REAL)     AS mrr,                   -- facture mensuelle = MRR du client
    CASE WHEN TRIM(TotalCharges) = '' THEN 0                   -- 11 valeurs vides (clients à 0 mois)
         ELSE CAST(TotalCharges AS REAL) END AS total_facture, -- sinon conversion en nombre
    CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS churn,        -- churn en 1 / 0 pour calculer des taux
    CASE                                                       -- tranches d'ancienneté
        WHEN CAST(tenure AS INTEGER) <= 6  THEN '1. 0-6 mois'
        WHEN CAST(tenure AS INTEGER) <= 12 THEN '2. 7-12 mois'
        WHEN CAST(tenure AS INTEGER) <= 24 THEN '3. 13-24 mois'
        WHEN CAST(tenure AS INTEGER) <= 48 THEN '4. 25-48 mois'
        ELSE '5. 49 mois et +'
    END AS tranche_anciennete,
    (CASE WHEN OnlineSecurity   = 'Yes' THEN 1 ELSE 0 END      -- nombre d'options de sécurité
   + CASE WHEN OnlineBackup     = 'Yes' THEN 1 ELSE 0 END      -- souscrites (0 à 4)
   + CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN TechSupport      = 'Yes' THEN 1 ELSE 0 END) AS nb_options_securite
FROM clients;


-- ---------------------------------------------------------------------
-- 2. KPI globaux : taux de churn et MRR perdu
-- ---------------------------------------------------------------------
SELECT
    COUNT(*)                                        AS nb_clients,        -- base totale
    SUM(churn)                                      AS nb_churners,       -- somme des 1 = clients partis
    ROUND(100.0 * SUM(churn) / COUNT(*), 1)         AS taux_churn_pct,    -- 100.0 force un calcul décimal
    ROUND(SUM(mrr), 0)                              AS mrr_total,         -- revenu mensuel total
    ROUND(SUM(CASE WHEN churn = 1 THEN mrr END), 0) AS mrr_perdu          -- MRR des clients partis
FROM v_clients;


-- ---------------------------------------------------------------------
-- 3. Churn par type de contrat
-- ---------------------------------------------------------------------
SELECT
    contrat,                                                -- dimension analysée
    COUNT(*)                                AS nb_clients,
    ROUND(100.0 * SUM(churn) / COUNT(*), 1) AS taux_churn_pct,
    ROUND(AVG(mrr), 1)                      AS mrr_moyen
FROM v_clients
GROUP BY contrat                                            -- une ligne par type de contrat
ORDER BY taux_churn_pct DESC;                               -- du plus risqué au moins risqué


-- ---------------------------------------------------------------------
-- 4. Churn par tranche d'ancienneté
-- ---------------------------------------------------------------------
SELECT
    tranche_anciennete,
    COUNT(*)                                AS nb_clients,
    ROUND(100.0 * SUM(churn) / COUNT(*), 1) AS taux_churn_pct
FROM v_clients
GROUP BY tranche_anciennete
ORDER BY tranche_anciennete;                -- ordre chronologique grâce au préfixe 1., 2., ...


-- ---------------------------------------------------------------------
-- 5. Churn par mode de paiement
-- ---------------------------------------------------------------------
SELECT
    paiement,
    COUNT(*)                                AS nb_clients,
    ROUND(100.0 * SUM(churn) / COUNT(*), 1) AS taux_churn_pct
FROM v_clients
GROUP BY paiement
ORDER BY taux_churn_pct DESC;


-- ---------------------------------------------------------------------
-- 6. Effet des options de sécurité et du support (clients ayant Internet)
-- ---------------------------------------------------------------------
SELECT
    nb_options_securite,                                    -- 0, 1, 2, 3 ou 4 options
    COUNT(*)                                AS nb_clients,
    ROUND(100.0 * SUM(churn) / COUNT(*), 1) AS taux_churn_pct
FROM v_clients
WHERE service_internet <> 'No'              -- les options n'existent que pour les clients Internet
GROUP BY nb_options_securite
ORDER BY nb_options_securite;


-- ---------------------------------------------------------------------
-- 7. Matrice de priorisation : contrat × ancienneté, avec MRR en jeu
--    → les segments à fort taux de churn ET fort MRR actif sont la cible n°1
-- ---------------------------------------------------------------------
SELECT
    contrat,
    tranche_anciennete,
    COUNT(*)                                                AS nb_clients,
    ROUND(100.0 * SUM(churn) / COUNT(*), 1)                 AS taux_churn_pct,
    ROUND(SUM(CASE WHEN churn = 0 THEN mrr ELSE 0 END), 0)  AS mrr_actif_a_proteger
FROM v_clients
GROUP BY contrat, tranche_anciennete
HAVING COUNT(*) >= 50                        -- on écarte les segments trop petits pour conclure
ORDER BY taux_churn_pct DESC
LIMIT 10;                                    -- top 10 des segments les plus exposés
