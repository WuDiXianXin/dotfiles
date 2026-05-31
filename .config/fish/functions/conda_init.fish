function conda_init
    if test -f /home/xx/miniconda3/bin/conda
        eval /home/xx/miniconda3/bin/conda "shell.fish" "hook" $argv | source
    else
        if test -f "/home/xx/miniconda3/etc/fish/conf.d/conda.fish"
            source "/home/xx/miniconda3/etc/fish/conf.d/conda.fish"
        else
            set -x PATH "/home/xx/miniconda3/bin" $PATH
        end
    end
end
