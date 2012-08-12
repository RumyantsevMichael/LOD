unit Sound;

interface

uses
  DGLE2;

type

  TSoundStack = record
    item : array of ISoundSample;

    procedure Add;
    procedure Update;
  end;

implementation

{ TSoundStack }

procedure TSoundStack.Add;
begin

end;

procedure TSoundStack.Update;
begin

end;

end.
