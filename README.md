Auteurs :

Romaissae GHALEM
Abdelouadoud LAADIMI
Objectif

--> Retrouver la sous-clé du 10ᵉ round d’un AES-128 implémenté sur FPGA
--> Exploiter des fuites électromagnétiques (EMA)
--> Utiliser une attaque par corrélation d’ordre 1

Méthode

--> Sélection de la zone du dernier round dans 20000 traces
--> Modèle de fuite basé sur le poids de Hamming
--> Test de 256 hypothèses par octet
--> Corrélation de Pearson
--> Choix de l’hypothèse avec la corrélation maximale

Résultat

--> Reconstruction complète de la sous-clé w10
--> Attaque réussie

Contenu du dépôt

--> Script d’extraction des traces
--> Script principal d’attaque
--> Fichiers .mat (key_dec, pti_dec, cto_dec, L)
