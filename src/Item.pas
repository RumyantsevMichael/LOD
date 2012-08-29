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

    procedure RenderInfo( x, y : Integer ); virtual; abstract;
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

end.
