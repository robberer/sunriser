package SunRiser::Publisher;

use Moo;

with 'SunRiser::Role::Logger';

sub _build__logger_category { 'SR_PUBLISHER' }

use Text::Xslate qw( mark_raw );
use JavaScript::Value::Escape;
use Path::Tiny;
use File::ShareDir::ProjectDistDir;

has publish_files => (
  is => 'ro',
  lazy => 1,
  builder => 1,
);

sub _build_publish_files {
  my ( $self ) = @_;
  return [qw(
    index.html
    login.html
  )];
}

sub has_publish_file {
  my ( $self, $file ) = @_;
  my %files = ( map { $_, 1 } @{$self->publish_files} );
  return defined $files{$file};
}

sub publish_to {
  my ( $self, $dir ) = @_;
  $self->info('Publishing all files to '.$dir);
  my @files = @{$self->publish_files};
  for my $filename (@files) {
    my $file = path($dir,$filename);
    $file->parent->mkpath unless -d $file->parent;
    $file->spew_utf8($self->render($filename));
  }
}

sub render {
  my ( $self, $file ) = @_;
  $self->info('Generating '.$file.' from template');
  my $template = $file.'.tx';
  my %vars = %{$self->base_vars};
  $vars{file} = $file;
  return $self->template_engine->render($template,\%vars);
}

has base_vars => (
  is => 'ro',
  lazy => 1,
  builder => 1,
);

sub _build_base_vars {
  my ( $self ) = @_;
  return {};
}

has template_path => (
  is => 'ro',
  lazy => 1,
  builder => 1,
);

sub _build_template_path {
  path(dist_dir('SunRiser'),'templates')->absolute->stringify
}

has template_engine => (
  is => 'ro',
  lazy => 1,
  builder => 1,
);

sub _build_template_engine {
  my ( $self ) = @_;
  my $templates = $self->template_path;
  return Text::Xslate->new(
    path => [$templates],
    function => {
      js => sub { return mark_raw(javascript_value_escape(join("",@_))) },
      r => sub { return mark_raw(join("",@_)) },
      substr => sub {
        my($str, $offset, $length) = @_;
        return undef unless defined $str;
        $offset = 0 unless defined $offset;
        $length = length($str) unless defined $length;
        return CORE::substr($str, $offset, $length);
      },
      lc => sub {
        return defined($_[0]) ? CORE::lc($_[0]) : undef;
      },
      uc => sub {
        return defined($_[0]) ? CORE::uc($_[0]) : undef;
      },
    },
  );
}


1;