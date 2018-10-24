#!perl
# vim:ts=4:sw=4:expandtab
#
# Please read the following documents before working on tests:
# • https://build.i3wm.org/docs/testsuite.html
#   (or docs/testsuite)
#
# • https://build.i3wm.org/docs/lib-i3test.html
#   (alternatively: perldoc ./testcases/lib/i3test.pm)
#
# • https://build.i3wm.org/docs/ipc.html
#   (or docs/ipc)
#
# • http://onyxneon.com/books/modern_perl/modern_perl_a4.pdf
#   (unless you are already familiar with Perl)
#
# Verify that the corrent focus stack order is preserved after various
# operations.
use i3test i3_config => <<EOT;
# i3 config file (v4)
font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1
fake-outputs 1024x768+0+0,1024x768+1024+0
EOT

sub kill_and_confirm_focus {
    my $focus = shift;
    my $msg = shift;
    cmd "kill";
    sync_with_i3;
    is($x->input_focus, $focus, $msg);
}

my @windows;
my $ws;

sub focus_windows {
    for (my $i = $#windows; $i >= 0; $i--) {
        cmd '[id=' . $windows[$i]->id . '] focus';
    }
}

sub confirm_focus {
    my $msg = shift;
    sync_with_i3;
    is($x->input_focus, $windows[0]->id, $msg . ': window 0 focused');
    foreach my $i (1 .. $#windows) {
        kill_and_confirm_focus($windows[$i]->id, "$msg: window $i focused");
    }
    cmd 'kill';
    @windows = ();
}

#####################################################################
# Open 5 windows, focus them in a custom order and then change to
# tabbed layout. The focus order should be preserved.
#####################################################################

fresh_workspace;

$windows[3] = open_window;
$windows[1] = open_window;
$windows[0] = open_window;
$windows[2] = open_window;
$windows[4] = open_window;
focus_windows;

cmd 'layout tabbed';
confirm_focus('tabbed');

#####################################################################
# Same as above but with stacked.
#####################################################################

fresh_workspace;
$windows[3] = open_window;
$windows[1] = open_window;
$windows[0] = open_window;
$windows[2] = open_window;
$windows[4] = open_window;
focus_windows;

cmd 'layout stacked';
confirm_focus('stacked');

#####################################################################
# Open 4 windows horizontally, move the last one down. The focus
# order should be preserved.
#####################################################################

fresh_workspace;
$windows[3] = open_window;
$windows[2] = open_window;
$windows[1] = open_window;
$windows[0] = open_window;

cmd 'move down';
confirm_focus('split-h + move');

#####################################################################
# Same as above but with a vertical split.
#####################################################################

fresh_workspace;
$windows[3] = open_window;
cmd 'split v';
$windows[2] = open_window;
$windows[1] = open_window;
$windows[0] = open_window;

cmd 'move left';
confirm_focus('split-v + move');

#####################################################################
# Test that moving an unfocused container from another output
# maintains the correct focus order.
#####################################################################

fresh_workspace(output => 0);
$windows[3] = open_window;
fresh_workspace(output => 1);
$windows[2] = open_window;
$windows[1] = open_window;
$windows[0] = open_window;

cmd '[id=' . $windows[3]->id . '] move right';
confirm_focus('unfocused move from other output');

#####################################################################
# Test that moving an unfocused container inside its original parent
# maintains the correct focus order.
#####################################################################

fresh_workspace;
$windows[0] = open_window;
$windows[1] = open_window;
cmd 'split v';
$windows[2] = open_window;
$windows[3] = open_window;
focus_windows;

cmd '[id=' . $windows[2]->id . '] move up';
confirm_focus('split-v + unfocused move inside parent');

######################################################################
# Test that moving an unfocused container maintains the correct focus
# order.
# Layout: H [ A V1 [ B C D ] ]
######################################################################

fresh_workspace;
$windows[3] = open_window;
$windows[2] = open_window;
cmd 'split v';
$windows[1] = open_window;
$windows[0] = open_window;

cmd '[id=' . $windows[3]->id . '] move right';
confirm_focus('split-v + unfocused move');

######################################################################
# Test that moving an unfocused container from inside a split
# container to another workspace doesn't focus sibling.
######################################################################

$ws = fresh_workspace;
$windows[0] = open_window;
$windows[1] = open_window;
cmd 'split v';
open_window;
cmd 'mark a';

cmd '[id=' . $windows[0]->id . '] focus';
cmd '[con_mark=a] move to workspace ' . get_unused_workspace;

is(@{get_ws_content($ws)}, 2, 'Sanity check: marked window moved');
confirm_focus('Move unfocused window from split container');

######################################################################
# Moving containers to another workspace puts them on the top of the
# focus stack but behind the focused container.
######################################################################

for my $new_workspace (0 .. 1) {
    fresh_workspace;
    $windows[2] = open_window;
    $windows[1] = open_window;
    fresh_workspace if $new_workspace;
    $windows[3] = open_window;
    $windows[0] = open_window;
    cmd 'mark target';

    cmd '[id=' . $windows[2]->id . '] move to mark target';
    cmd '[id=' . $windows[1]->id . '] move to mark target';
    confirm_focus('\'move to mark\' focus order' . ($new_workspace ? ' when moving containers from other workspace' : ''));
}

######################################################################
# Same but with workspace commands.
######################################################################

fresh_workspace;
$windows[2] = open_window;
$windows[1] = open_window;
$ws = fresh_workspace;
$windows[3] = open_window;
$windows[0] = open_window;
cmd 'mark target';

cmd '[id=' . $windows[2]->id . '] move to workspace ' . $ws;
cmd '[id=' . $windows[1]->id . '] move to workspace ' . $ws;
confirm_focus('\'move to workspace\' focus order when moving containers from other workspace');

######################################################################
# Test focus order with floating and tiling windows.
# See issue: 1975
######################################################################

fresh_workspace;
$windows[2] = open_window;
$windows[0] = open_window;
$windows[3] = open_floating_window;
$windows[1] = open_floating_window;
focus_windows;

confirm_focus('mix of floating and tiling windows');

######################################################################
# Same but an unfocused tiling window is killed first.
######################################################################

fresh_workspace;
$windows[2] = open_window;
$windows[0] = open_window;
$windows[3] = open_floating_window;
$windows[1] = open_floating_window;
focus_windows;

cmd '[id=' . $windows[1]->id . '] focus';
cmd '[id=' . $windows[0]->id . '] kill';

kill_and_confirm_focus($windows[2]->id, 'window 2 focused after tiling killed');
kill_and_confirm_focus($windows[3]->id, 'window 3 focused after tiling killed');

done_testing;
