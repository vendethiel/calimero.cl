#!/usr/bin/env raku
for @*ARGS -> $file {
  my $s = slurp $file;
  my @s;
  for $s ~~ m:g/"(" <.ws> ":import-from" <.ws> ":"$<package>=[\S+] <.ws> ["#:"$<import>=[<[\w.*-]>+]* <.ws>]+ / {
    @s = $/.List.map(*.<import>).flat.map(~*);
  };
  my $said = False;
  for @s -> $sym {
    if 1 == +($s ~~ m:g/$sym/) {
      unless $said { say "$file:"; $said = True; }
      say "  $sym";
    }
  };
}
