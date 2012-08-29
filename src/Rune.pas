unit Rune;

interface

uses
  Item;

type

  PRune = ^TRune;
  TRune = class ( TItem )
    Level : Byte;

    constructor Create( name : string );

    function Clone: TRune;
    procedure RenderInfo( x, y : Integer ); override;
  end;

  TRunePack = record
    item : array of TRune;
    count : Byte;

    procedure Add( name : string );
    function Find( name : string ): PRune;
  end;

  TRuneStack = record
    Stack : array of TRune;
  end;

procedure Init;

function MakeRune( name : string; Level : Byte ): TRune;

var

  RunePack : TRunePack;

implementation

uses
  DGLE2,
  DGLE2_types,

  SubSystems,
  Resources,
  Convert;

procedure Init;
begin
  RunePack.Add('Iwaz');
  RunePack.Find('Iwaz')^.texture := txt_pack_Rune.Find('Iwaz');

  RunePack.Add('Ansuz');
  RunePack.Find('Ansuz')^.texture := txt_pack_Rune.Find('Ansuz');

  RunePack.Add('Sowilu');
  RunePack.Find('Sowilu')^.texture := txt_pack_Rune.Find('Sowilu');

  RunePack.Add('Berkana');
  RunePack.Find('Berkana')^.texture := txt_pack_Rune.Find('Berkana');
end;


function MakeRune( name : string; Level : Byte ): TRune;
begin
  Result := RunePack.Find( name ).Clone;
  Result.Level := Level;
end;

{ TRunePack }

procedure TRunePack.Add(name: string);
begin
  SetLength( Self.item, count + 1 );
  Self.item[ count ] := TRune.Create( name );
  Inc( count );
end;

function TRunePack.Find(name: string): PRune;
var
  i: Integer;
begin
  Result := @Item[ 0 ];

  for i := 0 to count - 1 do
    if item[ i ].name = name then
      Result := @Item[ i ];
end;

{ TRune }

constructor TRune.Create(name: string);
begin
  inherited Create;

  Self.name := name;
end;

function TRune.Clone: TRune;
begin
  Result := TRune.Create( Self.name );
  Result.texture := Self.texture;
end;

procedure TRune.RenderInfo( x, y : Integer );
var
  rect : TRectf;
  w : Cardinal;
  h : Cardinal;
begin
  FntPack.Find('Tahoma').GetTextDimensions( StrToPAChar( Self.name ), w, h );

  rect.x := x;
  rect.y := y;
  rect.width := w;
  rect.height := h * 2;

  Render2D.DrawRect( rect, Color4 );
  Render2D.DrawRect( rect, color4($0), PF_FILL );

  FntPack.Find('Tahoma').Draw2D( x, y, StrToPAChar( name ), Color4 );
  FntPack.Find('Tahoma').Draw2D( x, y + h, IntToPAChar( Level ), Color4 );
end;

end.
