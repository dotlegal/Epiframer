extensions [matrix]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__includes ["theory-in-tags.nls" "objects.nls"] ; (#pttrns x #strtgs; objects)
;;;;;;;;;;;;;;nb;;;;;;; ! # $ % & _ ? -> 0 can be set as variables ;;;;;;;;;;;;;

;2345678901234567890123456789012345678901234567890123456789012345678901234567890
breed [inds ind]   ;; Individuals
breed [insts inst] ;; Institutions
breed [sits sit]   ;; Situations
breed [MSSGS MSSG] ;; Messages with dpl = data protection level
inds-own  [brand name mypatch born live? purse tag cndt memory r-w-s r-v-s r-v-t ]
insts-own [brand name mypatch born live? purse tag cndt memory]
sits-own  [brand name mypatch born live? purse tag cndt memory]
MSSGS-own [message] ;(list dpl msgnum sndr ddrss sp stmp channel content)
globals [
;; implicitly defined in interface
;; - sliders:   gen-tcks mx-tcks grdfrc grpfrc oppfrc indfrc
;; - choosers:  log? leveldiv? recurse? evolve?

;; Parameters (or: for the setup phase (level 1))
  #pttrns #strtgs value-file-name
  res-wrths-strtgs ;res-wrths-tags
  res-vals-strtgs res-vals-tags
  #tags #cndtns all-pttrns all-strtgs all-tags all-cndtns
  #ptchs #inds #jdgs #bnkrts #crdtrs #trsts

;; Reporting variables for the interface ... (used for interactions)

  all-msgs   all-lettrs  all-emails  all-eforms tags-strats Ktags-strats;(run)
  all-Kmsgs  all-Klettrs all-Kemails all-Keforms                        ;(run)
  all-KoutR all-KinsR all-KJR all--KJR all-KTR all--KTR                 ;(run)

  cgnrtn cntrec adapt?                                          ;(generation)
  gen-msgs   gen-lettrs  gen-emails  gen-eforms                 ;(generation)
  gen-Kmsgs  gen-Klettrs gen-Kemails gen-Keforms                ;(generation)
  gen-KoutR gen-KinsR gen-KJR gen--KJR gen-KTR gen--KTR         ;(generation)

  per-msgs per-lettrs per-emails per-eforms       ;(cntr = ticks)(period)
  per-Kmsgs per-Klettrs per-Kemails per-Keforms                 ;(period)
  per-KoutR per-KinsR per-KJR per--KJR per-KTR per--KTR         ;(period)

  nodes c# cpttrn ccrdts cjdg ctrst  cbnkrt KEI?                ;(pttrn)

  sndr stag scndt schoice sndr-rsrcs stag#                      ;(choice)
  rcvr rtag rcndt rchoice rcvr-rsrcs rtag# press                     ;(choice)
]
;;setup @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
to setup
  clear-all reset-ticks
  setup-interface
  setup-nodes-tier1
  setup-all-tags-list setup-all-cndts-list setup-all-pttrns setup-all-strtgs
  setup-resource-values setup-agents
end
to setup-interface
;; for the setup phase (level 1)
  set tags-strats matrix:from-row-list [[0 0 0][0 0 0][0 0 0][0 0 0]]
  set Ktags-strats matrix:from-row-list [[0 0 0][0 0 0][0 0 0][0 0 0]]
  set #pttrns 5 set #strtgs 3 set #ptchs 1024 set #inds 1024
  set #jdgs 8 set #trsts 8  set #bnkrts 20 set #crdtrs 4
  set cgnrtn 0 set cntrec 0 set adapt? false
  setup-run setup-gen setup-per
end
to setup-nodes-tier1    ;; (PM)
  set nodes (list [0 1] [1 1] [2 4] [3 4] [4 4] [5 4] [6 1] [7 1])
  ;  (0) judge appoints trustee               (0 1)
  ;  (1) trustee calls press incite creditors (1 1)
  ;  (2) creditors request registration       (2 4)
  ;  (3) trustee decides on registration      (3 4)
  ;  (4) trustee calls for comments on plan   (4 4)
  ;  (5) creditors comment on plan            (5 4)
  ;  (6) trustee calls for judge's support    (6 1)
  ;  (7) judge gives decision                 (7 1)
  output-type "\n Nodes-tier1: [pttrn-id #of messages]:\n " output-print nodes
  output-type " Normative-debate slider settings "
  output-print  ( list grdfrc grpfrc oppfrc indfrc )
end
to setup-resource-values
    output-print (list    " code conversion rules:\n"
    "    if i = \"?\" [ set i random 3 -1 ]  ;; ? (don't know)\n"
    "    if i = \"m\" [ set i 2 ]            ;; m (mandatory)\n"
    "    if i = \"p\" [ set i random 2 + 1 ] ;; p (preferred)\n"
    "    if i = \"n\" [ set i 0 ]            ;; n (neutral)\n"
    "    if i = \"u\" [ set i random 2 - 2 ] ;; u (unfavored)\n"
    "    if i = \"f\" [ set i -2 ]           ;; f (forbidden)")
      let legenda ( list
    "\n  tags:" all-tags "cndts:" all-cndtns
    "\n  strtgs:" all-strtgs  " mx-tcks" mx-tcks "gen-tcks" gen-tcks "forces"
     (list grdfrc grpfrc oppfrc indfrc) "\n  log?" log? "leveldiv?"
     leveldiv? "evolve?" evolve? "NormativeDebate" NormativeDebate "\nvalue codes"
    "\n   ? -> (don't know)  m -> (mandatory)   p -> (preferred)"
    "\n   n -> (neutral)     u -> (unfavored)   f -> (forbidden)")
  set res-wrths-strtgs current-theory
  ;set res-wrths-tags item 1 theories
  set res-vals-strtgs transcode (list res-wrths-strtgs)
  set res-vals-tags   transpose res-vals-strtgs
  output-print legenda
  output-print "\nresource codes (pttrns x tags x strtgs)"
  let cntr -1 foreach res-wrths-strtgs [ p ->  set cntr cntr + 1
    output-type item cntr all-pttrns output-type " -> " output-print p ]
  output-print " "
  if Log? = true [
    output-print "\nVariables logged"
    output-print " msgs Kmsgs all-lettrs all-emails all-eforms all-Klettrs"
    output-print " all-Kemails all-Keforms KinsR KoutR KJR -KJR KTR -KTR \n"]
end
to setup-agents
  setup-inds setup-insts setup-sits setup-mssgs setup-brands
end

;;go @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
to go
  if ticks > mx-tcks [ do-roundup stop]
  if (genshift = 0)  [ do-generation]
  do-period
  tick
end
to once
    go
end
to do-roundup
    ;output-type " from roundup " output-print ticks
    if log? = true [export-output "kei-log.txt"]
  output-print "\n the non-KEI-domain frequencies in a tags x strategies matrix"
    output-print matrix:pretty-print-text tags-strats
  output-print "\n the KEI-domain frequencies in a tags x strategies matrix"
    output-print matrix:pretty-print-text Ktags-strats

end
to do-generation
  setup-gen
  do-setup-jdgs do-setup-trsts do-setup-bnkrts do-setup-crdtrs
  if NormativeDebate != "stable" and ticks > 9 [adapt]
end

to adapt ;; and setup jdgs trsts bnkrts & crdtrs
  let cndtnl-vec ( list grdfrc grpfrc oppfrc indfrc )
  if (( list grdfrc grpfrc oppfrc indfrc ) = [0 0 0 0]) [stop]
  ;user-message "adapting individual resource-value tables ..."
  let channels [0 0 0]
  if normativedebate = "0:letter" [set channels [1 0 0]]
  if normativedebate = "1:email"  [set channels [0 1 0]]
  if normativedebate = "2:eform"  [set channels [0 0 1]]
  if normativedebate = "3:0&1"    [set channels [1 1 0]]
  if normativedebate = "4:0&2"    [set channels [1 0 1]]
  if normativedebate = "5:1&2"    [set channels [0 1 1]]
  if normativedebate = "6:all"    [set channels [1 1 1]]

  ask inds [
    let pattern [] let cndtnl [] let val []
    let #cndtnl -1 let #val -1 let #pattern -1
    foreach r-v-s [ i -> set pattern i     ;<- i/pattern is a pattern sublist [5 x]
      set #pattern #pattern + 1 set #cndtnl -1
      foreach pattern [ j -> set cndtnl j  ;<- j/cndtnl is a tag sublidt ([0 1 2]) [4 x]
        set #cndtnl #cndtnl + 1 set #val -1 let factor item #cndtnl cndtnl-vec
        foreach cndtnl [ k -> set val k    ;<- j/val is a strtg value [3 x]
          set #val #val + 1 if item #val channels = 1 [ set val val + factor
            set cndtnl (replace-item #val cndtnl val )]
        set pattern (replace-item #cndtnl pattern (cndtnl))]
      set r-v-s (replace-item #pattern r-v-s (pattern))]
    set r-v-t transpose r-v-s ]
  ]

 ; user-message "... ready!"
  output-type "\nadaptation of resource codes at period " output-type ticks
  output-type " based on slider settings " output-print cndtnl-vec

  ;; show a table of correlations between tags and strategies
 end
to do-period
    setup-per
    do-wpn-tier1
    do-plot-prepare
  ;; refresh bnkrts, crdtrs & trsts each period (tick)
    do-setup-trsts do-setup-bnkrts do-setup-crdtrs
end
to do-wpn-tier1 ;; cycle = one tick [& call  choose]
  ask one-of inds with [ brand = "prss" ] [ set press who ]
  setup-per         ; set c# 0
  ask inds with [brand = "bnkrt"] [ set cbnkrt who set ccrdts []
  ask my-links [ ask other-end [ if (brand = "trst") [set ctrst who]
  if (brand = "crdtr") [set ccrdts lput who ccrdts ] ] ] ;; output-print ccrdts
  ask (ind ctrst) [ask my-links [ask other-end [if (brand = "jdg") [
    set cjdg who ]]]]
  foreach nodes [ x -> set cpttrn item 0 x set c# item 1 x repeat c# [
    if cpttrn = 0 [set sndr cjdg set rcvr ctrst set KEI? true choose]
    if cpttrn = 1 [set sndr ctrst set rcvr press set KEI? false choose]
    if cpttrn = 2 [foreach ccrdts [y -> set sndr y set rcvr ctrst set KEI? false choose]]
    if cpttrn = 3 [set sndr ctrst foreach ccrdts [ y -> set rcvr y set KEI? false choose]]
    if cpttrn = 4 [set sndr ctrst foreach ccrdts [ y -> set rcvr y set KEI? false choose]]
    if cpttrn = 5 [foreach ccrdts [y -> set sndr y set rcvr ctrst set KEI? false choose]]
    if cpttrn = 6 [set sndr ctrst set rcvr cjdg set KEI? true choose]
    if cpttrn = 7 [set sndr cjdg set rcvr ctrst set KEI? true choose]
    choose ]]]
end
to choose ;; choose channel and update counters
    set per-msgs per-msgs + 1 if KEI = true [set per-Kmsgs per-Kmsgs + 1]
;;       sndrs choice & metabolsim
  ask (ind sndr) [
    set stag# position tag all-tags
    let sstrtgs item stag# item cpttrn r-v-s
    set schoice max-pos sstrtgs
        if (cpttrn = 0 and mandatory? = true) [set schoice 2]
        if (cpttrn = 5 and mandatory? = true) [set schoice 2]
        if (cpttrn = 6 and mandatory? = true) [set schoice 2]
    set sndr-rsrcs item schoice item cpttrn r-v-t
    set purse add-to-purse (list sndr-rsrcs purse) ]
;;      rcvrs choice & metabolsim
  ask (ind rcvr) [
    set rtag# position tag all-tags
    let rstrtgs item rtag# item cpttrn r-v-s
    set rchoice max-pos rstrtgs
    set rcvr-rsrcs item rchoice item cpttrn r-v-t
    set purse add-to-purse (list rcvr-rsrcs purse)  ]
;;      update per-message interface reporter values
  if schoice = 0 [set per-lettrs per-lettrs + 1
  if KEI = true [set per-Klettrs per-Klettrs + 1]]
  if schoice = 1 [set per-emails per-emails + 1
  if KEI = true [set per-Kemails per-Kemails + 1]]
  if schoice = 2 [set per-eforms per-eforms + 1
    if KEI = true [set per-Keforms per-Keforms + 1]]
  if cpttrn = 0 and schoice = 2
    [set per-KJR sm-sblsts (list per-KJR sndr-rsrcs)]
  if cpttrn = 0 and schoice != 2
    [set per--KJR sm-sblsts (list per--KJR sndr-rsrcs)]
  if cpttrn = 4 and schoice = 2
    [set per-KTR sm-sblsts (list per-KTR sndr-rsrcs)]
  if cpttrn = 4 and schoice != 2
    [set per--KTR sm-sblsts (list per--KTR sndr-rsrcs)]
  ifelse KEI = true [set per-KinsR sm-sblsts (list per-KinsR sndr-rsrcs)]
    [set per-KoutR sm-sblsts (list per-KoutR sndr-rsrcs)]

   ifelse KEI = true [
    matrix:set Ktags-strats stag# schoice matrix:get Ktags-strats stag# schoice + 1]
    [matrix:set tags-strats stag# schoice matrix:get tags-strats stag# schoice + 1]

  if log? = true [
    matrix:set tags-strats stag# schoice matrix:get tags-strats stag# schoice + 1]
end


to do-plot-prepare ;; and update all- and gen- counters
  set all-msgs all-msgs + per-msgs set all-lettrs all-lettrs + per-lettrs
  set all-emails all-emails + per-emails set all-eforms all-eforms + per-eforms
  set all-Kmsgs all-Kmsgs + per-Kmsgs set all-Klettrs all-Klettrs + per-Klettrs
  set all-Kemails all-Kemails + per-Kemails set all-Keforms all-Keforms + per-Keforms
  set gen-Kmsgs gen-Kmsgs + per-Kmsgs set gen-Klettrs gen-Klettrs + per-Klettrs
  set gen-Kemails gen-Kemails + per-Kemails set gen-Keforms gen-Keforms + per-Keforms
  set all-KJR sm-sblsts (list all-KJR per-KJR)
  set all--KJR sm-sblsts (list all--KJR per--KJR)
  set all-KTR sm-sblsts (list all-KTR per-KTR)
  set all--KTR sm-sblsts (list all--KTR per--KTR)
  set all-KinsR sm-sblsts (list all-KinsR per-KinsR)
  set all-KoutR sm-sblsts (list all-KoutR per-KoutR)
  end



;  if Log? = true [ output-print (list ticks jdg-divs trst-divs per-msgs per-Kmsgs per-lettrs
;    per-emails per-eforms per-Klettrs per-Kemails per-Keforms per-KinsR
;    per-KoutR per-KJR per--KJR per-KTR per--KTR )]
@#$#@#$#@
GRAPHICS-WINDOW
22
16
507
502
-1
-1
14.91
1
5
1
1
1
0
0
0
1
0
31
0
31
1
1
1
ticks
30.0

BUTTON
975
84
1031
127
NIL
setup 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1031
84
1090
127
once
once
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
509
16
973
136
          I - Channels chosen in bankruptcy-administration domain
period (tick)
%
0.0
240.0
0.0
100.0
true
true
"" ""
PENS
"%lettrs" 1.0 0 -13840069 true "" "if ticks > 1 [ plot 100 * per-lettrs / per-msgs ]"
"%emls" 1.0 0 -2674135 true "" "if ticks > 1 [ plot 100 * per-emails / per-msgs ]"
"%efrms" 1.0 0 -16777216 true "" "if ticks > 1 [ plot 100 * per-eforms / per-msgs ]"

BUTTON
974
162
1091
225
go/stop
GO
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
975
16
1089
49
mx-tcks
mx-tcks
0
1000
931.0
1
1
NIL
HORIZONTAL

MONITOR
318
23
408
68
    trst x tags
trst-divs
0
1
11

SWITCH
974
260
1091
293
leveldiv?
leveldiv?
1
1
-1000

PLOT
509
137
972
259
II - Channels chosen in KEI domain
period (tick)
%
0.0
240.0
0.0
100.0
true
true
"" ""
PENS
"%Klttrs" 1.0 0 -13840069 true "" "if ticks > 1 [ plot per-Klettrs * 100 / per-Kmsgs]"
"%Kmls" 1.0 0 -2674135 true "" "if ticks > 1 [ plot per-Kemails * 100 / per-Kmsgs]"
"%Kfrms" 1.0 0 -16777216 true "" "if ticks > 1 [ plot per-Keforms * 100 / per-Kmsgs]"

PLOT
510
260
713
380
III - Rsrcs of KEI-user judges 
cycle (tick)
K for (j)
0.0
240.0
0.0
4.0
true
false
"" ""
PENS
"grp" 1.0 0 -13840069 true "" "if ticks > 1 [ plot item 1 all-KJR]"
"grd" 1.0 0 -2674135 true "" "if ticks > 1 [ plot item 0 all-KJR]"
"opp " 1.0 0 -14070903 true "" "if ticks > 1 [ plot item 2 all-KJR]"
"ind" 1.0 0 -6459832 true "" "if ticks > 1 [ plot item 3 all-KJR]"

SLIDER
975
372
1093
405
grpfrc
grpfrc
-1
1
0.0
0.5
1
NIL
HORIZONTAL

SLIDER
976
473
1093
506
indfrc
indfrc
-1
1
0.0
0.5
1
NIL
HORIZONTAL

SLIDER
975
440
1092
473
oppfrc
oppfrc
-1
1
0.0
0.5
1
NIL
HORIZONTAL

OUTPUT
25
536
1134
808
12

MONITOR
914
88
974
133
Tms (K)
round (all-msgs / 1000)
0
1
11

MONITOR
914
211
969
256
Kms (K)
round (all-Kmsgs / 1000)
17
1
11

SWITCH
974
226
1091
259
log?
log?
0
1
-1000

SLIDER
976
407
1094
440
grdfrc
grdfrc
-1
1
0.0
0.5
1
NIL
HORIZONTAL

MONITOR
512
10
580
55
      T%% 
(list \n precision (all-lettrs * 100 / all-msgs ) 0\n precision (all-emails * 100 / all-msgs) 0\n precision (all-eforms * 100 / all-msgs) 0 )
0
1
11

SLIDER
975
50
1089
83
gen-tcks
gen-tcks
0
500
250.0
10
1
NIL
HORIZONTAL

PLOT
714
260
972
380
IV - ... of non KEI-user judges
NIL
 -K for (j)
0.0
240.0
0.0
10.0
true
true
"" ""
PENS
"[ab]" 1.0 0 -14439633 true "" "if (ticks > 0) [plot item 1 all--KJR]"
"[aa]" 1.0 0 -2674135 true "" "if (ticks > 0) [plot item 0 all--KJR]"
"[ba]" 1.0 0 -14070903 true "" "if (ticks > 0) [plot item 2 all--KJR]"
"[bb]" 1.0 0 -8431303 true "" "if (ticks > 0) [plot item 3 all--KJR]"

MONITOR
513
138
588
183
       K%% 
(list \n precision (all-Klettrs * 100 / all-Kmsgs ) 0\n precision (all-Kemails * 100 / all-Kmsgs) 0\n precision (all-Keforms * 100 / all-Kmsgs) 0 )
17
1
11

SWITCH
974
294
1091
327
evolve?
evolve?
1
1
-1000

MONITOR
409
23
501
68
     jdg x tags
jdg-divs
17
1
11

PLOT
510
381
715
503
V - Rsrcs of KEI-user trsts 
NIL
 K for (t)
0.0
240.0
0.0
4.0
true
false
"" ""
PENS
"grp" 1.0 0 -13840069 true "" "if ticks > 1 [ plot item 1 all-KTR]"
"grd" 1.0 0 -2674135 true "" "if ticks > 1 [ plot item 0 all-KTR]"
"opp" 1.0 0 -14070903 true "" "if ticks > 1 [ plot item 2 all-KTR]"
"ind" 1.0 0 -8431303 true "" "if ticks > 1 [ plot item 3 all-KTR]"

PLOT
714
379
973
502
VI ...  of non KEI-user trsts 
NIL
-K for (t)
0.0
240.0
0.0
10.0
true
true
"" ""
PENS
"[ab]" 1.0 0 -14439633 true "" "if ticks > 1 [ plot item 1 all--KTR]"
"[aa]" 1.0 0 -2674135 true "" "if ticks > 1 [ plot item 0 all--KTR]"
"[ba]" 1.0 0 -14070903 true "" "if ticks > 1 [ plot item 2 all--KTR]"
"[bb]" 1.0 0 -8431303 true "" "if ticks > 1 [ plot item 3 all--KTR]"

CHOOSER
974
328
1092
373
NormativeDebate
NormativeDebate
"stable" "0:letter" "1:email" "2:eform" "3:0&1" "4:0&2" "5:1&2" "6:all"
0

SWITCH
975
128
1091
161
mandatory?
mandatory?
0
1
-1000

@#$#@#$#@
   
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
