x = imread('Farol-de-Santa-Luzia.jpg'); xx = rgb2gray(x); 
% Aqui, a imagem foi redimensionada de 500x500 pixels para 250x250 pixels. 
f= uint16(imresize(xx, [250, 250], 'bicubic'));
% No seu caso, a imagem de 250x250 pontos será fornecida no formato raw.
% Aqui calcula-se o histograma da imagem 
histograma=zeros(256,1);
for i=1:250,      
    for j=1:250,  
        % matlab não indexa posição 0 e uma imagem pode ter nível de cinza=0            
        histograma(f(i,j)+1)=histograma(f(i,j)+1)+1;      
    end;  
end; 
histo = imhist(uint8(f)); % calculado chamando-se a função imhist do Matlab
subplot(311); imshow(uint8(f)); title("Imagem do Farol de Santa Luzia - VV") 
subplot(312); plot(histograma); % calculado conforme linhas de código 9 a 14 
title("Histograma calculado")
subplot(313); 
plot(histo); 
title("Histograma usando-se a função 'imhist'") 