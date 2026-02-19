%% Affichage de la première trace EM
clear all;
clc;
close all;

% Chemin vers le dossier contenant les traces
folderSrc = 'SECU8917';  % À ADAPTER

% Lister les fichiers
matrixFilelist = dir(folderSrc);
sizeFilelist = size(matrixFilelist, 1);

% Chercher le premier fichier de trace
for i = 1:sizeFilelist
    filename = matrixFilelist(i).name;
    
    if ~isempty(findstr('trace', filename))
        % Lire la trace
        tracepath = fullfile(folderSrc, filename);
        trace = csvread(tracepath);
        
        % Afficher la trace
        figure;
        plot(trace, 'b-', 'LineWidth', 1);
        title('Première trace de fuite électromagnétique');
        xlabel('Échantillons');
        ylabel('Amplitude EM');
        grid on;
        xlim([0 length(trace)]);
        
        fprintf('Trace affichée : %d points\n', length(trace));
        break;
    end
end
