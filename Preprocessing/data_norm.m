function [new_data] = data_norm(data)
  largo = size(data);
  new_data = [data(:,1)];
  for j=2:largo(2)   
     new_data = [new_data normalize(data(:,j),'range')];
  end 
end