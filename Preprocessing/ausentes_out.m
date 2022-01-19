function [new_data, new_lab] = ausentes_out(dati, etiqueta) 
    tam = size(dati);
    new_data = [];
    new_lab = [];
    parfor i=1:tam(1)   
    cont = 0;
        for j=2:tam(2) 
            if dati(i,j)==0
                cont= cont+1; 
            end
        end
        if cont<2
            new_data = [new_data;dati(i,:)];
            new_lab = [new_lab;etiqueta(i)];
        end
    end
end
