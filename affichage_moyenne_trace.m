%% Affichage de la moyenne des traces EM
clear all;
clc;
close all;

% Chemin vers le dossier contenant les traces
folderSrc = 'SECU8917';  % À ADAPTER

% Nombre de traces à moyenner
Nt = 20000;  % Ajuster selon tes besoins

fprintf('Chargement de %d traces...\n', Nt);

% Lister les fichiers
matrixFilelist = dir(folderSrc);
sizeFilelist = size(matrixFilelist, 1);

% Initialisation
traces_sum = zeros(1, 4000);
nb_loaded = 0;

% Charger et sommer les traces
for i = 1:sizeFilelist
    filename = matrixFilelist(i).name;
    
    if ~isempty(findstr('trace', filename))
        tracepath = fullfile(folderSrc, filename);
        trace = csvread(tracepath);
        traces_sum = traces_sum + trace;
        nb_loaded = nb_loaded + 1;
        
        if mod(nb_loaded, 100) == 0
            fprintf('  %d traces chargées...\n', nb_loaded);
        end
        
        if nb_loaded >= Nt
            break;
        end
    end
end

% Calculer la moyenne
mean_trace = traces_sum / nb_loaded;

% Afficher la moyenne
figure;
plot(mean_trace, 'b-', 'LineWidth', 1.5);
title(sprintf('Moyenne de %d traces EM', nb_loaded));
xlabel('Échantillons');
ylabel('Amplitude EM moyenne');
grid on;
xlim([0 length(mean_trace)]);

fprintf('Moyenne affichée : %d traces\n', nb_loaded);
