function EXT_COLOR () { echo -ne "\[\033[38;5;$1m\]"; }

flush() {
   sync; echo 1 > /proc/sys/vm/op_caches
}

ops() {
   grep ^cmoe /fs/cetusops/fs1/quota.txt|awk '{print $6}'
   grep ^opsCMOE /fs/cetus/fs2/quota.txt|awk '{print $6}'
}

vnc_server() {
    #/usr/bin/Xvnc -once -geometry ${1:-1920x1200} -httpPort 5906 -depth 24 -query localhost securitytypes=none +kb :6
    /usr/bin/Xvnc -once -geometry ${1:-1920x1200} -depth 24 -query localhost securitytypes=none :6
}

vnc_client() {
    vncviewer ${1:-vlad}${2:-:6}
}

vnc() {
    vnc_server 1920x1200 &
    vnc_client &
}

alloc() {
   #----- under IRIX64 :  udo root du -k -s $* 2>/dev/null | sort -n -r
   du -k -s $* 2>/dev/null | sort -n -r
}

bfind() {
   find ~ -type f -perm +022 -print && find ~ -type d -perm +022 -print
}


lpxe() {
   a2ps -o- -R --medium=Letter --columns=1 -f6.0 $* | lpr -Pcmodxerox
}

lphp() {
   a2ps -o- -R --medium=Letter --columns=1 -f6.0 $* | lpr -Pcmodhp
}

jp-quota() {
    ssh joule '/opt/ssm/linux26-i386/bin/chngquota -list -tree afsr' | gawk 'NR<=3;NR>=4{print| "sort -k 3 -n -r"}' | gawk '
BEGIN {
    split("B_KB_MB_GB_TB_PB", SYMS, "_");
    FMT="%-6s %-10s %12s %12s %12s %12s %-20s\n";
    tmpstr=sprintf(FMT,"","","","","","","");
    W=length(tmpstr);
    SEP1=rep("=",W);
    SEP2=rep("-",W);
}
NR==1 { print SEP1; printf(FMT,"Type","Id","Used","Quota","%","SoftQuota","Path"); print SEP1; }
NR==3 { printf("%-17s %12s %12s %12s\n",$1,fs($2,2),fs($3,2),pc($2,$3)); print SEP2; }
NR>=4 { printf(FMT,$1,$2,fs($3,2),fs($4,2),pc($3,$4),fs($5,2),$6); }
END { print SEP1; }
function fs(val, idx) {
    size=val;
    while( size>=1024 || size<=-1024) {
        size/=1024;
        ++idx;
    }
    return(sprintf("%.2f",size) " " SYMS[idx]);
}
function pc(v1,v2) {
    if( v2 > 0 ) {
        return(sprintf("%.0f",v1*100.0/v2));
    } else {
        return("-");
    }
}
function rep(c,n) {
    i=0;
    s="";
    while(i<n) {
        s = s c;
        ++i;
    }
    return(s);
}'
}
