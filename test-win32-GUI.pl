use 5.010;
use strict;
use Win32::GUI();
use Data::Dumper;

my $text = defined($ARGV[0]) ? $ARGV[0] : "Hello, world";
my $dice_size = 5;

my $main = Win32::GUI::Window->new(
  -name => 'Main',
  -text => 'Perl',
  -width => 192 * 5,
  -height => 285,
  -hasmaximize => 0,
  -sizable => 0,
  -resizable => 0,
    );
my $font = Win32::GUI::Font->new(
  -name => "Comic Sans MS",
  -size => 24,
    );
my $label = $main->AddLabel(
  -text => $text,
  -font => $font,
  -foreground => [255, 0, 0],
    );

my @begin_end_img_array;        # start & over button images.
my @dice_img_array;             # 6 dices images.
my @dice_label_array;           # dice labels.
sub get_bitmap_object{
  my ($name, $array_name) = @_;
  $name = 'img/' . $name . '.bmp';
  say $name;
  my $tmp = new Win32::GUI::Bitmap($name);
  if(delete_duplicate_in_array($array_name, $tmp)){
    push @$array_name, $tmp;
  }
  $tmp;
}

sub delete_duplicate_in_array{
  my ($array_name, $tmp) = @_;
  my $flag = 1;
  foreach(@$array_name){
    if($_->{-handle} == $tmp->{-handle}){
      $flag = 0;
    }
  }
  $flag;
}
my $img_roll_begin = get_bitmap_object("roll_begin", \@begin_end_img_array);
my $img_roll_stop = get_bitmap_object("roll_stop", \@begin_end_img_array);
my $width_base = 192;
# say Dumper(@begin_end_img_array);
my $roll_button = $main->AddButton(
  -name => "roll_button",
  -width => 953,
  -height => 64,
  -bitmap => $img_roll_begin,
  -top => 192,
    );
for(1..6){
  get_bitmap_object('dice_' . $_, \@dice_img_array);
}
for (1..$dice_size){
  $dice_label_array[$_ - 1] = new Win32::GUI::Label(
    -name => "dice_$_",
    -bitmap => $dice_img_array[$_ - 1],
    -parent => $main,           # must assign the PARENT!!
    -left => ($_ - 1) * $width_base,
      );
#  say 'haha ' . $_ . '   ' . Dumper($dice_label_array[$_ - 1]);
  $main->AddLabel($dice_label_array[$_ - 1]);
}

# say Dumper(@dice_label_array);
my $t1 = $main->AddTimer('T1', 0);

sub T1_Timer {
#  print "Timer went off!\n";
  foreach (@dice_label_array){
    my $tmp = int(rand(6));
    $_->SetImage($dice_img_array[$tmp]);
  }
}

sub roll_button_Click{
  state  $n = 0;
#  say "Roll button click.";
  $n = 0 if ++$n >= scalar(@begin_end_img_array);
  $roll_button->SetImage($begin_end_img_array[$n]);
  my $tmp_interval = $t1->Interval();
  if($tmp_interval == 0){
    $t1->Interval(100);
  }
  else{
    $t1->Interval(0);
  }
}

my $ncw = $main->Width() - $main->ScaleWidth();
my $nch = $main->Height() - $main->ScaleHeight();
my $w = 192* 5  + $ncw;
my $h = 285 + $nch;

my $desk = Win32::GUI::GetDesktopWindow();
my $dw = Win32::GUI::Width($desk);
my $dh = Win32::GUI::Height($desk);
my $x = ($dw - $w) / 2;
my $y = ($dh - $h) / 2;

$main->Move($x, $y);            # move the window to the screen center.
$main->Show();

Win32::GUI::Dialog();

sub Main_Terminate {
  -1;
}

sub Main_Resize {
  my $mw = $main->ScaleWidth();
  my $mh = $main->ScaleHeight();
  my $lw = $label->Width();
  my $lh = $label->Height();

  $label->Left(int(($mw - $lw) / 2));
  $label->Top(int(($mh - $lh) / 2));
}
