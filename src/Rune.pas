unit Rune;

interface

uses
  Item;

type

  PRune = ^TRune;
  TRune = class ( TItem )

    constructor Create( name : string );
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

var

  RunePack : TRunePack;

implementation

uses
  Resources;

procedure Init;
begin
  RunePack.Add('Iwaz');
  RunePack.Find('Iwaz')^.texture := txt_pack_Rune.Find('Iwaz');

  RunePack.Add('Sowilu');
  RunePack.Find('Sowilu')^.texture := txt_pack_Rune.Find('Sowilu');
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

end.
