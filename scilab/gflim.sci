function gflim(lim)
    ax=gca(),// gat the handle on the current axes
    a = ax.data_bounds
    a(3:$) = lim
    ax.data_bounds=a;
endfunction
