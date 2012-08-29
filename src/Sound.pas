unit Sound;

interface

uses
  DGLE2,

  Resources;

type

  TMusicTheme = ( Atmosphere, Battle );
  TMusicState = ( Still, Decreases );

  TMusic = record
    data : PMusic;
    theme : TMusicTheme;
    state : TMusicState;
  end;

  TMusicList = record
  private
    music : array of TMusic;
    buffer : array of TMusic;

    count : Byte;
    current : Byte;
    current_theme : TMusicTheme;

  public
    procedure Add( music_file : PMusic; music_theme : TMusicTheme );
    procedure Del( music_file : PMusic );
    procedure Mix;

    procedure Next;
    procedure Pre;

    procedure Decrease( index : Integer );
    procedure Regulator;

    procedure SetTheme( theme : TMusicTheme );

    procedure Init;
    procedure Update;
  end;

procedure Init;
procedure Update;
procedure Free;

var
  SoundChannel : ISoundChannel;

  MusicList : TMusicList;

implementation

uses
  SubSystems,
  Settings;

procedure Init;
begin
  MusicList.Init;

  MusicList.Add( music_pack.Find('Atmosphere_001'), Atmosphere );
  MusicList.Add( music_pack.Find('Atmosphere_002'), Atmosphere );
  MusicList.Add( music_pack.Find('Atmosphere_003'), Atmosphere );
  MusicList.Add( music_pack.Find('Atmosphere_004'), Atmosphere );
  MusicList.Add( music_pack.Find('Atmosphere_005'), Atmosphere );
  MusicList.Add( music_pack.Find('Atmosphere_006'), Atmosphere );
  MusicList.Add( music_pack.Find('Atmosphere_007'), Atmosphere );
  MusicList.Add( music_pack.Find('Battle_001'), Battle );

  MusicList.Mix;

  if Settings.Sound.Sound then SoundChannel.PlayOrPause;
end;

procedure Update;
begin
  if Settings.Sound.Music then MusicList.Update;
end;

procedure Free;
begin
  SoundChannel := nil;
end;

{ TMusicList }

procedure TMusicList.Add( music_file : PMusic; music_theme : TMusicTheme );
begin
  SetLength( music, count + 1 );
  SetLength( buffer, count + 1 );

  music[ count ].data := music_file;
  music[ count ].theme := music_theme;
  music[ count ].state := Still;

  Inc( count );
end;

procedure TMusicList.Del( music_file: PMusic );
var
  i: Integer;
begin
  for i := 0 to count - 1 do
    if music[ i ].data = music_file then
      music[ i ].data := nil;
end;

procedure TMusicList.Mix;
var
  k : Integer;
  c : Integer;
  new : Integer;
  index : Integer;
  used : array of Boolean;
begin
  SetLength( used, count );
  for k := 0 to count - 1 do
    used[ k ] := False;

  for k := 0 to count - 1 do
  begin
    repeat
      index := Random( count );
    until
      used[ index ] = False;

    buffer[ index ] := music[ k ];
    if k = current then new := index;

    used[ index ] := True;
  end;

  for k := 0 to count - 1 do
    music[ k ] := buffer[ k ];

  current := new;
end;


procedure TMusicList.Decrease( index : Integer );
var
  volume : Cardinal;
begin
  music[ index ].data.GetVolume( volume );
  if volume > 0 then music[ index ].data.SetVolume( volume - 1 );
  if volume = 0 then
  begin
    music[ index ].data.Stop;
    music[ index ].data.SetVolume( 100 );
    music[ index ].state := Still;
  end;
end;

procedure TMusicList.Regulator;
var
  i: Integer;
begin
  for i := 0 to count - 1 do
  case music[ i ].state of
    Decreases: Decrease( i );
  end;
end;


procedure TMusicList.Next;
begin
  music[ current ].state := Decreases;

  Inc( current );
  if current > count - 1 then current := 0;

  if music[ current ].theme <> current_theme then Next;
end;

procedure TMusicList.Pre;
begin
  music[ current ].state := Decreases;

  Dec( current );
  if current < 0 then current := count - 1;

  if music[ current ].theme <> current_theme then Pre;
end;


procedure TMusicList.SetTheme(theme: TMusicTheme);
begin
  if current_theme <> theme then
  begin
    current_theme := theme;
    Mix;
    Next;
  end;
end;


procedure TMusicList.Init;
begin
  current_theme := Atmosphere;
end;

procedure TMusicList.Update;
var
  current_pos : Cardinal;
  Length : Cardinal;
  result : Boolean;
begin
  music[ current ].data.GetCurrentPosition( current_pos );
  music[ current ].data.GetLength( length );

  if current_pos >= Length then Next;

  music[ current ].data.IsPlaying( result );
  if result = false then  music[ current ].data.Play( False );

  Regulator;
end;

end.
