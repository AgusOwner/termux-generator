# Abre el menu ArgentSS una vez por sesion, solo en terminales interactivas.
if [ -t 0 ] && [ -t 1 ] && [ -z "${ARGENTSS_MENU_SHOWN:-}" ] && [ -x "$PREFIX/bin/argentss-menu" ]; then
    export ARGENTSS_MENU_SHOWN=1
    "$PREFIX/bin/argentss-menu"
fi
