function d_xy = tools_dist(a_xy,b_xy)
    d_xy = a_xy - b_xy;
    d_xy = sqrt(sum(d_xy .* d_xy));
end