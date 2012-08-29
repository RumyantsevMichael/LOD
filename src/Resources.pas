unit Resources;

interface

uses
  DGLE2,
  DGLE2_EXT;

type

  PTexture = ^ITexture;
  TTexture = record
    Name : string;
    Data : ITexture;
    isFree : Boolean;
  end;

  TTxtPack = record
    Item : array of TTexture;

    function Add( Name : string ): PTexture;
    function Find( Name : string ): PTexture;
    procedure Free;
  end;

////////////////////////////////////////////////////////////////////////////////

  PFont = ^IBitmapFont;
  TFont = record
    Name : string;
    Data : array [5..50] of IBitmapFont;
  end;

  TFntPack = record
    Item : array of TFont;

    function Add( Name : string; Size : Byte ): PFont;
    function Find( Name : string; Size : Byte = 10 ): PFont;
    procedure Free;
  end;

////////////////////////////////////////////////////////////////////////////////

  PSound = ^ISoundSample;
  TSound = record
    Name : string;
    Data : ISoundSample;
    isFree : Boolean;
  end;

  TSndPack = record
    Item : array of TSound;

    function Add( Name : string ): PSound;
    function Find( Name : string ): PSound;
    procedure Free;
  end;

////////////////////////////////////////////////////////////////////////////////

  PMusic = ^IMusic;
  TMusic = record
    Name : string;
    Data : IMusic;
    isFree : Boolean;
  end;

  TMusicPack = record
    Item : array of TMusic;

    function Add( Name : string ): PMusic;
    function Find( Name : string ): PMusic;
    procedure Free;
  end;

////////////////////////////////////////////////////////////////////////////////

const
  RES_PATH = 'Data\';
  TXT_PATH = RES_PATH + 'Textures\';
  SND_PATH = RES_PATH + 'Sound\';
  PRT_PATH = RES_PATH + 'Particles\';

var

  TLF : Integer = TLF_FILTERING_NONE;

  FntPack : TFntPack;

  ts_ground : ITexture;
  ts_decoration : ITexture;
  tp_object : TTxtPack;

  txt_pack_GUI: TTxtPack;
  txt_pack_Mob: TTxtPack;

  txt_pack_Item: TTxtPack;
  txt_pack_Rune: TTxtPack;

  sound_pack : TSndPack;
  music_pack : TMusicPack;

  pp_Fireball : IParticleEffect = nil;
  pp_Shokwave : IParticleEffect = nil;
  pp_Poisoning : IParticleEffect = nil;

procedure Load;
procedure Free;

implementation

uses
  System.SysUtils,

  SubSystems,
  Settings,
  Convert;

procedure Load;
var
  i: Integer;
