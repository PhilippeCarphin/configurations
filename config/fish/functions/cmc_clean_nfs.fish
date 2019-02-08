function cmc_clean_nfs
    ssh joule -t "cd $PWD; "'rm $(find . -name '"'"'.nfs*'"'"')'
end

