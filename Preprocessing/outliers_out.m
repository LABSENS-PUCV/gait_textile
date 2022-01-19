function [new_data] = outliers_out(data)
    largo = size(data);
    new_data = zeros(largo);
    for j=2:largo(2)
        prom = mean(data(:,j));
        desv = std(data(:,j));
        list_out = isoutlier(data(:,j));
        for i=1:largo(1)
            if list_out(i)==1
                new_data(i,j)= prom+desv; 
            else
                new_data(i,j)= data(i,j); 
            end
        end      
    end
    %size(new_data)
    %size(data)
    new_data(:,1)= data(:,1);
end

