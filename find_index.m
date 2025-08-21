% Return the index of the corresponding ID
function ind = find_index(elos, k, N)
ind = -1;
for i = 1:N
    if elos(i).id == k
        ind = i;
        break;
    end
end
