" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    36
"
" Other candidates:
" https://github.com/typelevel/wartremover
" https://github.com/sksamuel/scalac-scapegoat-plugin
" https://github.com/HairyFotr/linter
" https://github.com/sbt/cpd4sbt
" https://github.com/scala/scala-abide


call checksyntax#AddChecker('scala?',
            \     {
            \         'compiler': 'checksyntax/fsc_lint',
            \     },
            \     {
            \         'compiler': 'checksyntax/scalastyle',
            \     },
            \ )

