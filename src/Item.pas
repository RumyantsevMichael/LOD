unit Item;

interface

uses
  Resources;

type

  PItem = ^TItem;
  TItem = class
    name : string;
    price : Integer;
    texture : PTexture;

    foldable : Boolean;

    constructor Create;

    procedure RenderInfo( x, y : Integer );
  end;

implementation

uses
  System.SysUtils,

  DGLE2,
  DGLE2_types,

  SubSystems,
  Convert;

{ TItem }

constructor TItem.Create;
begin
  inherited Create;
end;

procedure TItem.RenderInfo( x, y : Integer );
var
  rect : TRectf;
  w : Cardinal;
  h : Cardinal;
begin
  FntPack.Find('Tahoma').GetTextDimensions( StrToPAChar( Self.name ), w, h );

  rect.x := x;
  rect.y := y;
  rect.width := w;
  rect.height := h;

  Render2D.DrawRect( rect, Color4 );
  Render2D.DrawRect( rect, color4($0), PF_FILL );

  FntPack.Find('Tahoma').Draw2D( x, y, StrToPAChar( name ), Color4 );
end;

end.
