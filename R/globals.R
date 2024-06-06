# A Hadley-tolerated hack to prevent devtools::check() from creating Notes.
# see https://forum.posit.co/t/how-to-solve-no-visible-binding-for-global-variable-note/28887
# and https://stackoverflow.com/questions/63136204/no-visible-global-function-definition-for
utils::globalVariables(c("datetime_PST", "flow", "stage"))