begin
  TLF := Settings.Graphics.Filtration;

  {$REGION ' Fonts '}
    for i := 5 to 18 do
      ResMan.Load(
                  StrToPAChar( RES_PATH + 'UI\Fonts\Tahoma\' + IntToStr( i ) + '.dft'),
                  IEngBaseObj( FntPack.Add('Tahoma', i  )^)
                  );

    for i := 17 to 24 do
      ResMan.Load(
                  StrToPAChar( RES_PATH + 'UI\Fonts\Lineage\' + IntToStr( i ) + '.dft'),
                  IEngBaseObj( FntPack.Add('Lineage', i  )^)
                  );

    for i := 10 to 24 do
      ResMan.Load(
                  StrToPAChar( RES_PATH + 'UI\Fonts\Fiddums\' + IntToStr( i ) + '.dft'),
                  IEngBaseObj( FntPack.Add('Fiddums', i  )^)
                  );

    for i := 10 to 24 do
      ResMan.Load(
                  StrToPAChar( RES_PATH + 'UI\Fonts\Centaur\' + IntToStr( i ) + '.dft'),
                  IEngBaseObj( FntPack.Add('Centaur', i  )^)
                  );
  {$ENDREGION}

  ResMan.Load( RES_PATH + 'Mob\player.png', IEngBaseObj(txt_pack_Mob.Add('player')^), TLF );
                                                        txt_pack_Mob.Find('player').SetFrameSize( 32, 32 );
  ResMan.Load( RES_PATH + 'Mob\bot.png',    IEngBaseObj(txt_pack_Mob.Add('bot')^),    TLF );
                                                        txt_pack_Mob.Find('bot').SetFrameSize( 32, 32 );

  // GUI
  ResMan.Load( RES_PATH + 'UI\border.png', IEngBaseObj(txt_pack_GUI.Add('border')^), TLF);
  ResMan.Load( RES_PATH + 'UI\angle.png',  IEngBaseObj(txt_pack_GUI.Add('angle')^),  TLF);
  ResMan.Load( RES_PATH + 'UI\back.png',   IEngBaseObj(txt_pack_GUI.Add('back')^),   TLF);

  ResMan.Load( RES_PATH + 'UI\bag.png',    IEngBaseObj(txt_pack_GUI.Add('bag')^),    TLF);
  ResMan.Load( RES_PATH + 'UI\bag_d.png',  IEngBaseObj(txt_pack_GUI.Add('bag_d')^),  TLF);
  ResMan.Load( RES_PATH + 'UI\bag_f.png',  IEngBaseObj(txt_pack_GUI.Add('bag_f')^),  TLF);

  ResMan.Load( RES_PATH + 'UI\button\button.png',   IEngBaseObj(txt_pack_GUI.Add('button')^),   TLF);
  ResMan.Load( RES_PATH + 'UI\button\button_f.png', IEngBaseObj(txt_pack_GUI.Add('button_f')^), TLF);

  ResMan.Load( RES_PATH + 'UI\corner.png',   IEngBaseObj(txt_pack_GUI.Add('corner')^),   TLF);
  ResMan.Load( RES_PATH + 'UI\hud.png',      IEngBaseObj(txt_pack_GUI.Add('hud')^),      TLF);
  ResMan.Load( RES_PATH + 'UI\hud_hp.png',   IEngBaseObj(txt_pack_GUI.Add('hud_hp')^),   TLF);
  ResMan.Load( RES_PATH + 'UI\hud_mp.png',   IEngBaseObj(txt_pack_GUI.Add('hud_mp')^),   TLF);

  ResMan.Load( RES_PATH + 'UI\potion_r.png', IEngBaseObj(txt_pack_GUI.Add('potion_r')^), TLF);
  ResMan.Load( RES_PATH + 'UI\potion_b.png', IEngBaseObj(txt_pack_GUI.Add('potion_b')^), TLF);
  ResMan.Load( RES_PATH + 'UI\potion_y.png', IEngBaseObj(txt_pack_GUI.Add('potion_y')^), TLF);
  ResMan.Load( RES_PATH + 'UI\potion.png',   IEngBaseObj(txt_pack_GUI.Add('potion')^),   TLF);

  ResMan.Load( RES_PATH + 'UI\pict.png', IEngBaseObj(txt_pack_GUI.Add('pict')^), TLF);

  ResMan.Load( RES_PATH + 'UI\+.png',   IEngBaseObj(txt_pack_GUI.Add('+')^),   TLF);
  ResMan.Load( RES_PATH + 'UI\+_f.png', IEngBaseObj(txt_pack_GUI.Add('+_f')^), TLF);
  ResMan.Load( RES_PATH + 'UI\-.png',   IEngBaseObj(txt_pack_GUI.Add('-')^),   TLF);
  ResMan.Load( RES_PATH + 'UI\-_f.png', IEngBaseObj(txt_pack_GUI.Add('-_f')^), TLF);

  // Items
  ResMan.Load( RES_PATH + 'Items\coin.png',  IEngBaseObj(txt_pack_Item.Add('coin')^),  TLF);
  ResMan.Load( RES_PATH + 'Items\sword.png', IEngBaseObj(txt_pack_Item.Add('sword')^), TLF);

  ResMan.Load( RES_PATH + 'Items\Runes\Iwaz.png',    IEngBaseObj(txt_pack_Rune.Add('Iwaz')^),    TLF);
  ResMan.Load( RES_PATH + 'Items\Runes\Ansuz.png',   IEngBaseObj(txt_pack_Rune.Add('Ansuz')^),  TLF);
  ResMan.Load( RES_PATH + 'Items\Runes\Sowilu.png',  IEngBaseObj(txt_pack_Rune.Add('Sowilu')^),  TLF);
  ResMan.Load( RES_PATH + 'Items\Runes\Berkana.png', IEngBaseObj(txt_pack_Rune.Add('Berkana')^), TLF);

  // Sound
  ResMan.Load( SND_PATH + 'Music\Atmosphere_001.mp3', IEngBaseObj(music_pack.Add('Atmosphere_001')^));
  ResMan.Load( SND_PATH + 'Music\Atmosphere_002.mp3', IEngBaseObj(music_pack.Add('Atmosphere_002')^));
  ResMan.Load( SND_PATH + 'Music\Atmosphere_003.mp3', IEngBaseObj(music_pack.Add('Atmosphere_003')^));
  ResMan.Load( SND_PATH + 'Music\Atmosphere_004.mp3', IEngBaseObj(music_pack.Add('Atmosphere_004')^));
  ResMan.Load( SND_PATH + 'Music\Atmosphere_005.mp3', IEngBaseObj(music_pack.Add('Atmosphere_005')^));
  ResMan.Load( SND_PATH + 'Music\Atmosphere_006.mp3', IEngBaseObj(music_pack.Add('Atmosphere_006')^));
  ResMan.Load( SND_PATH + 'Music\Atmosphere_007.mp3', IEngBaseObj(music_pack.Add('Atmosphere_007')^));
  ResMan.Load( SND_PATH + 'Music\Battle_001.mp3',     IEngBaseObj(music_pack.Add('Battle_001')^));

  // Particles
  ResMan.Load( PRT_PATH + 'Fireball.pyro',  IEngBaseObj( pp_Fireball ));
  ResMan.Load( PRT_PATH + 'Shokwave.pyro',  IEngBaseObj( pp_Shokwave ));
  ResMan.Load( PRT_PATH + 'Poisoning.pyro', IEngBaseObj( pp_Poisoning ));
end;

procedure Free;
begin
  ts_ground := nil;
  ts_decoration := nil;
  tp_object.Free;

  txt_pack_Mob.Free;

  txt_pack_GUI.Free;

  txt_pack_Item.Free;
  txt_pack_Rune.Free;

  pp_Fireball := nil;
  pp_Shokwave := nil;
  pp_Poisoning := nil;

  FntPack.Free;

  sound_pack.Free;
  music_pack.Free;
end;

{ TTxttxt_pack_Txt }

function TTxtPack.Add( Name : string ): PTexture;
var
  i: Integer;
  j: Integer;
  N: Boolean;
  L: Integer;
begin

  j := 0;
  N := True;
  L := Length( Item );

  for i := 0 to L - 1 do
  begin
    if Item[ i ].isFree then
    begin
      j := i;
      N := False;
    end;
  end;

  if N then
  begin
    SetLength( Item, L + 1 );
    j := L;
  end;

  Item[ j ].Name := Name;
  Item[ j ].isFree := False;
  Result := @Item[ j ].Data;

end;

function TTxtPack.Find(Name: string): PTexture;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Length( Item ) - 1 do
    if Item[ i ].Name = Name then
      if not Item[ i ].isFree then
        Result := @Item[ i ].Data;
end;

procedure TTxtPack.Free;
var
  i: Integer;
begin
  for i := 0 to Length( Item ) - 1 do
  begin
    Item[ i ].Data := nil;
    Item[ i ].isFree := True;
  end;
end;

{ TFntPack }////////////////////////////////////////////////////////////////////

function TFntPack.Add(Name: string; Size : Byte): PFont;
var
  i: Integer;
  l: Integer;
begin
  l := Length( Item );

  for i := 0 to l - 1 do
  if item[ i ].Name = Name then
  begin
    Item[ i ].Name := Name;
    Result := @Item[ i ].Data[ Size ];
    Exit;
  end;

  SetLength( Item, l + 1 );
  Item[ l ].Name := Name;
  Result := @Item[ l ].Data[ Size ];
end;

function TFntPack.Find(Name: string; Size : Byte = 10): PFont;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Length( Item ) - 1 do
    if Item[ i ].Name = Name then
      if Item[ i ].Data[ Size ] <> nil then
        Result := @Item[ i ].Data[ Size ];
end;

procedure TFntPack.Free;
var
  i: Integer;
  j: Integer;
begin
  for i := 0 to Length( Item ) - 1 do
  begin
    Item[ i ].Name := '';

    for j := 5 to 50 do
      Item[ i ].Data[ j ] := nil;
  end;
end;

{ TSndPack }

function TSndPack.Add(Name: string): PSound;
var
  i: Integer;
  j: Integer;
  N: Boolean;
  L: Integer;
begin

  j := 0;
  N := True;
  L := Length( Item );

  for i := 0 to L - 1 do
  begin
    if Item[ i ].isFree then
    begin
      j := i;
      N := False;
    end;
  end;

  if N then
  begin
    SetLength( Item, L + 1 );
    j := L;
  end;

  Item[ j ].Name := Name;
  Item[ j ].isFree := False;
  Result := @Item[ j ].Data;
end;

function TSndPack.Find(Name: string): PSound;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Length( Item ) - 1 do
    if Item[ i ].Name = Name then
      if not Item[ i ].isFree then
        Result := @Item[ i ].Data;
end;

procedure TSndPack.Free;
var
  i: Integer;
begin
  for i := 0 to Length( Item ) - 1 do
  begin
    Item[ i ].Data := nil;
    Item[ i ].isFree := True;
  end;
end;

{ TMusicPack }

function TMusicPack.Add(Name: string): PMusic;
var
  i: Integer;
  j: Integer;
  N: Boolean;
  L: Integer;
begin

  j := 0;
  N := True;
  L := Length( Item );

  for i := 0 to L - 1 do
  begin
    if Item[ i ].isFree then
    begin
      j := i;
      N := False;
    end;
  end;

  if N then
  begin
    SetLength( Item, L + 1 );
    j := L;
  end;

  Item[ j ].Name := Name;
  Item[ j ].isFree := False;
  Result := @Item[ j ].Data;
end;

function TMusicPack.Find(Name: string): PMusic;
var
  i : Integer;
begin
  Result := nil;

  for i := 0 to Length( Item ) - 1 do
    if Item[ i ].Name = Name then
      if not Item[ i ].isFree then
        Result := @Item[ i ].Data;
end;

procedure TMusicPack.Free;
var
  i : Integer;
begin
  for i := 0 to Length( Item ) - 1 do
  begin
    Item[ i ].Data := nil;
    Item[ i ].isFree := True;
  end;
end;

end.
