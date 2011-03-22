% qf = quality factor as in IJG's implementation
function qt = qualityFactorIJG(quantisation_table, qf)

if( qf < 1 )
    qf = 1;
elseif( qf > 100 )
    qf = 100;
end
if (qf < 50)
    scale_factor = 5000 / qf;
else
    scale_factor = 200 - qf*2;
end
% set quantisation tables
qt = round(((quantisation_table .* scale_factor) + 50) ./ 100);
% limit the values to the valid range 
qt( qt <= 0 ) = 1;
qt( qt > 255 ) = 255;

return