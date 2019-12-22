function gitignore

    set -l git_root (git rev-parse --show-toplevel)
    set -l ignore_string ""

    if [ "$argv[1]" = -d ]
        set ignore_string $argv[2]
        set gitignore_file (pwd)/.gitignore
    else
        set ignore_string $argv[1]
        set gitignore_file $git_root/.gitignore
    end

    echo $ignore_string >> $gitignore_file
    git add $gitignore_file
end
