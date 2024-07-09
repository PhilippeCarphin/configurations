function p.debugpy -d "Launch python debugger listening on port 5678"
    echo $argv
    python3 -m debugpy --wait-for-client --listen 5678 $argv
end
