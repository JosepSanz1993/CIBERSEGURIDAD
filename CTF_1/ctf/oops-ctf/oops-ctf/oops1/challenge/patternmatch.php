<?php
// =============================================================================
//  ENIGMA DE PRIVESC — "pattern matching"
//  Aquest fitxer conté un missatge codificat en ASCII decimal.
//  Descodifica'l per obtenir el secret del compte local 'oopsuser' i fes `su`.
//
//  Pista: cada número és el codi ASCII (base 10) d'un caràcter.
//     Python:  "".join(chr(int(x)) for x in open('...').read().split())
//     Bash:    for n in $(cat); do printf "\\$(printf '%03o' $n)"; done
// =============================================================================

$ASCII = "73 110 32 74 97 118 97 44 32 106 97 118 97 46 117 116 105 108 46 114 101 103 101 120 46 80 97 116 116 101 114 110 46 99 111 109 112 105 108 101 40 114 101 103 101 120 41 32 112 108 117 115 32 77 97 116 99 104 101 114 46 109 97 116 99 104 101 115 40 41 32 116 101 115 116 115 32 119 104 101 116 104 101 114 32 116 104 101 32 69 78 84 73 82 69 32 105 110 112 117 116 32 109 97 116 99 104 101 115 32 116 104 101 32 112 97 116 116 101 114 110 46 32 84 104 101 32 108 111 99 97 108 32 97 99 99 111 117 110 116 32 39 111 111 112 115 117 115 101 114 39 32 115 101 99 114 101 116 32 109 97 116 99 104 101 115 32 116 104 105 115 32 108 105 116 101 114 97 108 32 112 97 116 116 101 114 110 58 32 67 114 52 99 107 77 51 95 76 52 98 35 50 48 50 52 32 45 45 32 117 115 101 32 105 116 32 119 105 116 104 58 32 32 115 117 32 111 111 112 115 117 115 101 114";

// (El fitxer NO descodifica sol el missatge: aquesta és la feina del jugador.)
// Deixem, però, l'estructura d'un "matcher" de Java com a decoració temàtica:
/*
    import java.util.regex.*;
    Pattern p = Pattern.compile("^Cr4ckM3_L4b#\\d{4}$");
    Matcher m = p.matcher(candidate);
    boolean ok = m.matches();   // true nomes si TOT l'input encaixa
*/
echo "Aquesta pagina no fa res. Mira'n el codi font (/internal/patternmatch.php).\n";
