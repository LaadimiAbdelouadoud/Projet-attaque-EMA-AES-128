clear all;
clc;
close all;

% Chemin vers le répertoire contenant les traces
folderSrc = 'SECU8917';  % À adapter selon votre système

% Nombre de traces
Nt = 20000;

matrixFilelist = dir(folderSrc);
sizeFilelist = size(matrixFilelist,1);

Nti = 0;

% Initialisation
key = cell(Nt,1);
pti = cell(Nt,1);
cto = cell(Nt,1);

fprintf('=== EXTRACTION DES TRACES ===\n');

% Parcourir tous les fichiers
for i = 1:sizeFilelist
    filename = matrixFilelist(i).name;
    
    % Chercher les fichiers trace_AES
    if ~isempty(strfind(filename, 'trace_AES'))
        Nti = Nti + 1;
        
        % Extraction key
        idx_key = strfind(filename, 'key=');
        key{Nti} = filename(idx_key+4:idx_key+35);
        
        % Extraction pti
        idx_pti = strfind(filename, 'pti=');
        pti{Nti} = filename(idx_pti+4:idx_pti+35);
        
        % Extraction cto
        idx_cto = strfind(filename, 'cto=');
        cto{Nti} = filename(idx_cto+4:idx_cto+35);
        
        % Charger la trace EM
        trace = csvread(fullfile(folderSrc, filename));
        L(Nti,:) = trace;
        
        if mod(Nti, 1000) == 0
            fprintf('  %d traces chargées...\n', Nti);
        end
        
        if Nti >= Nt
            break;
        end
    end
end

fprintf('Total: %d traces chargées\n', Nti);

% Conversion hexadécimal -> décimal
fprintf('Conversion hex -> decimal...\n');

for i = 1:Nti
    for j = 1:16
        key_dec(i,j) = hex2dec(key{i}((j-1)*2+1:j*2));
        pti_dec(i,j) = hex2dec(pti{i}((j-1)*2+1:j*2));
        cto_dec(i,j) = hex2dec(cto{i}((j-1)*2+1:j*2));
    end
end

% Sauvegarder
save('key_dec.mat','key_dec')
save('pti_dec.mat','pti_dec')
save('cto_dec.mat','cto_dec')
save('L.mat','L', '-v7.3')

fprintf('\n=== EXTRACTION TERMINÉE ===\n');
fprintf('Fichiers sauvegardés:\n');
fprintf('  - key_dec.mat, pti_dec.mat, cto_dec.mat, L.mat\n');
