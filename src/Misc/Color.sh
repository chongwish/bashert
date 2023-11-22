print_truecolor_line() {
    awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
        s="/\\";
        for (colnum = 0; colnum<term_cols; colnum++) {
            r = 255-(colnum*255/term_cols);
            g = (colnum*510/term_cols);
            b = (colnum*255/term_cols);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum%2+1,1);
            }
        printf "\n";
    }'
}

print_256color_number() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m%3d " "${i}"
        if (( $i == 15 )) || (( $i > 15 )) && (( ($i-15) % 12 == 0 )); then
            echo;
        fi
    done
}