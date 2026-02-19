clear all;
clc;
close all;
warning off;

fprintf('=== ATTAQUE EMA AES-128 - 10ème ROUND ===\n\n');

% Chargement des données
load('key_dec.mat')
load('pti_dec.mat')
load('cto_dec.mat')
load('L.mat')

% Renommer pour compatibilité avec le code référence
keys = key_dec;
traces = L;
cto = cto_dec;

fprintf('Données chargées: %d traces\n\n', size(traces,1));

% ==== INITIALISATION ====

% Clé réelle pour vérification
keys4x4 = reshape(keys(1, :), [4 4]);
all_w = keysched2(uint32(keys4x4));
w10 = all_w(:, :, 11);  % Objectif de l'attaque

fprintf('=== w10 ATTENDU (objectif) ===\n');
disp(w10)

% S-Box et Inverse S-Box
S_box = [99,124,119,123,242,107,111,197,48,1,103,43,254,215,171,118,202,130,201,125,250,89,71,240,173,212,162,175,156,164,114,192,183,253,147,38,54,63,247,204,52,165,229,241,113,216,49,21,4,199,35,195,24,150,5,154,7,18,128,226,235,39,178,117,9,131,44,26,27,110,90,160,82,59,214,179,41,227,47,132,83,209,0,237,32,252,177,91,106,203,190,57,74,76,88,207,208,239,170,251,67,77,51,133,69,249,2,127,80,60,159,168,81,163,64,143,146,157,56,245,188,182,218,33,16,255,243,210,205,12,19,236,95,151,68,23,196,167,126,61,100,93,25,115,96,129,79,220,34,42,144,136,70,238,184,20,222,94,11,219,224,50,58,10,73,6,36,92,194,211,172,98,145,149,228,121,231,200,55,109,141,213,78,169,108,86,244,234,101,122,174,8,186,120,37,46,28,166,180,198,232,221,116,31,75,189,139,138,112,62,181,102,72,3,246,14,97,53,87,185,134,193,29,158,225,248,152,17,105,217,142,148,155,30,135,233,206,85,40,223,140,161,137,13,191,230,66,104,65,153,45,15,176,84,187,22];

invSBox = zeros(1,256);
invSBox(S_box+1) = 0:255;

% Poids de Hamming
Weight_Hamming_vect = [0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 4 5 5 6 5 6 6 7 5 6 6 7 6 7 7 8];

% ==== AFFICHAGE DES TRACES ====
figure('Name', 'Analyse traces EM');

subplot(2,1,1)
plot(traces(1,:))
title('Trace EM #1')
xlabel('Échantillons')
ylabel('Amplitude')
grid on

subplot(2,1,2)
traces_mean = mean(traces);
plot(traces_mean)
title('Moyenne de toutes les traces')
xlabel('Échantillons')
ylabel('Amplitude')
grid on
hold on
xline(3000, 'r--', 'LineWidth', 2)
xline(3500, 'r--', 'LineWidth', 2)
legend('Moyenne', 'Zone Round 10')

% ==== FILTRAGE ZONE 10ème ROUND ====
idxmin = 3000;
idxmax = 3300;  % Comme dans le PDF référence

fprintf('\n=== ATTAQUE SUR LA ZONE [%d:%d] ===\n\n', idxmin, idxmax);

% ==== ATTAQUE PAR CORRÉLATION ====

% Hypothèses linéaires (256 possibilités par octet)
hypothese = uint8(ones(size(cto, 1), 1) * (0:255));

% Indices pour gérer ShiftRow
indices = 1:16;
indices = reshape(indices, [4 4]);

% Matrice résultat
best_candidate = zeros(4,4);

for ligne = 1:4
    % Application du ShiftRow
    indices_shifted(ligne, :) = circshift(indices(ligne, :), ligne - 1);
    
    for colonne = 1:4
        fprintf('Attaque sous-clé [%d,%d] (position %d)... ', ...
            ligne, colonne, indices_shifted(ligne, colonne));
        
        % Extension du ciphertext
        cto_extended = uint8(single(cto(:, indices(ligne, colonne))) * ones(1, 256));
        cto_extended_shifted = uint8(single(cto(:, indices_shifted(ligne, colonne))) * ones(1, 256));
        
        % Z1 = cto XOR hypothèse
        Z1 = bitxor(cto_extended_shifted, hypothese);
        
        % Z3 = InvSBox(Z1)
        Z3 = invSBox(Z1 + 1);
        
        % Distance de Hamming: dH(Z0, Z3) = dH(cto, InvSBox(cto XOR k))
        dh_03 = Weight_Hamming_vect(bitxor(uint8(Z3), uint8(cto_extended)) + 1);
        
        % Corrélation avec les traces filtrées
        correlation = corr(single(dh_03), traces(:, idxmin:idxmax));
        
        % Trouver la meilleure hypothèse
        [RK, IK] = sort(max(abs(correlation), [], 2), 'descend');
        best_candidate(ligne, colonne) = IK(1) - 1;
        
        fprintf('0x%02X (corr=%.4f)\n', best_candidate(ligne, colonne), RK(1));
    end
    
    % Inverser le ShiftRow pour reconstruction
    best_candidate(ligne, :) = circshift(best_candidate(ligne, :), -(ligne - 1));
end

fprintf('\n=== CLÉ w10 ESTIMÉE ===\n');
disp(best_candidate)

% ==== VÉRIFICATION ====
if isequal(uint32(best_candidate), w10)
    fprintf('\n✓✓✓ SUCCÈS TOTAL: w10 parfaitement retrouvée! ✓✓✓\n\n');
else
    fprintf('\n⚠ Vérification des différences:\n');
    diff = uint32(best_candidate) ~= w10;
    [rows, cols] = find(diff);
    for i = 1:length(rows)
        fprintf('  [%d,%d]: estimé=0x%02X, attendu=0x%02X\n', ...
            rows(i), cols(i), best_candidate(rows(i),cols(i)), w10(rows(i),cols(i)));
    end
    fprintf('\n');
end

fprintf('=== FIN DE L''ATTAQUE ===\n');
