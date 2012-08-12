unit Item.Coin;

interface

uses
  Item;

type

  TCoin = class ( TItem )
    constructor Create( value : Integer );
  end;

implementation

uses
  System.SysUtils,

  Resources;

{ TCoin }

constructor TCoin.Create(value: Integer);
begin
  inherited Create;

  if value = 1 then
    name := 'Coin'
  else
    name := IntTostr( value ) + ' Coins';

  price := value;

  texture := @txt_pack_Item.Find('coin')^;
end;

end.
